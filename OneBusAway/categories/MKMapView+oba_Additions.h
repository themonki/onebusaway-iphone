//
//  MKMapView+oba_Additions.h
//  org.onebusaway.iphone
//
//  Created by Aaron Brethorst on 9/22/12.
//
//

// From http://troybrant.net/blog/2010/01/set-the-zoom-level-of-an-mkmapview/

@import MapKit;

NS_ASSUME_NONNULL_BEGIN

@interface MKMapView (oba_Additions)
- (void)oba_setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated;
- (NSUInteger)oba_zoomLevel;
@end

NS_ASSUME_NONNULL_END
