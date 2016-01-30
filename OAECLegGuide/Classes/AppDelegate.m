//
//  AppDelegate.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/21/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "DataLoader.h"
#import "Boundary.h"
#import "ModalAlert.h"
#import "NSDictionary+People.h"
#import "NSString+Stuff.h"
#import "Committee.h"
#import "NSDictionary+Committee.h"



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
@synthesize stateSenateAppropriationsSubcommittees=_stateSenateAppropriationsSubcommittees;
@synthesize stateHouseAppropriationsSubcommittees=_stateHouseAppropriationsSubcommittees;
@synthesize countyBoundaries=_countyBoundaries;
@synthesize municipalBoundaries=_municipalBoundaries;
@synthesize congressionalBoundaries=_congressionalBoundaries;
@synthesize stateSenateBoundaries=_stateSenateBoundaries;
@synthesize stateHouseBoundaries=_stateHouseBoundaries;
@synthesize coopBoundaries=_coopBoundaries;
@synthesize alertView=_alertView;

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive) {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
}

- (void)weblink {
    NSURL *url = [NSURL URLWithString:@"http://www.oaec.coop"];
    if (![[UIApplication sharedApplication] openURL:url])
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"CAyQsLynTJcl5D93CGysLwghBdDnawaOnn51tdgy"
                  clientKey:@"Gn3uq5QhvmtFq0U1GH9qyb9vF2SsqZqhvxbAj8Qs"];
    
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    
    
    mapDataLoaded = NO;
    NSString *dataFilename = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"csv"];
    
    NSLog(@"start load");
    self.all = [DataLoader loadCSVFile:dataFilename];
    
    NSString *calendarDataFilename = [[NSBundle mainBundle] pathForResource:@"calendar" ofType:@"csv"];
    self.calendar = [DataLoader loadCalendarCSVFile:calendarDataFilename];
    
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
    self.stateSenateAppropriationsSubcommittees  = [DataLoader buildCommitteesFromPeople:self.stateSenate committeeKey:APPROPRIATIONS];
    self.stateHouseAppropriationsSubcommittees = [DataLoader buildCommitteesFromPeople:self.stateHouse committeeKey:APPROPRIATIONS];
   

    
    // Resort OAEC Member Systems by company name then contact name
    NSSortDescriptor *companySort = [NSSortDescriptor sortDescriptorWithKey:@"Cooperative Name" ascending:YES];
    sortDescriptors = [NSArray arrayWithObjects:sortOrderSort,companySort,lastNameSort,firstNameSort,nil];
    self.oaecMembers = [self.oaecMembers sortedArrayUsingDescriptors:sortDescriptors];
    

    
    NSMutableArray *allCommittees = [NSMutableArray arrayWithCapacity:self.stateSenateStandingCommittees.count+
                                     self.stateHouseStandingCommittees.count+
                                     self.stateSenateAppropriationsSubcommittees.count+
                                     self.stateHouseAppropriationsSubcommittees.count];
    
    [allCommittees addObjectsFromArray:self.stateSenateStandingCommittees];
    [allCommittees addObjectsFromArray:self.stateHouseStandingCommittees];
    //[allCommittees addObjectsFromArray:self.stateSenateAppropriationsSubcommittees];
    //[allCommittees addObjectsFromArray:self.stateHouseAppropriationsSubcommittees];
    
    NSMutableDictionary *committeeLookup = [NSMutableDictionary dictionaryWithCapacity:allCommittees.count];
    for (Committee *committee in allCommittees) {
        committee.key = [[NSString stringWithFormat:@"%@:%@",[committee.body trim],[committee.name trim]] lowercaseString];
        //NSLog(@"name: %@  body: %@ type: %@",committee.name,committee.body,committee.type);
        NSLog(@"Committee key: *%@*",committee.key);
        [committeeLookup setObject:committee forKey:committee.key];
    }
    
    dataFilename = [[NSBundle mainBundle] pathForResource:@"committees" ofType:@"csv"];
    
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

    return YES;
}

-(void) realLoadBoundaries {
    NSLog(@"Load boundaries");
    
    self.countyBoundaries        = [Boundary buildBoundaryDictionaryWithJSONFile:[[NSBundle mainBundle] pathForResource:@"Counties" ofType:@"json"]]; // TULSA
    //self.municipalBoundaries     = [Boundary buildBoundaryDictionaryWithJSONFile:[[NSBundle mainBundle] pathForResource:@"Municipalities" ofType:@"json"]]; // Tulsa
    self.congressionalBoundaries = [Boundary buildBoundaryDictionaryWithJSONFile:[[NSBundle mainBundle] pathForResource:@"CongressionalDistricts" ofType:@"json"]]; // 01
    self.stateSenateBoundaries   = [Boundary buildBoundaryDictionaryWithJSONFile:[[NSBundle mainBundle] pathForResource:@"StateSenateDistricts" ofType:@"json"]];
    self.stateHouseBoundaries    = [Boundary buildBoundaryDictionaryWithJSONFile:[[NSBundle mainBundle] pathForResource:@"StateHouseDistricts" ofType:@"json"]];
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
    
    //NSLog(@"Answer == %i",answer);

    if (answer==0 && buttonText!=nil) {
        NSURL *url = [NSURL URLWithString:messageURL];
        [[UIApplication sharedApplication] openURL:url];
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
