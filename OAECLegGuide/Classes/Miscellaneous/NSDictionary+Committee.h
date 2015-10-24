//
//  NSDictionary+Committee.h
//  LegGuide
//
//  Created by Matt Galloway on 1/26/14.
//  Copyright (c) 2014 Architactile LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Committee)

@property (readonly) NSString *committeeChamber;
@property (readonly) NSString *committeeName;
@property (readonly) NSString *committeeDOW;
@property (readonly) NSString *committeeTime;
@property (readonly) NSString *committeeRoom;
@property (readonly) NSString *committeeWebsite;

@end
