//
//  AboutViewController.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/21/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "AboutViewController.h"
#import "AppDelegate.h"
#import "PeopleListViewController.h"
#import "ListSection.h"

@interface AboutViewController () {
    BOOL firstLaunch;
}

@property (retain, nonatomic) IBOutlet UIImageView *backgroundImage;
- (IBAction)backButtonPressed:(id)sender;
- (IBAction)legislatureButtonPressed:(id)sender;
- (IBAction)memberSystemsButtonPressed:(id)sender;
- (IBAction)legContactsButtonPressed:(id)sender;


@end

@implementation AboutViewController

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)legislatureButtonPressed:(id)sender {
    UINavigationController *nc = [self.tabBarController.viewControllers objectAtIndex:1];
    [nc popToRootViewControllerAnimated:NO];
    [self.tabBarController setSelectedIndex:1];
}

-(IBAction) weblink {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] weblink];
}

- (IBAction)memberSystemsButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PeopleListViewController *plvc = [[[PeopleListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
    plvc.sections = [ListSection buildSectionsFrom:ad.all dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects:OAEC_MEMBER, nil]];
    
    [self.navigationController pushViewController:plvc animated:YES];
    
}

- (IBAction)legContactsButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PeopleListViewController *plvc = [[[PeopleListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
    plvc.sections = [ListSection buildSectionsFrom:ad.all dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects:LEGISLATIVE_CONTACT, nil]];
    
    [self.navigationController pushViewController:plvc animated:YES];
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if ([[UIScreen mainScreen]bounds].size.height - 480.0 > DBL_EPSILON) {
        NSLog(@"Use bigger image");
        self.backgroundImage.image=[UIImage imageNamed:@"AboutBackground-iPhone5@2x.png"];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (firstLaunch) {
        firstLaunch=NO;
        AppDelegate *ap = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [ap loadBoundaries];
    }
}

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
    firstLaunch=YES;
}

- (void)viewDidUnload
{
    [self setBackgroundImage:nil];
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
    [_backgroundImage release];
    [super dealloc];
}
@end
