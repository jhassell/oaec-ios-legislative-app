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
#import "Definitions.h"
#import "NSDictionary+People.h"
#import "NSString+Stuff.h"
#import "Committee.h"
#import "NSDictionary+Committee.h"
#import <UserNotifications/UserNotifications.h>
#import "SSZipArchive.h"
#if __has_feature(modules)
@import PushwooshFramework;
#elif __has_include(<PushwooshFramework/PushwooshFramework.h>)
#import <PushwooshFramework/PushwooshFramework.h>
#elif __has_include("PushwooshFramework.h")
#import "PushwooshFramework.h"
#elif __has_include(<PushwooshFramework.h>)
#import <PushwooshFramework.h>
#endif

NSString * const OAECSpreadsheetDataDidReloadNotification = @"OAECSpreadsheetDataDidReloadNotification";

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

static void OpenExternalURLWithLogging(NSURL *url) {
    if (url == nil) return;
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
        if (!success) NSLog(@"[OAEC][URL] Failed to open: %@", [url description]);
    }];
}

- (UIViewController *)topPresentedViewController {
    UIViewController *vc = self.window.rootViewController;
    while (vc.presentedViewController != nil) vc = vc.presentedViewController;
    return vc;
}

- (void)presentLoadingAlert {
    UIViewController *presenter = [self topPresentedViewController];
    if (presenter == nil || self.alertView != nil) return;
    UIAlertController *loadingAlert = [UIAlertController alertControllerWithTitle:@"Loading Map Data"
                                                                           message:@"\n\nPlease wait..."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    UIActivityIndicatorView *activity;
    if (@available(iOS 13.0, *)) {
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    } else {
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    activity.translatesAutoresizingMaskIntoConstraints = NO;
    [loadingAlert.view addSubview:activity];
    [NSLayoutConstraint activateConstraints:@[
        [activity.centerXAnchor constraintEqualToAnchor:loadingAlert.view.centerXAnchor],
        [activity.topAnchor constraintEqualToAnchor:loadingAlert.view.topAnchor constant:52.0f]
    ]];
    [activity startAnimating];
    self.alertView = loadingAlert;
    [presenter presentViewController:loadingAlert animated:YES completion:nil];
}

- (void)dismissLoadingAlertIfNeeded {
    if (self.alertView == nil) return;
    [self.alertView dismissViewControllerAnimated:YES completion:nil];
    self.alertView = nil;
}

- (void)presentUpdateMessageWithTitle:(NSString *)messageTitle
                              message:(NSString *)messageText
                                  url:(NSString *)messageURL
                     actionButtonText:(NSString *)buttonText {
    UIViewController *presenter = [self topPresentedViewController];
    if (presenter == nil) return;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:messageTitle
                                                                   message:messageText
                                                            preferredStyle:UIAlertControllerStyleAlert];
    if (buttonText != nil && buttonText.length > 0) {
        [alert addAction:[UIAlertAction actionWithTitle:buttonText style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            OpenExternalURLWithLogging([NSURL URLWithString:messageURL]);
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    } else {
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    }
    [presenter presentViewController:alert animated:YES completion:nil];
}

- (void)weblink {
    OpenExternalURLWithLogging([NSURL URLWithString:WEB_ADDRESS]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Hide back button text globally so only chevrons are ever shown.
    UIOffset offscreenOffset = UIOffsetMake(-1000.0f, 0.0f);
    if (@available(iOS 9.0, *)) {
        UIBarButtonItem *appearance = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]];
        [appearance setBackButtonTitlePositionAdjustment:offscreenOffset forBarMetrics:UIBarMetricsDefault];
        [appearance setBackButtonTitlePositionAdjustment:offscreenOffset forBarMetrics:UIBarMetricsCompact];
    } else {
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:offscreenOffset forBarMetrics:UIBarMetricsDefault];
    }

    //-----------PUSHWOOSH PART-----------
    // set custom delegate for push handling, in our case AppDelegate
    [Pushwoosh sharedInstance].delegate = (id<PWMessagingDelegate>)self;
    //register for push notifications!
    [[Pushwoosh sharedInstance] registerForPushNotifications];

    NSLog(@"[OAEC][App] Launch complete");
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
    NSLog(@"[OAEC][Push] Message received");
}
//this event is fired when user taps the notification
- (void)pushwoosh:(Pushwoosh *)pushwoosh onMessageOpened:(PWMessage *)message {
    NSLog(@"[OAEC][Push] Message opened");
}


- (void)downloadImmediateData {
    [self downloadSpreadsheet];
    [self downloadCalendar];
    [self downloadPhotosZipFile];
}

- (void)populateSpreadsheetData {
    
    NSLog(@"[OAEC][Data] Populating in-memory datasets");
    
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
   

    
    
    NSLog(@"[OAEC][Data] Loaded people: total=%lu senate=%lu house=%lu judiciary=%lu",
          (unsigned long)[self.all count],
          (unsigned long)[self.stateSenate count],
          (unsigned long)[self.stateHouse count],
          (unsigned long)[self.stateJudiciary count]);
    
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
        [committeeLookup setObject:committee forKey:committee.key];
    }
    
    NSString *dataFilename = [[NSBundle mainBundle] pathForResource:@"committees" ofType:@"csv"];
    
    NSArray *committeesMetaData = [DataLoader loadCSVFile:dataFilename];
    
    for (NSDictionary *committeeDict in committeesMetaData) {
        
        NSString *key = [[NSString stringWithFormat:@"%@:%@",[committeeDict.committeeChamber trim],[committeeDict.committeeName trim]] lowercaseString];
        
        Committee *committee = [committeeLookup objectForKey:key];
        
        if (committee!=nil) {
            
            committee.room=committeeDict.committeeRoom;
            committee.time=committeeDict.committeeTime;
            committee.dow=committeeDict.committeeDOW;
            committee.website=committeeDict.committeeWebsite;
        } else {
            NSLog(@"[OAEC][Data] Committee metadata missing for key: %@", key);
        }
    }

    NSLog(@"[OAEC][Data] Dataset population complete");

}

