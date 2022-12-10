//
//  Address.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 8/3/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "LAAddress.h"
#import "NSString+Stuff.h"

@implementation LAAddress

@synthesize name=_name;
@synthesize address=_address;
@synthesize roomNumber=_roomNumber;
@synthesize city=_city;
@synthesize state=_state;
@synthesize zip=_zip;
@synthesize phone=_phone;
@synthesize email=_email;


-(BOOL) isEmpty {
    
    BOOL retVal = YES;
    
    if (![NSString isBlankOrNil:self.address ]) retVal=NO;
    if (![NSString isBlankOrNil:self.city]) retVal=NO;
    if (![NSString isBlankOrNil:self.state]) retVal=NO;
    if (![NSString isBlankOrNil:self.zip]) retVal=NO;
    if (![NSString isBlankOrNil:self.roomNumber]) retVal=NO;
    if (![NSString isBlankOrNil:self.phone]) retVal=NO;
    
    return retVal;
}


- (void)dealloc
{
    [_name release];
    [_address release];
    [_roomNumber release];
    [_city release];
    [_state release];
    [_zip release];
    [_phone release];
    [_email release];
    [super dealloc];
}

@end
