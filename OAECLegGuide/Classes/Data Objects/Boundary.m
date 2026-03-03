//
//  Boundary.m
//  HereOk
//
//  Created by Matt Galloway on 4/14/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "Boundary.h"
#import "BoundaryPolygon.h"
#import "UIColor-Expanded.h"

@implementation Boundary

@synthesize metadata=_metadata;
@synthesize polygons=_polygons;
@synthesize name=_name;
@synthesize type=_type;
@synthesize color=_color;
@synthesize set=_set;

-(BOOL)pointInside:(CLLocationCoordinate2D )point 
{
    BOOL isInside = NO; 
    for(BoundaryPolygon *boundaryPolygon in self.polygons) {
        MKPolygon *polygon = boundaryPolygon.polygon;
        MKPolygonRenderer *polygonView = [[MKPolygonRenderer alloc] initWithPolygon:polygon];
        MKMapPoint mapPoint = MKMapPointForCoordinate(point);        
        CGPoint polygonViewPoint = [polygonView pointForMapPoint:mapPoint];
        BOOL mapCoordinateIsInPolygon = CGPathContainsPoint(polygonView.path, NULL, 
                                                            polygonViewPoint, NO);
        if (mapCoordinateIsInPolygon)
        {
            isInside = YES;
            break;
        }
    }

    return isInside;
}

+(NSDictionary *) buildBoundaryDictionaryWithJSONFile:(NSString *)jsonFilename {
    
    // Load Counties from JSON
    
    NSError *error=nil;
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonFilename] options:0 error:&error];
    
    NSArray *boundaryObjects = [jsonObject objectForKey:@"objects"];
    NSMutableDictionary *boundariesDict = [NSMutableDictionary dictionaryWithCapacity:77];
    for(NSDictionary *boundaryObject in boundaryObjects) {
        Boundary *boundary=[Boundary boundaryWithBoundaryServiceDictionary:boundaryObject];     
        
        Boundary *existingBoundary = [boundariesDict objectForKey:boundary.name];
        if (existingBoundary==nil) {        
            [boundariesDict setObject:boundary forKey:boundary.name];
        } else {
            [existingBoundary addPolygons:boundary.polygons];
        }
    }
    
    return boundariesDict;
}

+(NSDictionary *) buildDistrictDictionaryWithGEOJSONFile:(NSString *)jsonFilename andDistrictType:(NSString *)districtType {
    
    // GEOJSON file renamed with .json extension, but not modified
    
    NSError *error=nil;
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonFilename] options:0 error:&error];
    
    NSArray *boundaryObjects = [jsonObject objectForKey:@"features"];
    NSMutableDictionary *boundariesDict = [NSMutableDictionary dictionaryWithCapacity:77];
    for(NSDictionary *boundaryObject in boundaryObjects) {

        Boundary *boundary = [Boundary boundaryDistrictWithBoundaryServiceDictionaryforGEOJSON:boundaryObject andDistrictType:districtType];
            
        Boundary *existingBoundary = [boundariesDict objectForKey:boundary.name];
        if (existingBoundary==nil) {
            [boundariesDict setObject:boundary forKey:boundary.name];
        } else {
            [existingBoundary addPolygons:boundary.polygons];
        }
    }
    
    return boundariesDict;
}


- (id)initWithPolygons:(NSMutableArray *) polygons name:(NSString *)name type:(NSString *)type metadata:(NSDictionary *)metadata set:(NSString *)set{
    self = [super init];
    if (self) {
        
        [self addPolygons:polygons];
        
        _name=[name retain];
        _type=[type retain];
        _metadata=[metadata retain];
        _color = [[UIColor randomColor] retain];
        _set = [set retain];
    }
    return self;
}

-(void) addPolygons:(NSMutableArray *)polygons {
    for (BoundaryPolygon *boundaryPolygon in polygons) {
        boundaryPolygon.boundary=self;
    } 
    
    if (_polygons==nil) {
        _polygons = [polygons retain];
    } else {
        [_polygons addObjectsFromArray:polygons];
    }
}

+(CLLocationCoordinate2D *) makeCLLocationCoordinate2DArrayFrom:(NSArray *)polygon {
    CLLocationCoordinate2D *polygonCoordinates = NULL;
    polygonCoordinates = malloc(sizeof(CLLocationCoordinate2D) * [polygon count]);
    int index = 0;
    for (NSArray *pointCoordiate in polygon) {
        polygonCoordinates[index++] = CLLocationCoordinate2DMake(
            [(NSNumber *)[pointCoordiate objectAtIndex:1] doubleValue],
            [(NSNumber *)[pointCoordiate objectAtIndex:0] doubleValue]);                                                     
    }
    return polygonCoordinates;
}

