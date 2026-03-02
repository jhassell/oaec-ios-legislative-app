//
//  AppDelegate.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/21/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "DataLoader.h"
#import "Boundary.h"
#import "ModalAlert.h"
#import "NSDictionary+People.h"
#import "NSString+Stuff.h"
#import "Committee.h"
#import "NSDictionary+Committee.h"
#import <UserNotifications/UserNotifications.h>
#import "AFURLSessionManager.h"
#import "SSZipArchive.h"
#import <PushwooshFramework/PushwooshFramework.h>


@implementation AppDelegate

@synthesize window = _window;


@synthesize all=_all; 
@synthesize stateSenate=_stateSenate; 
@synthesize stateHouse=_stateHouse;
@synthesize stateJudiciary=_stateJudiciary;
@synthesize federalSenate=_federalSenate;
@synthesize federalHouse=_federalHouse; 
@synthesize statewide=_statewide;
@synthesize oaecMembers=_oaecMembers;
@synthesize legislativeContacts=_legislativeContacts;
@synthesize calendar=_calendar;

@synthesize stateSenateStandingCommittees=_stateSenateStandingCommittees;
@synthesize stateHouseStandingCommittees=_stateHouseStandingCommittees;
@synthesize stateSenateCAEDOCommittees=_stateSenateCAEDOCommittees;
@synthesize stateHouseCAEDOCommittees=_stateHouseCAEDOCommittees;
@synthesize stateSenateEducationOversightCommittees=_stateSenateEducationOversightCommittees;
@synthesize stateHouseEducationOversightCommittees=_stateHouseEducationOversightCommittees;
@synthesize stateSenateGovernmentOversightCommittees=_stateSenateGovernmentOversightCommittees;
@synthesize stateHouseGovernmentOversightCommittees=_stateHouseGovernmentOversightCommittees;
@synthesize stateSenateHealthOversightCommittees=_stateSenateHealthOversightCommittees;
@synthesize stateHouseHealthOversightCommittees=_stateHouseHealthOversightCommittees;
@synthesize stateSenateEnergyOversightCommittees=_stateSenateEnergyOversightCommittees;
@synthesize stateHouseEnergyOversightCommittees=_stateHouseEnergyOversightCommittees;
@synthesize stateSenateJudiciaryOversightCommittees=_stateSenateJudiciaryOversightCommittees;
@synthesize stateHouseJudiciaryOversightCommittees=_stateHouseJudiciaryOversightCommittees;

@synthesize stateSenateAppropriationsSubcommittees=_stateSenateAppropriationsSubcommittees;
@synthesize stateHouseAppropriationsSubcommittees=_stateHouseAppropriationsSubcommittees;
@synthesize countyBoundaries=_countyBoundaries;
@synthesize municipalBoundaries=_municipalBoundaries;
@synthesize congressionalBoundaries=_congressionalBoundaries;
@synthesize stateSenateBoundaries=_stateSenateBoundaries;
@synthesize stateHouseBoundaries=_stateHouseBoundaries;
@synthesize coopBoundaries=_coopBoundaries;
@synthesize alertView=_alertView;

- (void)weblink {
    NSURL *url = [NSURL URLWithString:@"http://www.oaec.coop"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            if (!success) {
                NSLog(@"Failed to open URL: %@", url.absoluteString);
            }
        }];
    } else {
        NSLog(@"Cannot open URL: %@", url.absoluteString);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //-----------PUSHWOOSH PART-----------
    // set custom delegate for push handling, in our case AppDelegate
    [Pushwoosh sharedInstance].delegate = self;
    //register for push notifications!
    [[Pushwoosh sharedInstance] registerForPushNotifications];

    NSLog(@"finish load");
    return YES;
}

//handle token received from APNS
- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[Pushwoosh sharedInstance] handlePushRegistration:deviceToken];
}

