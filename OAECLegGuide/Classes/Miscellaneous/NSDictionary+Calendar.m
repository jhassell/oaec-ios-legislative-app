//
//  NSDictionary+Calendar.m
//  LegGuide
//
//  Created by Matt Galloway on 11/24/13.
//  Copyright (c) 2013 Architactile LLC. All rights reserved.
//

#import "NSDictionary+Calendar.h"

@implementation NSDictionary (Calendar)

-(NSDate *) date {
    return [self objectForKey:@"Date"];
}

-(NSString *) details {
    return [self objectForKey:@"Details"];
}

@end
