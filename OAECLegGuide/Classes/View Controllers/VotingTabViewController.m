//
//  VotingTabViewController.m
//  OAECLegGuide
//
//  Created by User on 5/15/17.
//  Copyright © 2017 Architactile LLC. All rights reserved.
//

#import <Realm/Realm.h>
#import "VotingTabViewController.h"
#import "VotingListViewController.h"
#import "AppDelegate.h"
#import "ListSection.h"
#import "CommitteeListViewController.h"
#import "ListSection.h"

@interface VotingTabViewController ()
- (IBAction)statewideButtonPressed:(id)sender;
- (IBAction)senateButtonPressed:(id)sender;
- (IBAction)senateLeadershipButtonPressed:(id)sender;
- (IBAction)senateCommitteesButtonPressed:(id)sender;
- (IBAction)houseButtonPressed:(id)sender;
- (IBAction)houseLeadershipButtonPressed:(id)sender;
- (IBAction)houseCommitteesButtonpressed:(id)sender;
- (IBAction)allButtonPressed:(id)sender;
- (IBAction)judicialButtonPressed:(id)sender;
- (IBAction)voteTallyButtonPressed:(id)sender;


@end

@implementation VotingTabViewController

-(IBAction) weblink {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] weblink];
}


- (IBAction)statewideButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    VotingListViewController *plvc = [[[VotingListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
    plvc.sections = [ListSection buildSectionsFrom:ad.all dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects:STATEWIDE, nil]];
    
    [self pushViewController:plvc animated:YES];
    
}

- (IBAction)senateButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    VotingListViewController *plvc = [[[VotingListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
    plvc.sections = [ListSection buildSectionsFrom:ad.stateSenate dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects:STATE_SENATE, nil]];
    
    [self.navigationController pushViewController:plvc animated:YES];
    
}

- (IBAction)senateLeadershipButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    VotingListViewController *plvc = [[[VotingListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
    plvc.sections = [ListSection buildSectionsFrom:ad.all dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects: STATE_SENATE, nil] withTitlesOnly:YES];
    
    [self.navigationController pushViewController:plvc animated:YES];
}

- (IBAction)senateCommitteesButtonPressed:(id)sender {
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CommitteeListViewController *clvc = [[[CommitteeListViewController alloc] initWithNibName:@"CommitteeListView-iPhone" bundle:nil] autorelease];
    
    ListSection *ls1 = [[[ListSection alloc] init] autorelease];
    ls1.title=STANDING;
    ls1.children=[[NSArray arrayWithArray:ad.stateSenateStandingCommittees] mutableCopy];
    
    ListSection *ls2 = [[[ListSection alloc] init] autorelease];
    ls2.title=APPROPRIATIONS;
    ls2.children=[[NSArray arrayWithArray:ad.stateSenateAppropriationsSubcommittees] mutableCopy];
    
    clvc.sections = [NSArray arrayWithObjects:ls1,ls2,nil];
    
    [self.navigationController pushViewController:clvc animated:YES];
    
    
}

- (IBAction)houseButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    VotingListViewController *plvc = [[[VotingListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
    plvc.sections = [ListSection buildSectionsFrom:ad.stateHouse dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects: STATE_HOUSE, nil]];
    
    [self.navigationController pushViewController:plvc animated:YES];
    
}

- (IBAction)houseLeadershipButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    VotingListViewController *plvc = [[[VotingListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
    plvc.sections = [ListSection buildSectionsFrom:ad.all dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects: STATE_HOUSE, nil] withTitlesOnly:YES];
    
    [self.navigationController pushViewController:plvc animated:YES];
    
}

- (IBAction)houseCommitteesButtonpressed:(id)sender {
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CommitteeListViewController *clvc = [[[CommitteeListViewController alloc] initWithNibName:@"CommitteeListView-iPhone" bundle:nil] autorelease];
    
    ListSection *ls1 = [[[ListSection alloc] init] autorelease];
    ls1.title=STANDING;
    ls1.children=[[NSArray arrayWithArray:ad.stateHouseStandingCommittees] mutableCopy];
    
    ListSection *ls2 = [[[ListSection alloc] init] autorelease];
    ls2.title=APPROPRIATIONS;
    ls2.children=[[NSArray arrayWithArray:ad.stateHouseAppropriationsSubcommittees] mutableCopy];
    
    clvc.sections = [NSArray arrayWithObjects:ls1,ls2,nil];
    
    [self.navigationController pushViewController:clvc animated:YES];
    
}

- (IBAction)allButtonPressed:(id)sender {
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    VotingListViewController *plvc = [[VotingListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil];
    
    ListSection *ls1 = [[[ListSection alloc] init] autorelease];
    ls1.title=@"All Oklahoma";
    
    NSMutableArray *all = [NSMutableArray arrayWithArray:ad.stateHouse];
    [all addObjectsFromArray:ad.stateSenate];
    [all addObjectsFromArray:ad.statewide];
    
    NSSortDescriptor *lastSort = [NSSortDescriptor sortDescriptorWithKey:@"Last Name" ascending:YES];
    NSSortDescriptor *firstSort = [NSSortDescriptor sortDescriptorWithKey:@"First Name" ascending:YES];
    
    [all sortUsingDescriptors:[NSArray arrayWithObjects:lastSort,firstSort,nil]];
    
    ls1.children=[[NSArray arrayWithArray:all] mutableCopy];
    
    plvc.sections = [NSArray arrayWithObject:ls1];
    
    //NSLog(@"%i sections",[plvc.sections count]);
    
    // for (ListSection *section in plvc.sections) {
    
    //NSLog(@"Section %@ has %i children",section.title,[section.children count]);
    
    // }
    
    [self.navigationController pushViewController:plvc animated:YES];
    
}




- (IBAction)voteTallyButtonPressed:(id)sender {
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    VotingListViewController *plvc = [[VotingListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil];
    
    ListSection *ls1 = [[[ListSection alloc] init] autorelease];
    ls1.title=@"All Oklahoma";
    
    NSMutableArray *all = [NSMutableArray arrayWithArray:ad.stateHouse];
    [all addObjectsFromArray:ad.stateSenate];
    [all addObjectsFromArray:ad.statewide];
    
    NSSortDescriptor *lastSort = [NSSortDescriptor sortDescriptorWithKey:@"Last Name" ascending:YES];
    NSSortDescriptor *firstSort = [NSSortDescriptor sortDescriptorWithKey:@"First Name" ascending:YES];
    
    [all sortUsingDescriptors:[NSArray arrayWithObjects:lastSort,firstSort,nil]];
    
    ls1.children=[[NSArray arrayWithArray:all] mutableCopy];
    
    plvc.sections = [NSArray arrayWithObject:ls1];
    
    
    [self.navigationController pushViewController:plvc animated:YES];
    
}







- (IBAction)judicialButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    VotingListViewController *plvc = [[[VotingListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
    plvc.sections = [ListSection buildSectionsFrom:ad.stateJudiciary dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects: STATE_JUDICIARY, nil]];
    
    [self.navigationController pushViewController:plvc animated:YES];
    
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
    // Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
