//
//  CommitteeMember.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/30/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "CommitteeMember.h"

@implementation CommitteeMember

@synthesize person=_person;
@synthesize title=_title;
@synthesize sortTitle=_sortTitle;
@synthesize committee=_committee;

- (void)dealloc
{
    [_person release];
    [_committee release];
    [_title release];
    [_sortTitle release];
    [super dealloc];
}

@end
