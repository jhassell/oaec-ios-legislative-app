//
//  PeopleListViewController.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/29/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "PeopleListViewController.h"
#import "PeopleListDelegate.h"
#import "AppDelegate.h"
#import "Committee.h"

#import <Realm/Realm.h>



@interface PeopleListViewController ()

@property (nonatomic, retain) PeopleListDelegate *peopleListDelegate;
@property (retain, nonatomic) IBOutlet UITableView *peopleTable;

- (IBAction)backButtonPushed:(id)sender;

@end

@implementation PeopleListViewController

@synthesize peopleListDelegate=_peopleListDelegate;
@synthesize peopleTable=_peopleTable;
@synthesize sections=_sections;
@synthesize committee=_committee;

#pragma mark - UI Hooks


-(IBAction) weblink {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] weblink];
}


- (IBAction)backButtonPushed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Lifecycle Stuff

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.peopleTable.indexPathForSelectedRow!=nil) {
        [self.peopleTable deselectRowAtIndexPath:self.peopleTable.indexPathForSelectedRow animated:YES];
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.peopleListDelegate==nil) {
        self.peopleListDelegate = [[[PeopleListDelegate alloc] init] autorelease];
        self.peopleListDelegate.viewController = self;
        self.peopleListDelegate.committee=self.committee;
        self.peopleListDelegate.sections = self.sections;
        self.peopleTable.delegate=self.peopleListDelegate;
        self.peopleTable.dataSource=self.peopleListDelegate;
        self.peopleTable.contentOffset = CGPointMake(0, SEARCH_VIEW_HEIGHT);
        self.peopleListDelegate.peopleTable=self.peopleTable;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc
{
    [_committee release];
    [_sections release];
    [_peopleTable release];
    [_peopleListDelegate release];
    [super dealloc];
}

@end
