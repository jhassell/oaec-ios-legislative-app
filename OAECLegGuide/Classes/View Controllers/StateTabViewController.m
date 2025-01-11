//
//  StateTabViewController.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/21/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <Realm/Realm.h>
#import "StateTabViewController.h"
#import "PeopleListViewController.h"
#import "VotingListViewController.h"
#import "AppDelegate.h"
#import "ListSection.h"
#import "CommitteeListViewController.h"
#import "CommitteeVoteListViewController.h"
#import "ListSection.h"

@interface StateTabViewController ()
- (IBAction)statewideButtonPressed:(id)sender;
- (IBAction)senateButtonPressed:(id)sender;
- (IBAction)senateVoteButtonPressed:(id)sender;
- (IBAction)senateLeadershipButtonPressed:(id)sender;
- (IBAction)senateCommitteesButtonPressed:(id)sender;
- (IBAction)houseButtonPressed:(id)sender;
- (IBAction)houseVoteButtonPressed:(id)sender;
- (IBAction)houseLeadershipButtonPressed:(id)sender;
- (IBAction)houseCommitteesButtonpressed:(id)sender;
- (IBAction)houseVoteCommitteesButtonPressed:(id)sender;
- (IBAction)allButtonPressed:(id)sender;
- (IBAction)allVoteButtonPressed:(id)sender;
- (IBAction)judicialButtonPressed:(id)sender;
- (IBAction)voteTallyButtonPressed:(id)sender;


@end

@implementation StateTabViewController

-(IBAction) weblink {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] weblink];
}


- (IBAction)backButtonPressed:(id)sender {    
    self.tabBarController.selectedIndex = 0;
}


- (IBAction)statewideButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PeopleListViewController *plvc = [[[PeopleListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
    plvc.sections = [ListSection buildSectionsFrom:ad.all dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects:STATEWIDE, nil]];    
    
    [self.navigationController pushViewController:plvc animated:YES];

}

- (IBAction)senateButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PeopleListViewController *plvc = [[[PeopleListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
    plvc.sections = [ListSection buildSectionsFrom:ad.stateSenate dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects:STATE_SENATE, nil]];
    
    [self.navigationController pushViewController:plvc animated:YES];

}

- (IBAction)senateVoteButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    VotingListViewController *vlvc = [[[VotingListViewController alloc] initWithNibName:@"VoteListView-iPhone" bundle:nil] autorelease];
    vlvc.rc_sections = [ListSection buildSectionsFrom:ad.stateSenate dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects:STATE_SENATE, nil]];
    
    [self.navigationController pushViewController:vlvc animated:YES];
    
}

- (IBAction)houseVoteButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    VotingListViewController *vlvc = [[[VotingListViewController alloc] initWithNibName:@"VoteListView-iPhone" bundle:nil] autorelease];
    vlvc.rc_sections = [ListSection buildSectionsFrom:ad.stateHouse dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects:STATE_HOUSE, nil]];
    
    [self.navigationController pushViewController:vlvc animated:YES];
    
}

