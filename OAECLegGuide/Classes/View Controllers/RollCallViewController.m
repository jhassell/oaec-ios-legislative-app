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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *backBtn = (UIButton *)[self.view viewWithTag:9001];
    if ([backBtn isKindOfClass:[UIButton class]]) {
        [backBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [backBtn setAttributedTitle:nil forState:UIControlStateNormal];
        [backBtn setAttributedTitle:nil forState:UIControlStateHighlighted];
        if (@available(iOS 13.0, *)) {
            UIImage *chevron = [UIImage systemImageNamed:@"chevron.left"];
            if (chevron) {
                UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium];
                chevron = [chevron imageByApplyingSymbolConfiguration:config];
                [backBtn setImage:chevron forState:UIControlStateNormal];
                [backBtn setTitle:nil forState:UIControlStateNormal];
                backBtn.tintColor = [UIColor labelColor];
            }
        } else {
            [backBtn setImage:nil forState:UIControlStateNormal];
            [backBtn setTitle:@"\u2039" forState:UIControlStateNormal];
            backBtn.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
            [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
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
