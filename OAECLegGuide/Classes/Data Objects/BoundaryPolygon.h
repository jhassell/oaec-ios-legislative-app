//
//  BoundaryPolygon.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 8/16/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Boundary;

@interface BoundaryPolygon: NSObject <MKOverlay>

@property (nonatomic, assign) Boundary *boundary;
@property (nonatomic, retain) MKPolygon *polygon;


@end
