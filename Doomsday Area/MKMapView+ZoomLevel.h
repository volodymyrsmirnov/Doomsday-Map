//
//  MKMapView+ZoomLevel.h
//  Doomsday Area
//
//  Created by Vladimir Smirnov on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// taken from http://troybrant.net/blog/2010/01/set-the-zoom-level-of-an-mkmapview/


#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end