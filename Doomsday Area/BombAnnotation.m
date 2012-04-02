//
//  BombAnnotation.m
//  Doomsday Area
//
//  Created by Vladimir Smirnov on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BombAnnotation.h"
#import <MapKit/MapKit.h>

@implementation BombAnnotation

@synthesize coordinate, bTitle, bDescription;

- (NSString *)subtitle{
    return self.bDescription;
}

- (NSString *)title{
    return self.bTitle;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
    coordinate=c;
    return self;
}


- (void)setCoordinate:(CLLocationCoordinate2D) c 
{
    coordinate = c;
}

@end