- (void)publishSpreadsheetPeopleOnMainThread:(NSArray *)people {
    self.all = people ?: @[];
    [self populateSpreadsheetData];
    [[NSNotificationCenter defaultCenter] postNotificationName:OAECSpreadsheetDataDidReloadNotification object:self];
}

- (NSArray *)loadPreferredLocalSpreadsheetPeople {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *previousDataFilename = [NSString stringWithFormat:@"%@/previousdata.csv", docsDir];
    NSString *bundledDataFilename = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"csv"];

    if ([fileManager fileExistsAtPath:previousDataFilename]) {
        NSArray *cachedPeople = [DataLoader loadCSVFile:previousDataFilename];
        if (cachedPeople != nil && cachedPeople.count > 0) {
            NSLog(@"[OAEC][Download] Preloaded cached previousdata.csv (%lu rows)", (unsigned long)cachedPeople.count);
            return cachedPeople;
        }
        NSLog(@"[OAEC][Download] Cached previousdata.csv was empty or invalid; falling back to bundled data.csv");
    }

    if (bundledDataFilename != nil) {
        NSArray *bundledPeople = [DataLoader loadCSVFile:bundledDataFilename];
        if (bundledPeople != nil && bundledPeople.count > 0) {
            NSLog(@"[OAEC][Download] Preloaded bundled data.csv (%lu rows)", (unsigned long)bundledPeople.count);
            return bundledPeople;
        }
    }

    NSLog(@"[OAEC][Download] No usable local spreadsheet was available before download");
    return nil;
}



