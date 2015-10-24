//
//  BoundaryPolygon.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 8/16/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "BoundaryPolygon.h"
#import "Boundary.h"

@implementation BoundaryPolygon

@synthesize boundary=_boundary;
@synthesize polygon=_polygon;

-(CLLocationCoordinate2D) coordinate {
    return [self.polygon coordinate];
}

-(MKMapRect) boundingMapRect {
    return [self.polygon boundingMapRect];
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
    return [self.polygon intersectsMapRect:mapRect];
}

- (void)dealloc
{
    [_polygon release];
    [super dealloc];
}



@end
