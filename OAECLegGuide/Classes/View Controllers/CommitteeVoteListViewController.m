//
//  CommitteeVoteListViewController.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/31/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "CommitteeVoteListViewController.h"
#import "ListSection.h"
#import "Committee.h"
#import "VotingListViewController.h"
#import "CommitteeListViewCell.h"
#import "AppDelegate.h"
#import "NSDictionary+People.h"
#import "NSString+Stuff.h"

@interface CommitteeVoteListViewController ()
- (IBAction)backButtonPushed:(id)sender;

@end

@implementation CommitteeVoteListViewController
@synthesize table=_table;
@synthesize sections=_sections;


-(IBAction) weblink {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] weblink];
}

- (IBAction)backButtonPushed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.textColor=[UIColor whiteColor];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.sections==nil) return nil;
    if ([self.sections count]<=section) return nil;
    ListSection *listSection = [self.sections objectAtIndex:section];
    return [NSString stringWithFormat:@"%@s",listSection.title];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.sections==nil) return 0;
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.sections==nil) return 0;
    if (section >= [self.sections count]) return 0;
    ListSection *listSection = [self.sections objectAtIndex:section];
    if (listSection.children==nil) return 0;
    return [listSection.children count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CommitteeListViewCell";
    CommitteeListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell==nil) {
        cell =  [[[NSBundle mainBundle] loadNibNamed:@"CommitteeListCell-iPhone" owner:nil options:nil] objectAtIndex:0];
    }
    
    ListSection *listSection = [self.sections objectAtIndex:indexPath.section];
    Committee *committee = [listSection.children objectAtIndex:indexPath.row];
    
    cell.committeeNameLabel.text = committee.name;
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ListSection *listSection = [self.sections objectAtIndex:indexPath.section];
    Committee *committee = [listSection.children objectAtIndex:indexPath.row];
    
    VotingListViewController *vlvc = [[[VotingListViewController alloc] initWithNibName:@"VoteListView-iPhone" bundle:nil] autorelease];
    
    
    ListSection *ls1 = [[[ListSection alloc] init] autorelease];
    
    ls1.title = committee.name;
    ls1.children = committee.members;
    
    vlvc.rc_sections = [NSArray arrayWithObject:ls1];
    
    vlvc.rc_committee = committee;
    
    [self.navigationController pushViewController:vlvc animated:YES];

}

- (void)dealloc {
    [_sections release];
    [_table release];
    [super dealloc];
}
@end