- (void)downloadSpreadsheet {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURL *URL = [NSURL URLWithString:@"https://www.dropbox.com/s/1f6ymjx2mjq0wn6/data58.csv?raw=1"];
    NSString *csvFilename = [NSString stringWithFormat:@"%@/data58.csv", docsDir];
    NSString *previousDataFilename = [NSString stringWithFormat:@"%@/previousdata.csv", docsDir];
    NSArray *preloadedPeople = nil;
    if (self.all == nil || self.all.count == 0) {
        preloadedPeople = [self loadPreferredLocalSpreadsheetPeople];
    }
    if (preloadedPeople != nil && preloadedPeople.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.all == nil || self.all.count == 0) {
                [self publishSpreadsheetPeopleOnMainThread:preloadedPeople];
            }
        });
    }
    [fileManager removeItemAtPath:csvFilename error:nil];

    NSLog(@"[OAEC][Download] Starting data58.csv download");
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:[NSURLRequest requestWithURL:URL] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        mapDataLoaded = NO;
        NSError *fmError = nil;
        NSString *harddataFilename = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"csv"];
        NSArray *loadedPeople = nil;
        if (error != nil) {
            NSLog(@"[OAEC][Download] data58.csv download failed: %@", error.localizedDescription);
        }
        if (location != nil) {
            NSURL *destURL = [NSURL fileURLWithPath:csvFilename];
            [fileManager removeItemAtURL:destURL error:nil];
            [fileManager copyItemAtURL:location toURL:destURL error:nil];
        }
        BOOL usedDownloaded = NO, usedPrevious = NO, usedBundle = NO;
        if ([fileManager fileExistsAtPath:csvFilename]) {
            loadedPeople = [DataLoader loadCSVFile:csvFilename];
            if (loadedPeople != nil && loadedPeople.count > 0) {
                usedDownloaded = YES;
                NSLog(@"[OAEC][Download] data58.csv loaded from network (%lu rows)", (unsigned long)loadedPeople.count);
                [fileManager removeItemAtPath:previousDataFilename error:&fmError];
                [fileManager copyItemAtPath:csvFilename toPath:previousDataFilename error:&fmError];
                [fileManager removeItemAtPath:csvFilename error:&fmError];
            }
        }
        if (!usedDownloaded && [fileManager fileExistsAtPath:previousDataFilename]) {
            loadedPeople = [DataLoader loadCSVFile:previousDataFilename];
            if (loadedPeople != nil && loadedPeople.count > 0) {
                usedPrevious = YES;
                NSLog(@"[OAEC][Download] data58.csv fallback to cached previousdata.csv (%lu rows)", (unsigned long)loadedPeople.count);
            }
        }
        if (!usedDownloaded && !usedPrevious && harddataFilename != nil) {
            loadedPeople = [DataLoader loadCSVFile:harddataFilename];
            if (loadedPeople != nil && loadedPeople.count > 0) {
                usedBundle = YES;
                NSLog(@"[OAEC][Download] data58.csv fallback to bundled data.csv (%lu rows)", (unsigned long)loadedPeople.count);
            }
        }
        if (loadedPeople == nil || loadedPeople.count == 0) loadedPeople = @[];
        if (!usedDownloaded && !usedPrevious && !usedBundle) {
            NSLog(@"[OAEC][Download] data58.csv unavailable; continuing with empty dataset");
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            // Keep dataset publication on the main thread so UI readers never race background writes.
            [self publishSpreadsheetPeopleOnMainThread:loadedPeople];
        });
    }];
    [downloadTask resume];
}


- (void)downloadCalendar {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *calendarFilename = [NSString stringWithFormat:@"%@/calendar58.csv", docsDir];
    NSString *previousCalendarFilename = [NSString stringWithFormat:@"%@/previouscalendar.csv", docsDir];
    [fileManager removeItemAtPath:calendarFilename error:nil];

    NSURL *CALENDAR_URL = [NSURL URLWithString:@"https://www.dropbox.com/s/hp0z3dgq5ajjenw/calendar58.csv?raw=1"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDownloadTask *calendarDownloadTask = [session downloadTaskWithRequest:[NSURLRequest requestWithURL:CALENDAR_URL] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSError *fmError = nil;
        NSString *hardcalendarFilename = [[NSBundle mainBundle] pathForResource:@"calendar" ofType:@"csv"];
        if (location != nil) {
            NSURL *destURL = [NSURL fileURLWithPath:calendarFilename];
            [fileManager removeItemAtURL:destURL error:nil];
            [fileManager copyItemAtURL:location toURL:destURL error:nil];
        }
        if ([fileManager fileExistsAtPath:calendarFilename]) {
            self.calendar = [DataLoader loadCalendarCSVFile:calendarFilename];
            [fileManager removeItemAtPath:previousCalendarFilename error:&fmError];
            [fileManager copyItemAtPath:calendarFilename toPath:previousCalendarFilename error:&fmError];
            [fileManager removeItemAtPath:calendarFilename error:&fmError];
        } else if ([fileManager fileExistsAtPath:previousCalendarFilename]) {
            self.calendar = [DataLoader loadCalendarCSVFile:previousCalendarFilename];
        } else if (hardcalendarFilename != nil) {
            self.calendar = [DataLoader loadCalendarCSVFile:hardcalendarFilename];
        }
    }];
    [calendarDownloadTask resume];
}


