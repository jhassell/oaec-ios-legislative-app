//
//  NSDictionary+People.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/27/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (People)

@property (readonly) NSString *type;
@property (readonly) NSString *photo;
@property (readonly) NSString *lastName;
@property (readonly) NSString *firstName;
@property (readonly) NSString *districtNumber;
@property (readonly) NSString *party;
@property (readonly) NSString *titleLeadership;
@property (readonly) NSString *email;
@property (readonly) NSString *webpage;
@property (readonly) NSString *twitter;
@property (readonly) NSString *facebook;
@property (readonly) NSString *linkedIn;
@property (readonly) NSString *termLimit;
@property (readonly) NSString *countiesCovered;
@property (readonly) NSString *standingCommittee;
@property (readonly) NSString *appropriationsSubcommittee;
@property (readonly) NSString *officeAddress;
@property (readonly) NSString *officeCity;
@property (readonly) NSString *officeState;
@property (readonly) NSString *officeZip;
@property (readonly) NSString *officeRmNumber;
@property (readonly) NSString *officePhone;
@property (readonly) NSString *homeAddress;
@property (readonly) NSString *homeCity;
@property (readonly) NSString *homeState;
@property (readonly) NSString *homeZip;
@property (readonly) NSString *districtPhone;
@property (readonly) NSString *laName;
@property (readonly) NSString *laEmail;
@property (readonly) NSString *predecessor;
@property (readonly) NSMutableArray *committees;

@property (readonly) NSString *coopName;
@property (readonly) NSString *coopLogoFilename;
@property (readonly) NSString *milesOfLines;
@property (readonly) NSString *activeMeters;
@property (readonly) NSString *employees;
@property (readonly) NSString *activeMetersMiles;
@property (readonly) NSString *coopType;
@property (readonly) NSString *coopRegionName;
@property (readonly) NSString *formattedFullNameWithTitle;
@property (readonly) UIColor *partyColor;


@property (readonly) int sortOrder;


@end