//handle token receiving error
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[Pushwoosh sharedInstance] handlePushRegistrationFailure:error];
}
//this is for iOS < 10 and for silent push notifications
- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
        [[Pushwoosh sharedInstance] handlePushReceived:userInfo];
        completionHandler(UIBackgroundFetchResultNoData);
}
//this event is fired when the push gets received
- (void)pushwoosh:(Pushwoosh *)pushwoosh onMessageReceived:(PWMessage *)message {
    NSLog(@"onMessageReceived: %@", message.payload);
}
//this event is fired when user taps the notification
- (void)pushwoosh:(Pushwoosh *)pushwoosh onMessageOpened:(PWMessage *)message {
    NSLog(@"onMessageOpened: %@", message.payload);
}


- (void)downloadImmediateData {
    [self downloadSpreadsheet];
    [self downloadCalendar];
    [self downloadPhotosZipFile];
}

- (void)populateSpreadsheetData {
    
    NSLog(@"start load");
    
    self.stateSenate   = [self.all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Type=%@",STATE_SENATE]];
    self.stateHouse    = [self.all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Type=%@",STATE_HOUSE]];
    self.stateJudiciary = [self.all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Type=%@",STATE_JUDICIARY]];
     self.federalSenate = [self.all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Type=%@",FEDERAL_SENATE]];
    self.federalHouse  = [self.all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Type=%@",FEDERAL_HOUSE]];
    self.statewide     = [self.all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Type=%@",STATEWIDE]];
    self.oaecMembers     = [self.all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Type=%@",OAEC_MEMBER]];
    self.legislativeContacts = [self.all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Type=%@",LEGISLATIVE_CONTACT]];

    // alpha order senate, house
    
    NSSortDescriptor *sortByLastName = [[[NSSortDescriptor alloc] initWithKey:@"Last Name" ascending:YES] autorelease];
    NSSortDescriptor *sortByFirstName = [[[NSSortDescriptor alloc] initWithKey:@"First Name" ascending:YES] autorelease];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortByLastName,sortByFirstName, nil];
    
    self.stateSenate = [self.stateSenate sortedArrayUsingDescriptors:sortDescriptors];
    self.stateHouse = [self.stateHouse sortedArrayUsingDescriptors:sortDescriptors];


    
    
    // Resort State Judiciary by sort order, then contact name
    
    NSSortDescriptor *sortOrderSort = [NSSortDescriptor sortDescriptorWithKey:@"Sort Order Number" ascending:YES];
    NSSortDescriptor *lastNameSort = [NSSortDescriptor sortDescriptorWithKey:@"Last Name" ascending:YES];
    NSSortDescriptor *firstNameSort = [NSSortDescriptor sortDescriptorWithKey:@"First Name" ascending:YES];
    sortDescriptors = [NSArray arrayWithObjects:sortOrderSort,lastNameSort,firstNameSort,nil];
    self.stateJudiciary = [self.stateJudiciary sortedArrayUsingDescriptors:sortDescriptors];
   

    
    
    NSLog(@"all count %lu",(unsigned long)[self.all count]);
    NSLog(@"state senate count %lu",(unsigned long)[self.stateSenate count]);
    NSLog(@"state judiciary count %lu",(unsigned long)[self.stateJudiciary count]);
    
    self.stateSenateStandingCommittees = [DataLoader buildCommitteesFromPeople:self.stateSenate committeeKey:STANDING];
    self.stateHouseStandingCommittees  = [DataLoader buildCommitteesFromPeople:self.stateHouse committeeKey:STANDING];
    self.stateSenateCAEDOCommittees =[DataLoader buildCommitteesFromPeople:self.stateSenate committeeKey:CAEDOCOMMITTEES];
    self.stateHouseCAEDOCommittees =[DataLoader buildCommitteesFromPeople:self.stateHouse committeeKey:CAEDOCOMMITTEES];
   
    
    self.stateSenateEducationOversightCommittees=[DataLoader buildCommitteesFromPeople:self.stateSenate committeeKey:EOCOMMITTEES];
    self.stateHouseEducationOversightCommittees=[DataLoader buildCommitteesFromPeople:self.stateHouse committeeKey:EOCOMMITTEES];
    self.stateSenateGovernmentOversightCommittees=[DataLoader buildCommitteesFromPeople:self.stateSenate committeeKey:GOCOMMITTEES];
    self.stateHouseGovernmentOversightCommittees=[DataLoader buildCommitteesFromPeople:self.stateHouse committeeKey:GOCOMMITTEES];
    self.stateSenateHealthOversightCommittees=[DataLoader buildCommitteesFromPeople:self.stateSenate committeeKey:HHSOCOMMITTEES];
    self.stateHouseHealthOversightCommittees=[DataLoader buildCommitteesFromPeople:self.stateHouse committeeKey:HHSOCOMMITTEES];
    self.stateSenateEnergyOversightCommittees=[DataLoader buildCommitteesFromPeople:self.stateSenate committeeKey:ENROCOMMITTEES];
    self.stateHouseEnergyOversightCommittees=[DataLoader buildCommitteesFromPeople:self.stateHouse committeeKey:ENROCOMMITTEES];
    self.stateSenateJudiciaryOversightCommittees=[DataLoader buildCommitteesFromPeople:self.stateSenate committeeKey:JPSCOMMITTEES];
    self.stateHouseJudiciaryOversightCommittees=[DataLoader buildCommitteesFromPeople:self.stateHouse committeeKey:JPSCOMMITTEES];
                                                 
    self.stateSenateAppropriationsSubcommittees  = [DataLoader buildCommitteesFromPeople:self.stateSenate committeeKey:APPROPRIATIONS];
    self.stateHouseAppropriationsSubcommittees = [DataLoader buildCommitteesFromPeople:self.stateHouse committeeKey:APPROPRIATIONS];


    
    // Resort OAEC Member Systems by company name then contact name
    NSSortDescriptor *companySort = [NSSortDescriptor sortDescriptorWithKey:@"Cooperative Name" ascending:YES];
    sortDescriptors = [NSArray arrayWithObjects:sortOrderSort,companySort,lastNameSort,firstNameSort,nil];
    self.oaecMembers = [self.oaecMembers sortedArrayUsingDescriptors:sortDescriptors];
    
    NSMutableArray *allCommittees = [NSMutableArray arrayWithCapacity:self.stateSenateStandingCommittees.count+
                                     self.stateHouseStandingCommittees.count+
                                     self.stateSenateCAEDOCommittees.count+
                                     self.stateHouseCAEDOCommittees.count+
                                     self.stateSenateStandingCommittees.count+
                                     self.stateHouseStandingCommittees.count+
                                     self.stateSenateCAEDOCommittees.count+
                                     self.stateHouseCAEDOCommittees.count+
                                     self.stateSenateEducationOversightCommittees.count+
                                     self.stateHouseEducationOversightCommittees.count+
                                     self.stateSenateGovernmentOversightCommittees.count+
                                     self.stateHouseGovernmentOversightCommittees.count+
                                     self.stateSenateHealthOversightCommittees.count+
                                     self.stateHouseHealthOversightCommittees.count+
                                     self.stateSenateEnergyOversightCommittees.count+
                                     self.stateHouseEnergyOversightCommittees.count+
                                     self.stateSenateJudiciaryOversightCommittees.count+
                                     self.stateHouseJudiciaryOversightCommittees.count+
                                     self.stateSenateAppropriationsSubcommittees.count+
                                     self.stateHouseAppropriationsSubcommittees.count];
    
    [allCommittees addObjectsFromArray:self.stateSenateStandingCommittees];
    [allCommittees addObjectsFromArray:self.stateHouseStandingCommittees];
    [allCommittees addObjectsFromArray:self.stateSenateCAEDOCommittees];
    [allCommittees addObjectsFromArray:self.stateHouseCAEDOCommittees];
    [allCommittees addObjectsFromArray:self.stateSenateEducationOversightCommittees];
    [allCommittees addObjectsFromArray:self.stateHouseEducationOversightCommittees];
    [allCommittees addObjectsFromArray:self.stateSenateGovernmentOversightCommittees];
    [allCommittees addObjectsFromArray:self.stateHouseGovernmentOversightCommittees];
    [allCommittees addObjectsFromArray:self.stateSenateHealthOversightCommittees];
    [allCommittees addObjectsFromArray:self.stateHouseHealthOversightCommittees];
    [allCommittees addObjectsFromArray:self.stateSenateEnergyOversightCommittees];
    [allCommittees addObjectsFromArray:self.stateHouseEnergyOversightCommittees];
    [allCommittees addObjectsFromArray:self.stateSenateJudiciaryOversightCommittees];
    [allCommittees addObjectsFromArray:self.stateHouseJudiciaryOversightCommittees];
    [allCommittees addObjectsFromArray:self.stateSenateAppropriationsSubcommittees];
    [allCommittees addObjectsFromArray:self.stateHouseAppropriationsSubcommittees];
    //[allCommittees addObjectsFromArray:self.stateSenateAppropriationsSubcommittees];
    //[allCommittees addObjectsFromArray:self.stateHouseAppropriationsSubcommittees];
    
    NSMutableDictionary *committeeLookup = [NSMutableDictionary dictionaryWithCapacity:allCommittees.count];
    for (Committee *committee in allCommittees) {
        committee.key = [[NSString stringWithFormat:@"%@:%@",[committee.body trim],[committee.name trim]] lowercaseString];
        //NSLog(@"name: %@  body: %@ type: %@",committee.name,committee.body,committee.type);
        NSLog(@"Committee key: *%@*",committee.key);
        [committeeLookup setObject:committee forKey:committee.key];
    }
    
    NSString *dataFilename = [[NSBundle mainBundle] pathForResource:@"committees" ofType:@"csv"];
    
    NSArray *committeesMetaData = [DataLoader loadCSVFile:dataFilename];
    
    for (NSDictionary *committeeDict in committeesMetaData) {
        
        NSString *key = [[NSString stringWithFormat:@"%@:%@",[committeeDict.committeeChamber trim],[committeeDict.committeeName trim]] lowercaseString];
        
        Committee *committee = [committeeLookup objectForKey:key];
        
        if (committee!=nil) {
            
            NSLog(@"committee.name = %@ -> %@",committee.name,committeeDict.committeeName);
            committee.room=committeeDict.committeeRoom;
            committee.time=committeeDict.committeeTime;
            committee.dow=committeeDict.committeeDOW;
            committee.website=committeeDict.committeeWebsite;
            NSLog(@"%@ %@ %@",committee.room,committee.time,committee.dow);
        } else {
            NSLog(@"Committee NOT FOUND: %@",key);
        }
    }

    
    
    NSLog(@"finish load");

}



- (void)downloadSpreadsheet {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirPaths;
    NSString *docsDir;
    
    
    NSURL *URL = [NSURL URLWithString:@"https://www.dropbox.com/s/1f6ymjx2mjq0wn6/data58.csv?raw=1"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                   NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSString *csvFilename = [NSString stringWithFormat:@"%@/%@", docsDir, @"data58.csv"];
    if ([fileManager fileExistsAtPath:csvFilename ] == YES)
    {
        NSError *error;
        [fileManager removeItemAtPath:csvFilename error:&error];
        NSLog (@"File deleted");
    }
    else
    {
        NSLog (@"File not found");
    }
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        mapDataLoaded = NO;
        NSString *harddataFilename = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"csv"];
        NSString *previousDataFilename = [NSString stringWithFormat:@"%@/%@", docsDir, @"previousdata.csv"];
        NSString *csvFilename = [NSString stringWithFormat:@"%@/%@", docsDir, @"data58.csv"];
        if ([fileManager fileExistsAtPath:csvFilename] == YES) {
            // Load from recently downloaded csvFilename
            self.all = [DataLoader loadCSVFile:csvFilename];
            // Remove previousDataFilename
            [fileManager removeItemAtPath:previousDataFilename error:&error];
            // Copy recently downloaded csvFilename to previousDataFilename
            [fileManager copyItemAtPath:csvFilename toPath:previousDataFilename error:&error];
            // Remove csvFilename in preparation for next download
            [fileManager removeItemAtPath:csvFilename error:&error];
        } else if ([fileManager fileExistsAtPath:previousDataFilename]) {
            self.all = [DataLoader loadCSVFile:previousDataFilename];
        } else {
            self.all = [DataLoader loadCSVFile:harddataFilename];
        }
        [self populateSpreadsheetData];
    }];
    [downloadTask resume];
    
}


- (void)downloadCalendar {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                   NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    // Download calendar
    NSURL *CALENDAR_URL = [NSURL URLWithString:@"https://www.dropbox.com/s/hp0z3dgq5ajjenw/calendar58.csv?raw=1"];
    NSURLRequest *calendar_request = [NSURLRequest requestWithURL:CALENDAR_URL];
    
    NSString *calendarFilename = [NSString stringWithFormat:@"%@/%@", docsDir, @"calendar58.csv"];
    if ([fileManager fileExistsAtPath:calendarFilename ] == YES)
    {
        NSError *error;
        [fileManager removeItemAtPath:calendarFilename error:&error];
        NSLog (@"File deleted");
    }
    else
    {
        NSLog (@"File not found");
    }
    
    NSURLSessionDownloadTask *calendarDownloadTask = [manager downloadTaskWithRequest:calendar_request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSString *hardcalendarFilename = [[NSBundle mainBundle] pathForResource:@"calendar" ofType:@"csv"];
        NSString *previousCalendarFilename = [NSString stringWithFormat:@"%@/%@", docsDir, @"previouscalendar.csv"];
        NSString *calendarFilename = [NSString stringWithFormat:@"%@/%@", docsDir, @"calendar58.csv"];
        if ([fileManager fileExistsAtPath:calendarFilename] == YES) {
            // Load from recently downloaded csvFilename
            self.calendar = [DataLoader loadCalendarCSVFile:calendarFilename];
            // Remove previousDataFilename
            [fileManager removeItemAtPath:previousCalendarFilename error:&error];
            // Copy recently downloaded csvFilename to previousDataFilename
            [fileManager copyItemAtPath:calendarFilename toPath:previousCalendarFilename error:&error];
            // Remove csvFilename in preparation for next download
            [fileManager removeItemAtPath:calendarFilename error:&error];
        } else if ([fileManager fileExistsAtPath:previousCalendarFilename]) {
            self.calendar = [DataLoader loadCalendarCSVFile:previousCalendarFilename];
        } else {
            self.calendar = [DataLoader loadCalendarCSVFile:hardcalendarFilename];
        }
        
    }];
    [calendarDownloadTask resume];

}


- (void)downloadPhotosZipFile {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                   NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    // Download photos
    NSURL *PHOTOS_URL = [NSURL URLWithString:@"https://www.dropbox.com/s/9cl4vth7q57qpt6/photos58.zip?raw=1"];
    
    NSURLRequest *photo_file_request = [NSURLRequest requestWithURL:PHOTOS_URL];
    
    NSString *photosFilename = [NSString stringWithFormat:@"%@/%@", docsDir, @"photos58.zip"];
    if ([fileManager fileExistsAtPath:photosFilename ] == YES)
    {
        NSError *error;
        [fileManager removeItemAtPath:photosFilename error:&error];
        NSLog (@"File deleted");
    }
    else
    {
        NSLog (@"File not found");
    }
    
    NSURLSessionDownloadTask *photosDownloadTask = [manager downloadTaskWithRequest:photo_file_request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSString *hardphotosFilename = [[NSBundle mainBundle] pathForResource:@"photos" ofType:@"zip"];
        NSString *previousPhotosFilename = [NSString stringWithFormat:@"%@/%@", docsDir, @"previousphotos.zip"];
        NSString *photosFilename = [NSString stringWithFormat:@"%@/%@", docsDir, @"photos58.zip"];
        if ([fileManager fileExistsAtPath:photosFilename] == YES) {
            // Load from recently downloaded csvFilename
            [DataLoader loadPhotosFile:photosFilename];
            // Remove previousDataFilename
            [fileManager removeItemAtPath:previousPhotosFilename error:&error];
            // Copy recently downloaded csvFilename to previousDataFilename
            [fileManager copyItemAtPath:photosFilename toPath:previousPhotosFilename error:&error];
            // Remove csvFilename in preparation for next download
            [fileManager removeItemAtPath:photosFilename error:&error];
        } else if ([fileManager fileExistsAtPath:previousPhotosFilename]) {
            [DataLoader loadPhotosFile:previousPhotosFilename];
        } else {
            [DataLoader loadPhotosFile:hardphotosFilename];
        }
        
    }];
    [photosDownloadTask resume];
    
}

-(void) realLoadBoundaries {
    NSLog(@"Load boundaries");
    
    self.countyBoundaries        = [Boundary buildBoundaryDictionaryWithJSONFile:[[NSBundle mainBundle] pathForResource:@"Counties" ofType:@"json"]]; // TULSA
    //self.municipalBoundaries     = [Boundary buildBoundaryDictionaryWithJSONFile:[[NSBundle mainBundle] pathForResource:@"Municipalities" ofType:@"json"]]; // Tulsa
    //self.congressionalBoundaries = [Boundary buildBoundaryDictionaryWithJSONFile:[[NSBundle mainBundle] pathForResource:@"CongressionalDistricts" ofType:@"json"]]; // 01
    self.congressionalBoundaries = [Boundary buildDistrictDictionaryWithGEOJSONFile:[[NSBundle mainBundle] pathForResource:@"Congress_Final_102621" ofType:@"json"] andDistrictType:@"Congressional District" ]; // 01

    //self.stateSenateBoundaries   = [Boundary buildBoundaryDictionaryWithJSONFile:[[NSBundle mainBundle] pathForResource:@"StateSenateDistricts" ofType:@"json"]];
    // self.stateSenateBoundaries   = [Boundary buildBoundaryDictionaryWithJSONFile:[[NSBundle mainBundle] pathForResource:@"Final_Senate_2021" ofType:@"json"]];

    self.stateSenateBoundaries   = [Boundary buildDistrictDictionaryWithGEOJSONFile:[[NSBundle mainBundle] pathForResource:@"Final_Senate_2021" ofType:@"json" ] andDistrictType:@"State Senate District" ];

    // self.stateHouseBoundaries    = [Boundary buildBoundaryDictionaryWithJSONFile:[[NSBundle mainBundle] pathForResource:@"StateHouseDistricts" ofType:@"json"]];
    self.stateHouseBoundaries    = [Boundary buildDistrictDictionaryWithGEOJSONFile:[[NSBundle mainBundle] pathForResource:@"House_Final_102621" ofType:@"json"] andDistrictType:@"State House District" ];

    self.coopBoundaries          = [Boundary buildBoundaryDictionaryWithJSONFile:[[NSBundle mainBundle] pathForResource:@"OAECRegions" ofType:@"json"]];
    
    NSLog(@"stop load");
    
    
    // Data Integrity Test
    
    if (/* DISABLES CODE */ (NO)) {
        
        for(NSDictionary *person in self.all) {
            
            NSDictionary *districtBoundaries=nil;
            NSString *districtNumber=nil;
            
            if ([person.type isEqualToString:STATE_HOUSE]) {
                districtNumber = [NSString stringWithFormat:@"%03i",[person.districtNumber intValue]];
                districtBoundaries=self.stateHouseBoundaries;
            } else if ([person.type isEqualToString:STATE_SENATE]) {
                districtNumber = [NSString stringWithFormat:@"%03i",[person.districtNumber intValue]];
                districtBoundaries=self.stateSenateBoundaries;
            } else if ([person.type isEqualToString:STATEWIDE]) {
            } else if ([person.type isEqualToString:FEDERAL_HOUSE]) {
                districtNumber = [NSString stringWithFormat:@"%02i",[person.districtNumber intValue]];
                districtBoundaries=self.congressionalBoundaries;
            } else if ([person.type isEqualToString:FEDERAL_SENATE]) {
            }   
            
            if (districtBoundaries!=nil) {
                Boundary *districtBoundary = [districtBoundaries objectForKey:districtNumber];
                if (districtBoundary==nil) {
                    NSLog(@"%@ %@ %@ District NOT found: %@",person.type,person.firstName,person.lastName,districtNumber);
                }
            }
            
            NSArray *counties = [person.countiesCovered componentsSeparatedByString:@"~"];
            for (NSString *county in counties) {
                Boundary *countyBoundary = [self.countyBoundaries objectForKey:[[county uppercaseString] trim]];
                if (county!=nil && [county length]>0 && countyBoundary==nil) {
                    NSLog(@"%@ %@ %@ County NOT found: %@",person.type,person.firstName,person.lastName,[[county uppercaseString] trim]);
                }
            }
        }
        
    }
    
    [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    self.alertView=nil;
}

-(void) loadBoundaries {
    if (mapDataLoaded) return;

    mapDataLoaded = YES;
    self.alertView = [ModalAlert noButtonAlertWithTitle:@"Loading Map Data" message:@"Please wait..."];
    [self performSelector:@selector(realLoadBoundaries) withObject:nil afterDelay:0.01];
}

-(void) displayMessage:(NSTimer *)theTimer {
    NSLog(@"Now?");
    if (!mapDataLoaded || self.alertView!=nil) return;
    
    
    NSLog(@"Fire!");
    [theTimer invalidate];
    
    NSString *messageTitle = [self.message objectAtIndex:0];
    NSString *messageText = [self.message objectAtIndex:1];
    NSString *messageURL = [self.message objectAtIndex:2];
    NSString *buttonText = [self.message objectAtIndex:3];
    
    NSString *button2Text = @"Cancel";
    
    if (messageText==nil || [messageText length]==0) {
        buttonText=nil;
        button2Text=@"Ok";
    }
    
    NSUInteger answer = [ModalAlert queryWith:messageText title:messageTitle button1:buttonText button2:button2Text];
    
    // NSLog(@"Answer == %i",answer);

    if (answer == 0 && buttonText != nil) {
        NSURL *url = [NSURL URLWithString:messageURL];
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                if (!success) {
                    NSLog(@"Failed to open URL: %@", url.absoluteString);
                }
            }];
        } else {
            NSLog(@"Cannot open URL: %@", url.absoluteString);
        }
    }
}



-(void) startTheTimer {
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(displayMessage:) userInfo:nil repeats:YES];
}