- (void)downloadPhotosZipFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *bundledPhotosPath = [[NSBundle mainBundle] pathForResource:@"photos" ofType:@"zip"];
    if (bundledPhotosPath != nil) {
        [DataLoader loadPhotosFile:bundledPhotosPath];
        NSLog(@"[OAEC][Download] Loaded bundled photos.zip for immediate availability");
    }

    NSURL *PHOTOS_URL = [NSURL URLWithString:@"https://www.dropbox.com/s/9cl4vth7q57qpt6/photos58.zip?raw=1"];
    NSString *photosFilename = [NSString stringWithFormat:@"%@/photos58.zip", docsDir];
    NSString *previousPhotosFilename = [NSString stringWithFormat:@"%@/previousphotos.zip", docsDir];
    [fileManager removeItemAtPath:photosFilename error:nil];

    NSLog(@"[OAEC][Download] Starting photos58.zip download");
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDownloadTask *photosDownloadTask = [session downloadTaskWithRequest:[NSURLRequest requestWithURL:PHOTOS_URL] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSError *fmError = nil;
        if (error != nil) {
            NSLog(@"[OAEC][Download] photos58.zip download failed: %@", error.localizedDescription);
        }
        if (location != nil) {
            NSURL *destURL = [NSURL fileURLWithPath:photosFilename];
            [fileManager removeItemAtURL:destURL error:nil];
            [fileManager copyItemAtURL:location toURL:destURL error:nil];
        }
        if ([fileManager fileExistsAtPath:photosFilename]) {
            [DataLoader loadPhotosFile:photosFilename];
            NSLog(@"[OAEC][Download] photos58.zip loaded from network");
            [fileManager removeItemAtPath:previousPhotosFilename error:&fmError];
            [fileManager copyItemAtPath:photosFilename toPath:previousPhotosFilename error:&fmError];
            [fileManager removeItemAtPath:photosFilename error:&fmError];
        } else if ([fileManager fileExistsAtPath:previousPhotosFilename]) {
            [DataLoader loadPhotosFile:previousPhotosFilename];
            NSLog(@"[OAEC][Download] photos58.zip fallback to cached previousphotos.zip");
        } else if (bundledPhotosPath != nil) {
            [DataLoader loadPhotosFile:bundledPhotosPath];
            NSLog(@"[OAEC][Download] photos58.zip fallback to bundled photos.zip");
        }
    }];
    [photosDownloadTask resume];
}

-(void) realLoadBoundaries {
    NSLog(@"[OAEC][Map] Loading boundary data");
    
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
    
    NSLog(@"[OAEC][Map] Boundary data ready");
    
    
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
                    NSLog(@"[OAEC][Integrity] %@ %@ %@ District NOT found: %@",person.type,person.firstName,person.lastName,districtNumber);
                }
            }
            
            NSArray *counties = [person.countiesCovered componentsSeparatedByString:@"~"];
            for (NSString *county in counties) {
                Boundary *countyBoundary = [self.countyBoundaries objectForKey:[[county uppercaseString] trim]];
                if (county!=nil && [county length]>0 && countyBoundary==nil) {
                    NSLog(@"[OAEC][Integrity] %@ %@ %@ County NOT found: %@",person.type,person.firstName,person.lastName,[[county uppercaseString] trim]);
                }
            }
        }
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissLoadingAlertIfNeeded];
    });
}

-(void) loadBoundaries {
    @synchronized (self) {
        if (mapDataLoaded) return;
        mapDataLoaded = YES;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentLoadingAlert];
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self realLoadBoundaries];
    });
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

    NSLog(@"[OAEC][App] Application became active");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
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
