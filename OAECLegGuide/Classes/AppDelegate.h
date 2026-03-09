//
//  AppDelegate.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/21/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define STATE_SENATE    @"Oklahoma Senate"
#define STATE_HOUSE     @"Oklahoma House"
#define STATE_JUDICIARY @"Oklahoma Judiciary"
#define FEDERAL_SENATE  @"US Senate"
#define FEDERAL_HOUSE   @"US House"
#define STATEWIDE       @"Statewide"
#define OAEC_MEMBER    @"OAEC Member System"
#define LEGISLATIVE_CONTACT @"OAEC Contact"

#define STANDING        @"Standing Committee"
#define APPROPRIATIONS  @"Appropriations Subcommittee"
#define CAEDOCOMMITTEES @"Commerce & Economic Development Oversight Committees"
#define EOCOMMITTEES    @"Education Oversight Committees"
#define GOCOMMITTEES    @"Government Oversight Committees"
#define HHSOCOMMITTEES  @"Health & Human Services Oversight Committees"
#define ENROCOMMITTEES  @"Energy & Natural Resources Oversight Committees"
#define JPSCOMMITTEES   @"Judiciary & Public Safety Oversight Committees"

extern NSString * const OAECSpreadsheetDataDidReloadNotification;



@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    BOOL mapDataLoaded;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSArray *all; 
@property (nonatomic, strong) NSArray *stateSenate; 
@property (nonatomic, strong) NSArray *stateHouse; 
@property (nonatomic, strong) NSArray *federalSenate; 
@property (nonatomic, strong) NSArray *federalHouse; 
@property (nonatomic, strong) NSArray *statewide; 
@property (nonatomic, strong) NSArray *oaecMembers;
@property (nonatomic, strong) NSArray *legislativeContacts;
@property (nonatomic, strong) NSArray *stateJudiciary;

@property (nonatomic, strong) NSArray *calendar;

@property (nonatomic, strong) NSArray *stateSenateStandingCommittees; 
@property (nonatomic, strong) NSArray *stateHouseStandingCommittees; 
@property (nonatomic, strong) NSArray *stateSenateCAEDOCommittees;
@property (nonatomic, strong) NSArray *stateHouseCAEDOCommittees;
@property (nonatomic, strong) NSArray *stateSenateEducationOversightCommittees;
@property (nonatomic, strong) NSArray *stateHouseEducationOversightCommittees;
@property (nonatomic, strong) NSArray *stateSenateGovernmentOversightCommittees;
@property (nonatomic, strong) NSArray *stateHouseGovernmentOversightCommittees;
@property (nonatomic, strong) NSArray *stateSenateHealthOversightCommittees;
@property (nonatomic, strong) NSArray *stateHouseHealthOversightCommittees;
@property (nonatomic, strong) NSArray *stateSenateEnergyOversightCommittees;
@property (nonatomic, strong) NSArray *stateHouseEnergyOversightCommittees;
@property (nonatomic, strong) NSArray *stateSenateJudiciaryOversightCommittees;
@property (nonatomic, strong) NSArray *stateHouseJudiciaryOversightCommittees;

@property (nonatomic, strong) NSArray *stateSenateAppropriationsSubcommittees;
@property (nonatomic, strong) NSArray *stateHouseAppropriationsSubcommittees;

@property (nonatomic, strong) NSDictionary *countyBoundaries;
@property (nonatomic, strong) NSDictionary *municipalBoundaries;
@property (nonatomic, strong) NSDictionary *congressionalBoundaries;
@property (nonatomic, strong) NSDictionary *stateSenateBoundaries;
@property (nonatomic, strong) NSDictionary *stateHouseBoundaries;
@property (nonatomic, strong) NSDictionary *coopBoundaries;

@property (nonatomic, strong) UIAlertController *alertView;

-(void) loadBoundaries;
-(void) weblink;

@end