+ (Boundary *)boundaryWithBoundaryServiceDictionary:(NSDictionary *)boundaryServiceDictionary{
    NSDictionary *simple_shape = [boundaryServiceDictionary objectForKey:@"simple_shape"];
    
    NSString *type = [simple_shape objectForKey:@"type"];
    if (![type isEqualToString:@"MultiPolygon"]) return nil;
    
    NSArray *coordinates = [simple_shape objectForKey:@"coordinates"];
    if (coordinates==nil || [coordinates count]==0) return nil;
        
    NSMutableArray *multiPolygons = [NSMutableArray arrayWithCapacity:5];
    
    for (NSArray *polygonList in coordinates) {
        
        int index=0;
        CLLocationCoordinate2D *outerPolygonCoordinates=NULL;
        NSUInteger outerPolygonPointCount = 0;
        
        NSMutableArray *innerPolygons = [NSMutableArray arrayWithCapacity:[coordinates count]];

        for (NSArray *polygon in polygonList) {
            if (polygon!=nil && [polygon count]>2) {
                CLLocationCoordinate2D *polygonCoordinates = [Boundary makeCLLocationCoordinate2DArrayFrom:polygon];
                if (index==0) {
                    outerPolygonCoordinates = polygonCoordinates;
                    outerPolygonPointCount = [polygon count];
                } else {
                    MKPolygon *innerPolygon = [MKPolygon polygonWithCoordinates:polygonCoordinates count:[polygon count]];
                    [innerPolygons addObject:innerPolygon];
                    free(polygonCoordinates);
                }
            }
            index++;
        }
        if (outerPolygonCoordinates==NULL) return nil;
        
        MKPolygon *polygon=nil;
        if ([innerPolygons count]==0) {
            polygon = [MKPolygon polygonWithCoordinates:outerPolygonCoordinates count:outerPolygonPointCount];
        } else {
            polygon = [MKPolygon polygonWithCoordinates:outerPolygonCoordinates count:outerPolygonPointCount interiorPolygons:innerPolygons];        
        }
        free(outerPolygonCoordinates);
        
        BoundaryPolygon *boundaryPolygon = [[BoundaryPolygon alloc] init];
        boundaryPolygon.boundary=nil;
        boundaryPolygon.polygon=polygon;
        [multiPolygons addObject:boundaryPolygon];
    }


    NSString *set = [[boundaryServiceDictionary objectForKey:@"set"] lastPathComponent];
    
    Boundary *boundary = [[Boundary alloc] initWithPolygons:multiPolygons
                          name:[boundaryServiceDictionary objectForKey:@"name"] 
                          type:[boundaryServiceDictionary objectForKey:@"kind"] 
                          metadata:[boundaryServiceDictionary objectForKey:@"metadata"]
                          set:set
                          ];

    return [boundary autorelease];
}

+ (Boundary *)boundaryDistrictWithBoundaryServiceDictionaryforGEOJSON:(NSDictionary *)boundaryServiceDictionary andDistrictType:(NSString *)districtType{
    NSDictionary *simple_shape = [boundaryServiceDictionary objectForKey:@"geometry"];
    
    NSString *type = [simple_shape objectForKey:@"type"];
    if (![type isEqualToString:@"Polygon"]) return nil;
    
    NSMutableArray *coordinates = [NSMutableArray arrayWithCapacity:100];
    coordinates[0] = [simple_shape objectForKey:@"coordinates"];
    if (coordinates==nil || [coordinates count]==0) return nil;
        
    NSMutableArray *multiPolygons = [NSMutableArray arrayWithCapacity:5];
    
    for (NSArray *polygonList in coordinates) {
        
        int index=0;
        CLLocationCoordinate2D *outerPolygonCoordinates=NULL;
        NSUInteger outerPolygonPointCount = 0;
        
        NSMutableArray *innerPolygons = [NSMutableArray arrayWithCapacity:[coordinates count]];

        for (NSArray *polygon in polygonList) {
            if (polygon!=nil && [polygon count]>2) {
                CLLocationCoordinate2D *polygonCoordinates = [Boundary makeCLLocationCoordinate2DArrayFrom:polygon];
                if (index==0) {
                    outerPolygonCoordinates = polygonCoordinates;
                    outerPolygonPointCount = [polygon count];
                } else {
                    MKPolygon *innerPolygon = [MKPolygon polygonWithCoordinates:polygonCoordinates count:[polygon count]];
                    [innerPolygons addObject:innerPolygon];
                    free(polygonCoordinates);
                }
            }
            index++;
        }
        if (outerPolygonCoordinates==NULL) return nil;
        
        MKPolygon *polygon=nil;
        if ([innerPolygons count]==0) {
            polygon = [MKPolygon polygonWithCoordinates:outerPolygonCoordinates count:outerPolygonPointCount];
        } else {
            polygon = [MKPolygon polygonWithCoordinates:outerPolygonCoordinates count:outerPolygonPointCount interiorPolygons:innerPolygons];
        }
        free(outerPolygonCoordinates);
        
        BoundaryPolygon *boundaryPolygon = [[BoundaryPolygon alloc] init];
        boundaryPolygon.boundary=nil;
        boundaryPolygon.polygon=polygon;
        [multiPolygons addObject:boundaryPolygon];
    }

    // Obtain district name from GeoJSON data
    NSDictionary *boundary_dictionary = boundaryServiceDictionary;
    NSDictionary *district_properties = [boundary_dictionary objectForKey:@"properties"];
    NSString *district_name = [district_properties objectForKey:@"DISTRICT"];
    
    Boundary *boundary = [[Boundary alloc] initWithPolygons:multiPolygons
                          name:district_name
                          type:districtType
                          metadata:nil
                          set:nil
                          ];

    return [boundary autorelease];
}


-(NSDictionary *) metadata {
    return _metadata;
}


- (void)dealloc
{
    [_color release];
    [_set release];
    [_polygons release];
    [_metadata release];
    [_name release];
    [_type release];
    [super dealloc];
}

@end
