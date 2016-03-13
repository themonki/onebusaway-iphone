//
//  OBABookmarksViewController.m
//  org.onebusaway.iphone
//
//  Created by Aaron Brethorst on 3/9/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "OBABookmarksViewController.h"
#import "OBAApplication.h"
#import "OBABookmarkGroup.h"
#import "OBAStopViewController.h"
#import "OBAEditStopBookmarkViewController.h"

@interface OBABookmarksViewController ()

@end

@implementation OBABookmarksViewController

- (instancetype)init {
    self = [super init];

    if (self) {
        self.tabBarItem.title = NSLocalizedString(@"Bookmarks", @"Bookmarks tab title");
        self.tabBarItem.image = [UIImage imageNamed:@"Bookmarks"];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.allowsSelectionDuringEditing = YES;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSString *title = nil;
    if (self.currentRegion) {
        title = [NSString stringWithFormat:NSLocalizedString(@"Bookmarks - %@", @""), self.currentRegion.regionName];
    }
    else {
        title = NSLocalizedString(@"Bookmarks", @"");
    }
    self.navigationItem.title = title;

    [self loadData];
}

#pragma mark OBANavigationTargetAware

- (OBANavigationTarget *)navigationTarget {
    return [OBANavigationTarget target:OBANavigationTargetTypeBookmarks];
}

#pragma mark - Data Loading

- (void)loadData {
    OBAModelDAO *modelDAO = [OBAApplication sharedApplication].modelDao;

    NSMutableArray *sections = [[NSMutableArray alloc] init];

    for (OBABookmarkGroup *group in modelDAO.bookmarkGroups) {
        NSArray *rows = [self tableRowsFromBookmarks:group.bookmarks];
        OBATableSection *section = [[OBATableSection alloc] initWithTitle:group.name rows:rows];
        [sections addObject:section];
    }

    OBATableSection *looseBookmarks = [[OBATableSection alloc] initWithTitle:nil rows:[self tableRowsFromBookmarks:modelDAO.bookmarks]];
    [sections addObject:looseBookmarks];

    self.sections = sections;
    [self.tableView reloadData];
}

#pragma mark - UITableView

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Disabled for now. This requires more time and attention than I can give it at the moment.
// I'd love to re-enable this feature, and soon, though.
- (BOOL)tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
// Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    OBATableSection *tableSection = self.sections[indexPath.section];
    OBATableRow *tableRow = tableSection.rows[indexPath.row];

    NSMutableArray *rows = [NSMutableArray arrayWithArray:tableSection.rows];
    [rows removeObjectAtIndex:indexPath.row];
    tableSection.rows = rows;

    if (tableRow.deleteModel) {
        tableRow.deleteModel();
    }

    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Accessors

- (OBARegionV2*)currentRegion {
    return [OBAApplication sharedApplication].modelDao.region;
}

#pragma mark - Private

- (NSArray<OBATableRow*>*)tableRowsFromBookmarks:(NSArray<OBABookmarkV2*>*)bookmarks {
    NSMutableArray *rows = [NSMutableArray array];

    for (OBABookmarkV2 *bm in bookmarks) {
        OBATableRow *row = [[OBATableRow alloc] initWithTitle:bm.name action:^{
            OBAStopViewController *controller = [[OBAStopViewController alloc] initWithStopID:bm.stopID];
            [self.navigationController pushViewController:controller animated:YES];
        }];
        [row setEditAction:^{
            OBAEditStopBookmarkViewController *editor = [[OBAEditStopBookmarkViewController alloc] initWithBookmark:bm editType:OBABookmarkEditExisting];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editor];
            [self presentViewController:nav animated:YES completion:nil];
        }];
        [row setDeleteModel:^{
            [[OBAApplication sharedApplication].modelDao removeBookmark:bm];
        }];
        [rows addObject:row];
    }

    return rows;
}

@end