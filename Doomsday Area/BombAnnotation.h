//
//  BombAnnotation.h
//  Doomsday Area
//
//  Created by Vladimir Smirnov on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface BombAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}

@property (assign, nonatomic) NSString *bTitle;
@property (assign, nonatomic) NSString *bDescription;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c;

- (void)setCoordinate:(CLLocationCoordinate2D) c;

@end
