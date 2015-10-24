//
//  Committee.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/30/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "Committee.h"

@implementation Committee

@synthesize name=_name;
@synthesize members=_members;
@synthesize body=_body;
@synthesize type=_type;
@synthesize website=_website;

- (id)init
{
    self = [super init];
    if (self) {
        self.members = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void)dealloc
{
    [_name release];
    [_members release];
    [_body release];
    [_type release];
    [_website release];
    [super dealloc];
}

@end