- (IBAction)senateLeadershipButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PeopleListViewController *plvc = [[[PeopleListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
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
    
    ListSection *ls3 = [[[ListSection alloc] init] autorelease];
    ls3.title=CAEDOCOMMITTEES;
    ls3.children=[[NSArray arrayWithArray:ad.stateSenateCAEDOCommittees] mutableCopy];

    ListSection *ls4 = [[[ListSection alloc] init] autorelease];
    ls4.title=EOCOMMITTEES;
    ls4.children=[[NSArray arrayWithArray:ad.stateSenateEducationOversightCommittees] mutableCopy];

    ListSection *ls5 = [[[ListSection alloc] init] autorelease];
    ls5.title=GOCOMMITTEES;
    ls5.children=[[NSArray arrayWithArray:ad.stateSenateGovernmentOversightCommittees] mutableCopy];

    ListSection *ls6 = [[[ListSection alloc] init] autorelease];
    ls6.title=HHSOCOMMITTEES;
    ls6.children=[[NSArray arrayWithArray:ad.stateSenateHealthOversightCommittees] mutableCopy];

    ListSection *ls7 = [[[ListSection alloc] init] autorelease];
    ls7.title=ENROCOMMITTEES;
    ls7.children=[[NSArray arrayWithArray:ad.stateSenateEnergyOversightCommittees] mutableCopy];
    
    ListSection *ls8 = [[[ListSection alloc] init] autorelease];
    ls8.title=JPSCOMMITTEES;
    ls8.children=[[NSArray arrayWithArray:ad.stateSenateJudiciaryOversightCommittees] mutableCopy];
    
    clvc.sections = [NSArray arrayWithObjects:ls1,ls2,ls3,ls4,ls5,ls6,ls7,ls8,nil];
    
    [self.navigationController pushViewController:clvc animated:YES];
    

}


- (IBAction)senateVoteCommitteesButtonPressed:(id)sender {
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CommitteeVoteListViewController *clvc = [[[CommitteeVoteListViewController alloc] initWithNibName:@"CommitteeListView-iPhone" bundle:nil] autorelease];
    
    ListSection *ls1 = [[[ListSection alloc] init] autorelease];
    ls1.title=STANDING;
    ls1.children=[[NSArray arrayWithArray:ad.stateSenateStandingCommittees] mutableCopy];
    
    ListSection *ls2 = [[[ListSection alloc] init] autorelease];
    ls2.title=APPROPRIATIONS;
    ls2.children=[[NSArray arrayWithArray:ad.stateSenateAppropriationsSubcommittees] mutableCopy];
    
    ListSection *ls3 = [[[ListSection alloc] init] autorelease];
    ls3.title=CAEDOCOMMITTEES;
    ls3.children=[[NSArray arrayWithArray:ad.stateSenateCAEDOCommittees] mutableCopy];

    ListSection *ls4 = [[[ListSection alloc] init] autorelease];
    ls4.title=EOCOMMITTEES;
    ls4.children=[[NSArray arrayWithArray:ad.stateSenateEducationOversightCommittees] mutableCopy];

    ListSection *ls5 = [[[ListSection alloc] init] autorelease];
    ls5.title=GOCOMMITTEES;
    ls5.children=[[NSArray arrayWithArray:ad.stateSenateGovernmentOversightCommittees] mutableCopy];

    ListSection *ls6 = [[[ListSection alloc] init] autorelease];
    ls6.title=HHSOCOMMITTEES;
    ls6.children=[[NSArray arrayWithArray:ad.stateSenateHealthOversightCommittees] mutableCopy];

    ListSection *ls7 = [[[ListSection alloc] init] autorelease];
    ls7.title=ENROCOMMITTEES;
    ls7.children=[[NSArray arrayWithArray:ad.stateSenateEnergyOversightCommittees] mutableCopy];
    
    ListSection *ls8 = [[[ListSection alloc] init] autorelease];
    ls8.title=JPSCOMMITTEES;
    ls8.children=[[NSArray arrayWithArray:ad.stateSenateJudiciaryOversightCommittees] mutableCopy];
    
    clvc.sections = [NSArray arrayWithObjects:ls1,ls2,ls3,ls4,ls5,ls6,ls7,ls8,nil];
    
    [self.navigationController pushViewController:clvc animated:YES];
    
}





- (IBAction)houseButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PeopleListViewController *plvc = [[[PeopleListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
    plvc.sections = [ListSection buildSectionsFrom:ad.stateHouse dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects: STATE_HOUSE, nil]];
    
    [self.navigationController pushViewController:plvc animated:YES];

}










- (IBAction)houseLeadershipButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PeopleListViewController *plvc = [[[PeopleListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
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
    
    ListSection *ls3 = [[[ListSection alloc] init] autorelease];
    ls3.title=CAEDOCOMMITTEES;
    ls3.children=[[NSArray arrayWithArray:ad.stateHouseCAEDOCommittees] mutableCopy];

    ListSection *ls4 = [[[ListSection alloc] init] autorelease];
    ls4.title=EOCOMMITTEES;
    ls4.children=[[NSArray arrayWithArray:ad.stateHouseEnergyOversightCommittees] mutableCopy];

    ListSection *ls5 = [[[ListSection alloc] init] autorelease];
    ls5.title=GOCOMMITTEES;
    ls5.children=[[NSArray arrayWithArray:ad.stateHouseGovernmentOversightCommittees] mutableCopy];

    ListSection *ls6 = [[[ListSection alloc] init] autorelease];
    ls6.title=HHSOCOMMITTEES;
    ls6.children=[[NSArray arrayWithArray:ad.stateHouseHealthOversightCommittees] mutableCopy];

    ListSection *ls7 = [[[ListSection alloc] init] autorelease];
    ls7.title=ENROCOMMITTEES;
    ls7.children=[[NSArray arrayWithArray:ad.stateHouseEnergyOversightCommittees] mutableCopy];
    
    ListSection *ls8 = [[[ListSection alloc] init] autorelease];
    ls8.title=JPSCOMMITTEES;
    ls8.children=[[NSArray arrayWithArray:ad.stateHouseJudiciaryOversightCommittees] mutableCopy];
    
    clvc.sections = [NSArray arrayWithObjects:ls1,ls2,ls3,ls4,ls5,ls6,ls7,ls8,nil];
    
    [self.navigationController pushViewController:clvc animated:YES];

}

- (IBAction)houseVoteCommitteesButtonPressed:(id)sender {
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CommitteeVoteListViewController *clvc = [[[CommitteeVoteListViewController alloc] initWithNibName:@"CommitteeListView-iPhone" bundle:nil] autorelease];
    
    ListSection *ls1 = [[[ListSection alloc] init] autorelease];
    ls1.title=STANDING;
    ls1.children=[[NSArray arrayWithArray:ad.stateHouseStandingCommittees] mutableCopy];
    
    ListSection *ls2 = [[[ListSection alloc] init] autorelease];
    ls2.title=APPROPRIATIONS;
    ls2.children=[[NSArray arrayWithArray:ad.stateHouseAppropriationsSubcommittees] mutableCopy];
    
    ListSection *ls3 = [[[ListSection alloc] init] autorelease];
    ls3.title=CAEDOCOMMITTEES;
    ls3.children=[[NSArray arrayWithArray:ad.stateHouseCAEDOCommittees] mutableCopy];

    ListSection *ls4 = [[[ListSection alloc] init] autorelease];
    ls4.title=EOCOMMITTEES;
    ls4.children=[[NSArray arrayWithArray:ad.stateHouseEnergyOversightCommittees] mutableCopy];

    ListSection *ls5 = [[[ListSection alloc] init] autorelease];
    ls5.title=GOCOMMITTEES;
    ls5.children=[[NSArray arrayWithArray:ad.stateHouseGovernmentOversightCommittees] mutableCopy];

    ListSection *ls6 = [[[ListSection alloc] init] autorelease];
    ls6.title=HHSOCOMMITTEES;
    ls6.children=[[NSArray arrayWithArray:ad.stateHouseHealthOversightCommittees] mutableCopy];

    ListSection *ls7 = [[[ListSection alloc] init] autorelease];
    ls7.title=ENROCOMMITTEES;
    ls7.children=[[NSArray arrayWithArray:ad.stateHouseEnergyOversightCommittees] mutableCopy];
    
    ListSection *ls8 = [[[ListSection alloc] init] autorelease];
    ls8.title=JPSCOMMITTEES;
    ls8.children=[[NSArray arrayWithArray:ad.stateHouseJudiciaryOversightCommittees] mutableCopy];
    
    clvc.sections = [NSArray arrayWithObjects:ls1,ls2,ls3,ls4,ls5,ls6,ls7,ls8,nil];
    
    [self.navigationController pushViewController:clvc animated:YES];
    
}



- (IBAction)allButtonPressed:(id)sender {
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PeopleListViewController *plvc = [[PeopleListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil];
    
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

- (IBAction)allVoteButtonPressed:(id)sender {
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    VotingListViewController *vlvc = [[VotingListViewController alloc] initWithNibName:@"VoteListView-iPhone" bundle:nil];
    
    ListSection *ls1 = [[[ListSection alloc] init] autorelease];
    ls1.title=@"All Oklahoma";
    
    NSMutableArray *all = [NSMutableArray arrayWithArray:ad.stateHouse];
    [all addObjectsFromArray:ad.stateSenate];
    [all addObjectsFromArray:ad.statewide];
    
    NSSortDescriptor *lastSort = [NSSortDescriptor sortDescriptorWithKey:@"Last Name" ascending:YES];
    NSSortDescriptor *firstSort = [NSSortDescriptor sortDescriptorWithKey:@"First Name" ascending:YES];
    
    [all sortUsingDescriptors:[NSArray arrayWithObjects:lastSort,firstSort,nil]];
    
    ls1.children=[[NSArray arrayWithArray:all] mutableCopy];
    
    vlvc.rc_sections = [NSArray arrayWithObject:ls1];
    
    //NSLog(@"%i sections",[plvc.sections count]);
    
    // for (ListSection *section in plvc.sections) {
    
    //NSLog(@"Section %@ has %i children",section.title,[section.children count]);
    
    // }
    
    [self.navigationController pushViewController:vlvc animated:YES];
    
}



- (IBAction)voteTallyButtonPressed:(id)sender {
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    VotingListViewController *vlvc = [[VotingListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil];
    
    ListSection *ls1 = [[[ListSection alloc] init] autorelease];
    ls1.title=@"All Oklahoma";
    
    NSMutableArray *all = [NSMutableArray arrayWithArray:ad.stateHouse];
    [all addObjectsFromArray:ad.stateSenate];
    [all addObjectsFromArray:ad.statewide];
    
    NSSortDescriptor *lastSort = [NSSortDescriptor sortDescriptorWithKey:@"Last Name" ascending:YES];
    NSSortDescriptor *firstSort = [NSSortDescriptor sortDescriptorWithKey:@"First Name" ascending:YES];
    
    [all sortUsingDescriptors:[NSArray arrayWithObjects:lastSort,firstSort,nil]];
    
    ls1.children=[[NSArray arrayWithArray:all] mutableCopy];
    
    vlvc.rc_sections = [NSArray arrayWithObject:ls1];
    
    
    [self.navigationController pushViewController:vlvc animated:YES];
    
}







- (IBAction)judicialButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PeopleListViewController *plvc = [[[PeopleListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
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