-(void) checkForUpdateMessage {
    
    NSLog(@"Check");
    
    
    NSString *filename = [NSString stringWithFormat:@"updatemessage.%@.json", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    NSString *stringURL = [NSString stringWithFormat:@"http://architactile.com/OAECMessage/%@/%@",[[NSBundle mainBundle] bundleIdentifier],filename];
    
    NSLog(@"Url = %@",stringURL);
    
    NSURL  *url = [NSURL URLWithString:stringURL];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:url];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger code = [httpResponse statusCode];
    
    if (code==200) {
        
        NSLog(@"Yulp.");
        error = nil;
        self.message = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        

        if (error == nil && self.message !=nil && [self.message count]==4) {
        
            NSLog(@"Yulp!");

            [self performSelectorOnMainThread:@selector(startTheTimer) withObject:nil waitUntilDone:NO];
        }
        
    }
}




- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    NSLog(@"Did become active");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        [self checkForUpdateMessage];
        [self downloadImmediateData];
    });
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)dealloc
{
 
    [_calendar release];
    [_countyBoundaries release];
    [_municipalBoundaries release];
    [_congressionalBoundaries release];
    [_stateSenateBoundaries release];
    [_stateHouseBoundaries release];
    [_coopBoundaries release];
    [_stateSenateStandingCommittees release]; 
    [_stateHouseStandingCommittees release];
    [_stateSenateCAEDOCommittees release];
    [_stateHouseCAEDOCommittees release];
    
    [_stateSenateEducationOversightCommittees release];
    [_stateHouseEducationOversightCommittees release];
    [_stateSenateGovernmentOversightCommittees release];
    [_stateHouseGovernmentOversightCommittees release];
    [_stateSenateHealthOversightCommittees release];
    [_stateHouseHealthOversightCommittees release];
    [_stateSenateEnergyOversightCommittees release];
    [_stateHouseEnergyOversightCommittees release];
    [_stateSenateJudiciaryOversightCommittees release];
    [_stateHouseJudiciaryOversightCommittees release];
    
    [_stateSenateAppropriationsSubcommittees release];
    [_stateHouseAppropriationsSubcommittees release];
    [_window release];
    [_all release];
    [_stateSenate release];
    [_stateHouse release];
    [_federalSenate release];
    [_federalHouse release];
    [_statewide release];
    [_oaecMembers release];
    [_legislativeContacts release];
    [_alertView release];
    
    [super dealloc];
}


@end
