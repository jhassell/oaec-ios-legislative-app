//
//  CommitteeListViewController.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/31/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "CommitteeListViewController.h"
#import "ListSection.h"
#import "Committee.h"
#import "PeopleListViewController.h"
#import "CommitteeListViewCell.h"
#import "AppDelegate.h"
#import "NSDictionary+People.h"
#import "NSString+Stuff.h"

@interface CommitteeListViewController ()
- (IBAction)backButtonPushed:(id)sender;

@end

@implementation CommitteeListViewController
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.textLabel.textColor = [UIColor colorWithRed:0.0 green:100.0/255.0 blue:0.0 alpha:1.0]; // Dark green color
        headerView.textLabel.font = [UIFont boldSystemFontOfSize:20]; // Optional: make the font bold
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.textColor=[UIColor whiteColor];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.sections==nil) return nil;
    if ([self.sections count]<=section) return nil;
    ListSection *listSection = [self.sections objectAtIndex:section];

    // Check if the section has any committees
    if (listSection.children == nil || [listSection.children count] == 0) {
        return nil; // No header for sections without committees
    }
    
    NSString *title = listSection.title;
    
    // Append "s" conditionally
    if ([title isEqualToString:@"Standing Committee"] || [title isEqualToString:@"Appropriations Subcommittee"]) {
        return [NSString stringWithFormat:@"%@s", title];
    }
    return title;
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
    
    PeopleListViewController *plvc = [[[PeopleListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
    
    
    ListSection *ls1 = [[[ListSection alloc] init] autorelease];
    
    ls1.title = committee.name;
    ls1.children = committee.members;
    
    plvc.sections = [NSArray arrayWithObject:ls1];
    
    plvc.committee = committee;
    
    [self.navigationController pushViewController:plvc animated:YES];

}

- (void)dealloc {
    [_sections release];
    [_table release];
    [super dealloc];
}
@end
