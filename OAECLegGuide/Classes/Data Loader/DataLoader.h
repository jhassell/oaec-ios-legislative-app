//
//  DataLoader.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/26/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataLoader : NSObject

+(NSArray *) loadCSVFile:(NSString *) csvPath ;
+(NSArray *) buildCommitteesFromPeople:(NSArray *) people committeeKey:(NSString *) committeeKey;
+(NSArray *) loadCalendarCSVFile:(NSString *) csvPath;
+(void) loadPhotosFile:(NSString *) zipPath;


@end
