//
//  Committee.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/30/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Committee : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *members;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *dow;
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *room;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *website;

@end
