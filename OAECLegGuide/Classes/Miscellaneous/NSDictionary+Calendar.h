//
//  NSDictionary+Calendar.h
//  LegGuide
//
//  Created by Matt Galloway on 11/24/13.
//  Copyright (c) 2013 Architactile LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Calendar)

@property (readonly) NSDate *date;
@property (readonly) NSString *details;

@end
