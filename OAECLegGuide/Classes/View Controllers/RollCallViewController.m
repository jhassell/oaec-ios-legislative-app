//
//  RollCallViewController.m
//  ok57leg
//
//  Created by User on 1/23/19.
//  Copyright © 2019 Architactile LLC. All rights reserved.
//

#import "RollCallViewController.h"
#import <Realm/Realm.h>
#import "StateTabViewController.h"
#import "PeopleListViewController.h"
#import "VotingListViewController.h"
#import "AppDelegate.h"
#import "ListSection.h"
#import "CommitteeListViewController.h"
#import "CommitteeVoteListViewController.h"
#import "ListSection.h"

@interface RollCallViewController ()

@end

@implementation RollCallViewController


- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)senateVoteCommitteesButtonPressed:(id)sender {
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CommitteeVoteListViewController *clvc = [[[CommitteeVoteListViewController alloc] initWithNibName:@"CommitteeListView-iPhone" bundle:nil] autorelease];
    
    ListSection *ls1 = [[[ListSection alloc] init] autorelease];
    ls1.title=STANDING;
    ls1.children=[[NSArray arrayWithArray:ad.stateSenateStandingCommittees] mutableCopy];
    
    ListSection *ls2 = [[[ListSection alloc] init] autorelease];
    ls2.title=APPROPRIATIONS;
    ls2.children=[[NSArray arrayWithArray:ad.stateSenateAppropriationsSubcommittees] mutableCopy];
    
    clvc.sections = [NSArray arrayWithObjects:ls1,ls2,nil];
    
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
    
    clvc.sections = [NSArray arrayWithObjects:ls1,ls2,nil];
    
    [self.navigationController pushViewController:clvc animated:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
