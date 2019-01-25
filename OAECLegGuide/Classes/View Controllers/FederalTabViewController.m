//
//  FederalTabViewController.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/21/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "FederalTabViewController.h"
#import "AppDelegate.h"
#import "ListSection.h"
#import "PeopleListDelegate.h"

@interface FederalTabViewController ()

@property (nonatomic, retain) PeopleListDelegate *peopleListDelegate;
@property (retain, nonatomic) IBOutlet UITableView *peopleTable;

@end

@implementation FederalTabViewController

@synthesize peopleListDelegate=_peopleListDelegate;
@synthesize peopleTable = _peopleTable;

-(IBAction) weblink {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] weblink];
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    self.tabBarController.selectedIndex = 0;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.peopleListDelegate = [[[PeopleListDelegate alloc] init] autorelease];
    
    NSArray *sections = [ListSection buildSectionsFrom:ad.all dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects:FEDERAL_SENATE, FEDERAL_HOUSE, nil]];
    
    if ([sections count]==2) {
        sections = [NSArray arrayWithObjects:[sections objectAtIndex:1],[sections objectAtIndex:0], nil];
    }
    
    self.peopleListDelegate.sections = sections;
    
    self.peopleListDelegate.viewController=self;
    self.peopleListDelegate.peopleTable=self.peopleTable;
    
    self.peopleTable.delegate=self.peopleListDelegate;
    self.peopleTable.dataSource=self.peopleListDelegate;
    self.peopleTable.contentOffset = CGPointMake(0, SEARCH_VIEW_HEIGHT);
    
    [self.peopleTable reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [_peopleListDelegate release];
    [_peopleTable release];
    [super dealloc];
}

@end
