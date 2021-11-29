//
//  Boundary.h
//  HereOk
//
//  Created by Matt Galloway on 4/14/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define BOUNDARY_TYPE_STATE_HOUSE @"State House District"
#define BOUNDARY_TYPE_STATE_SENATE  @"State Senate District"
#define BOUNDARY_TYPE_FEDERAL_HOUSE @"Congressional District"
#define BOUNDARY_TYPE_COOP @"OAEC Region"


@interface Boundary : NSObject;

- (id)initWithPolygons:(NSArray *) polygons name:(NSString *)name type:(NSString *)type metadata:(NSDictionary *)metadata set:(NSString *)set;

+ (Boundary *)boundaryWithBoundaryServiceDictionary:(NSDictionary *)boundaryServiceDictionary;
+ (NSDictionary *) buildBoundaryDictionaryWithJSONFile:(NSString *)jsonFilename;
+ (NSDictionary *) buildDistrictDictionaryWithGEOJSONFile:(NSString *)jsonFilename andDistrictType:(NSString *)districtType;
+ (Boundary *) boundaryDistrictWithBoundaryServiceDictionaryforGEOJSON:(NSDictionary *)boundaryServiceDictionary andDistrictType:(NSString *)districtType;


-(void) addPolygons:(NSMutableArray *)polygons;
-(BOOL)pointInside:(CLLocationCoordinate2D )point;

@property (nonatomic, readonly) NSMutableArray *polygons;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *set;
@property (nonatomic, readonly) NSDictionary *metadata;
@property (nonatomic, retain) UIColor *color;

@end
