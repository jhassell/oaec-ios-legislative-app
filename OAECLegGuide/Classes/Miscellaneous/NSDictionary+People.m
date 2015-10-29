//
//  NSDictionary+People.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/27/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "NSDictionary+People.h"
#import "AppDelegate.h"
#import "NSString+Stuff.h"

@implementation NSDictionary (People)

-(NSString *) type {
    return [self objectForKey:@"Type"];
}

-(NSString *) photo {
    return [self objectForKey:@"Photo"];
}

-(NSString *) lastName {
    return [self objectForKey:@"Last Name"];
}

-(NSString *) firstName {
    return [self objectForKey:@"First Name"];
}

-(NSString *) districtNumber {
    return [self objectForKey:@"District #"];
}

-(NSString *) party {
    return [self objectForKey:@"Party"];
}

-(NSString *) titleLeadership {
    return [self objectForKey:@"Title/leadership"];
}

-(NSString *) email {
    return [self objectForKey:@"E-mail"];
}

-(NSString *) webpage {
    return [self objectForKey:@"Website"];
}

-(NSString *) twitter {
    return [self objectForKey:@"Twitter"];
}

-(NSString *) facebook {
    return [self objectForKey:@"Facebook"];
}

-(NSString *) linkedIn {
    return [self objectForKey:@"LinkedIn"];
}

-(NSString *) termLimit {
    return [self objectForKey:@"Term limit"];
}

-(NSString *) countiesCovered {
    return [self objectForKey:@"Counties covered"];
}

-(NSString *) standingCommittee {
    return [self objectForKey:@"Standing Committee"];
}

-(NSString *) appropriationsSubcommittee {
    return [self objectForKey:@"Appropriations Subcommittee"];
}

-(NSString *) officeAddress {
    return [self objectForKey:@"Office address"];
}

-(NSString *) officeCity {
    return [self objectForKey:@"Office city"];
}

-(NSString *) officeState {
    return [self objectForKey:@"Office state"];
}

-(NSString *) officeZip {
    return [self objectForKey:@"Office zip"];
}

-(NSString *) officeRmNumber {
    return [self objectForKey:@"Office Rm #"];
}

-(NSString *) officePhone {
    return [self objectForKey:@"Office phone"];
}

-(NSString *) homeAddress {
    return [self objectForKey:@"Home address"];
}

-(NSString *) homeCity {
    return [self objectForKey:@"Home city"];
}

-(NSString *) homeState {
    return [self objectForKey:@"Home state"];
}

-(NSString *) homeZip {
    return [self objectForKey:@"Home zip"];
}

-(NSString *) districtPhone {
    return [self objectForKey:@"District Phone"];
}

-(NSString *) laName {
    return [self objectForKey:@"LA name"];
}

-(NSString *) predecessor {
    return [self objectForKey:@"Predecessor"];
}

-(NSMutableArray *) committees {
    return [self objectForKey:@"Committees"];
}

-(NSString *) coopName {
    return [self objectForKey:@"Cooperative Name"];
}

-(NSString *) coopLogoFilename {
    return [self objectForKey:@"Cooperative Logo Filename"];
}

-(NSString *) milesOfLines {
    return [self objectForKey:@"Miles of Line"];
}

-(NSString *) activeMeters {
    return [self objectForKey:@"Active Meters"];
}

-(NSString *) employees {
    return [self objectForKey:@"Employees"];
}

-(NSString *) activeMetersMiles {
    return [self objectForKey:@"Active Meters/Mile"];
}

-(NSString *) coopType {
    return [self objectForKey:@"Co-op Type"];
}

-(NSString *) coopRegionName {
    return [self objectForKey:@"Co-op Region Name"];
}

-(NSString *) formattedFullNameWithTitle {
    
    NSString *prefix=@"";
    NSString *office=@"";
    NSString *title=@"";
    NSString *partyAndDistrict=@"";
    NSString *personTitle=@"";
    NSString *districtNumber = nil;
    
    if ([self.type isEqualToString:STATE_HOUSE]) {
        prefix = @"Rep. ";
        office=@"Oklahoma Representative";
        title=self.titleLeadership;
        partyAndDistrict = [NSString stringWithFormat:@"State House District %@",self.districtNumber ];
        personTitle=partyAndDistrict;
        districtNumber = [NSString stringWithFormat:@"%03i",[self.districtNumber intValue]];
    } else if ([self.type isEqualToString:STATE_SENATE]) {
        prefix = @"Sen. ";
        office=@"Oklahoma Senator";
        title=self.titleLeadership;
        partyAndDistrict = [NSString stringWithFormat:@"State Senate District %@",self.districtNumber ];
        personTitle=partyAndDistrict;
        districtNumber = [NSString stringWithFormat:@"%03i",[self.districtNumber intValue]];
    } else if ([self.type isEqualToString:STATEWIDE]) {
        office=self.titleLeadership;
        partyAndDistrict = self.party;
        personTitle=[NSString stringWithFormat:@"%@ (%@)",office,self.party];
    } else if ([self.type isEqualToString:FEDERAL_HOUSE]) {
        prefix = @"Rep. ";
        office = @"US Representative";
        title = self.titleLeadership;
        partyAndDistrict = [NSString stringWithFormat:@"US House District %@",self.districtNumber ];
        personTitle=partyAndDistrict;
        districtNumber = [NSString stringWithFormat:@"%02i",[self.districtNumber intValue]];
    } else if ([self.type isEqualToString:FEDERAL_SENATE]) {
        prefix = @"Sen. ";
        office = @"US Senator";
        title = self.titleLeadership;
        partyAndDistrict = self.party;
        personTitle=partyAndDistrict;
    } else if ([self.type isEqualToString:STATE_JUDICIARY]) {
        prefix = @"Sen. ";
        office = @"US Senator";
        title = self.titleLeadership;
        partyAndDistrict = self.party;
        personTitle=partyAndDistrict;
    } else if ([self.type isEqualToString:OAEC_MEMBER]) {
        personTitle = self.titleLeadership;
    }
    
    NSString *returnString = nil;
    
    if ([@"VACANT" caseInsensitiveCompare:[self.firstName trim]]==NSOrderedSame) {
        returnString = @"Seat Vacant";
    } else {
        returnString = [NSString stringWithFormat:@"%@%@ %@%@",prefix,self.firstName,self.lastName,
                        ((self.party==nil || [[self.party trim] length]==0)?@"":[NSString stringWithFormat:@" (%@)",self.party ])];
    }
    
    return returnString;
    
}


-(UIColor *) partyColor {
    if ([self.party isEqualToString:@"R"]) {
        return [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
    } else if ([self.party isEqualToString:@"D"]) {
        return [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5];
    } else {
        return [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
    }
}

-(int) sortOrder {
    return [[self objectForKey:@"Sort Order"] intValue];
}

@end
