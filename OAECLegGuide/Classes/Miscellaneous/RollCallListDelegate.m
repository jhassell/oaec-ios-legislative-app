//
//  PeopleListDelegate.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/26/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "RollCallListDelegate.h"
#import "ListSection.h"
#import "NSDictionary+People.h"
#import "AppDelegate.h"
#import "CommitteeMember.h"
#import "PersonViewController.h"
#import "NSString+Stuff.h"
#import "SearchViewCell.h"
#import "CommitteeHeaderView.h"
#import "Committee.h"
#import "Tally.h"
#import <Realm/Realm.h>
#import "CustomTableViewHeaderCell.h"

#define CELL_HEADSHOT       ((UIImageView *)[cell viewWithTag:100])
#define CELL_NAME           ((UILabel *)[cell viewWithTag:101])
#define CELL_TITLE          ((UILabel *)[cell viewWithTag:102])
#define CELL_SUBTITLE       ((UILabel *)[cell viewWithTag:103])
#define CELL_DISTRICT       ((UILabel *)[cell viewWithTag:104])
#define CELL_PHOTO_NA       ((UIView *)[cell viewWithTag:105])
#define CELL_YEA_VOTE       ((UIButton *)[cell viewWithTag:106])
#define CELL_NAY_VOTE       ((UIButton *)[cell viewWithTag:107])

RLM_ARRAY_TYPE(rc_Realm_vote)
RLM_ARRAY_TYPE(rc_Realm_tally)

@interface rc_Realm_vote : RLMObject
@property (nonatomic, strong) NSString *status;
@end

@interface rc_Realm_tally : RLMObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *body;
@property (nonatomic) NSInteger voteCount;
@property (nonatomic, strong) RLMArray<rc_Realm_vote *><rc_Realm_vote> *votes;
@end

@interface rc_Realm_tally_parent : RLMObject
@property (nonatomic, strong) RLMArray<rc_Realm_tally *><rc_Realm_tally> *tallies;
@end

@implementation rc_Realm_vote
// Nothing needed
@end
@implementation rc_Realm_tally
// Nothing needed
@end
@implementation rc_Realm_tally_parent
// Nothing needed
@end






@interface RollCallListDelegate ()

@property (readonly) SearchViewCell *searchViewCell;
@property (nonatomic, strong) NSMutableArray *filteredSections;
@property (retain, nonatomic) UITableViewCell *committeeHeaderView;
@property (nonatomic, strong) NSMutableArray *yeaVotes;
@property (nonatomic, strong) NSMutableArray *nayVotes;
@property (nonatomic, strong) Tally *sectionTally;
@property (nonatomic, strong) rc_Realm_tally_parent *parent;



-(void) buildDisplaySections;

@end

@implementation RollCallListDelegate

//@synthesize rc_sections=_rc_sections;
//@synthesize rc_viewController=_rc_viewController;
//@synthesize searchViewCell=_searchViewCell;
//@synthesize rc_peopleTable=_rc_peopleTable;
//@synthesize filteredSections=_filteredSections;
//@synthesize rc_committee=_rc_committee;
//@synthesize rc_committeeHeaderView=_rc_committeeHeaderView;

#pragma mark - Search Bar Delegate Stuff

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    // return NO to not become first responder
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // called when text starts editing
    searchBar.showsCancelButton=YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    // return NO to not resign first responder
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    // called when text ends editing
    searchBar.showsCancelButton=NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // called when text changes (including clear)
    //[self buildDisplaySectionsWithFilterType:searchBar.selectedScopeButtonIndex filterText:[searchBar.text trim]];
    //[self.peopleTable reloadData];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // called before text changes
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // called when keyboard search button pressed
    
    if (searchBar.text!=nil && [searchBar.text length]>0) {
        [self buildDisplaySectionsWithFilterType:searchBar.selectedScopeButtonIndex filterText:[searchBar.text trim]];
    } else {
        [self buildDisplaySections];
    }
    [self.rc_peopleTable reloadData];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    // called when bookmark button pressed
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    // called when cancel button pressed
    [self buildDisplaySections];
    [self.rc_peopleTable reloadData];

    if (self.rc_peopleTable!=nil && self.filteredSections!=nil && [self.filteredSections count]>0) {
        [self.rc_peopleTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    searchBar.text=@"";
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar { 
    // called when search results button pressed
    
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    if (searchBar.text!=nil && [searchBar.text length]>0) {
        [self buildDisplaySectionsWithFilterType:searchBar.selectedScopeButtonIndex filterText:[searchBar.text trim]];
    } else {
        [self buildDisplaySections];
    }
    [self.rc_peopleTable reloadData];
}

#pragma mark - Filter 

-(void)setRc_sections:(NSArray *)rc_sections {

    if (_rc_sections!=nil) {
        [_rc_sections release];
        _rc_sections=nil;
    }
    
    _rc_sections = [rc_sections retain];
    [self buildDisplaySections];
}

-(void) buildDisplaySections {

    [self buildDisplaySectionsWithFilterType:99 filterText:nil];
}

-(void) buildDisplaySectionsWithFilterType:(NSInteger)filterType filterText:(NSString *) filterText {

    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (self.filteredSections==nil) {
        self.filteredSections = [NSMutableArray arrayWithCapacity:[self.rc_sections count]];
        [defaults setObject:false forKey:@"yeaStatus"];
    }
    [self.filteredSections removeAllObjects];
    
    if ([self.rc_sections count]==0) return;
    
    
    for(ListSection *section in self.rc_sections) {
        
        
        if (section.children!=nil && [section.children count]>0) {

            NSMutableArray *filteredChildren = [NSMutableArray arrayWithCapacity:[section.children count]];
            
            NSPredicate *filterPredicate=nil; 
            switch (filterType) {
  //              case 0:
  //                  filterPredicate = [NSPredicate predicateWithFormat:@"LastName contains[cd] %@",filterText];
  //                  break;
                case 0:
                    filterPredicate = [NSPredicate predicateWithFormat:@"FirstName contains[cd] %@ OR LastName contains[cd] %@",filterText,filterText];
                    break;
                case 1:
                    filterPredicate = [NSPredicate predicateWithFormat:@"CountiesCovered contains[cd] %@",filterText];
                    break;
                case 2:
                    filterPredicate = [NSPredicate predicateWithFormat:@"DistrictNumber = %@",filterText];
                    break;
                default:
                    filterPredicate=nil;
                    break;
            }
            
            if (filterPredicate==nil) {
                [filteredChildren addObjectsFromArray:section.children];
            } else if ([[section.children objectAtIndex:0] isKindOfClass:[CommitteeMember class]]) {
                for(CommitteeMember *member in section.children) {
                    if ([filterPredicate evaluateWithObject:member.person]) {
                        [filteredChildren addObject:member];
                    }
                }
            } else {
                [filteredChildren addObjectsFromArray:[section.children filteredArrayUsingPredicate:filterPredicate]];
            }
            
            if (filteredChildren!=nil && [filteredChildren count]>0) {
                ListSection *filteredListSection = [[[ListSection alloc] init] autorelease];
                
                filteredListSection.title = section.title;
                filteredListSection.rowHeight = section.rowHeight;
                filteredListSection.firstRowHeight = section.firstRowHeight;
                
                filteredListSection.children = [NSMutableArray arrayWithArray: filteredChildren];
                
                [self.filteredSections addObject:filteredListSection];
            }
        }
    }
    
}

#pragma mark - Search View Property

-(SearchViewCell *) searchViewCell {
    
    if (self.searchViewCell==nil) {
        //self.searchViewCell = [[[[NSBundle mainBundle] loadNibNamed:@"PeopleListSearchCell-iPhone" owner:self options:nil] objectAtIndex:0] retain];
        self.searchViewCell.searchBar.delegate=self;
        self.searchViewCell.searchBar.showsCancelButton=NO;
    }
    
    return self.searchViewCell;
}

#pragma mark - Property Overides

-(void) setRc_committee:(Committee *)rc_committee {
    if (rc_committee==nil) {
        self.committeeHeaderView=nil;
        _rc_committee=nil;
    } else {
        
        _rc_committee=rc_committee;
        
        NSLog(@"SETTING COMMITTEE: %@ %@ %@",rc_committee.room,rc_committee.time,rc_committee.dow);
        
        CommitteeHeaderView *chv = [[[NSBundle mainBundle] loadNibNamed:@"CommitteeHeaderView-iPhone" owner:self options:nil] lastObject];
        
        chv.chamberLabel.text=self.rc_committee.body;
        chv.committeeNameLabel.text=self.rc_committee.name;
        
        //if ((self.committee.dow != nil) && (self.committee.time != nil)) {
            chv.meetsLabel.text = [NSString stringWithFormat:@"%@%@%@",
                ([self.rc_committee.dow length]==0?@"":self.rc_committee.dow),
                ([self.rc_committee.time length]==0?@"":@" "),
                ([self.rc_committee.time length]==0?@"":[NSString stringWithFormat:@"@ %@",self.rc_committee.time])
                ];
        //} else {
        //    chv.meetsLabel.text=nil;
        //}

            
        chv.committeeSubtypeLabel.text=self.rc_committee.type;
        
        CGSize size = [chv.meetsLabel sizeThatFits:chv.meetsLabel.frame.size];
        
        chv.meetsLabel.frame = CGRectMake(chv.meetsLabel.frame.origin.x,
                                          chv.meetsLabel.frame.origin.y,
                                          size.width,
                                          size.height);
        chv.roomLabel.text = self.rc_committee.room;
        
        if (chv.roomLabel.text==nil || [chv.roomLabel.text trim].length==0) {
            chv.roomLabelLabel.hidden=YES;
        } else {
            chv.roomLabelLabel.hidden=NO;	
        }
        
        if ([chv.meetsLabel.text length]==0 || [chv.meetsLabel.text trim].length==0) {
            chv.meetsLabelLabel.hidden=YES;
        } else {
            chv.meetsLabelLabel.hidden=NO;
        }
        
        self.committeeHeaderView=chv;
    }
}



#pragma mark - Table view data source

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.filteredSections==nil) return 0;
    return [self.filteredSections count]+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.filteredSections!=nil && section==0) return 1; // Search View Cell
    if (self.filteredSections==nil || [self.filteredSections count]<=(section-1)) return 0;

    ListSection *listSection = [self.filteredSections objectAtIndex:(section-1)];
    
    NSUInteger rowCount = 0;
    
    if ( ([self.filteredSections count]+1==2) && ([listSection.children count]<4)) {
        rowCount=4;
    } else {
        rowCount = [listSection.children count];
    }
    
    if (self.committeeHeaderView!=nil && section == 1) {
        rowCount+=1;
    }

    self.sectionTally = [Tally new];
    [self.sectionTally initWithParams:rowCount];

    NSString *listSectionTitle = listSection.title;
    rc_Realm_tally *realmTally = [[rc_Realm_tally objectsWhere:@"name == %@ AND body == %@", listSectionTitle, self.rc_committee.body] firstObject];

    
    if (!realmTally) {
        rc_Realm_tally *firstTally = [[rc_Realm_tally alloc] init];
        firstTally.name = listSectionTitle;
        firstTally.body = self.rc_committee.body;
        if (self.committeeHeaderView != nil) {
            firstTally.voteCount = rowCount-1;
        } else {
            firstTally.voteCount = rowCount;
        }
        
        int i;
        for (i=0; i<rowCount; i++) {
            rc_Realm_vote *blankVote = [[rc_Realm_vote alloc] init];
            blankVote.status = @"Unknown";
            [firstTally.votes addObject:blankVote];
            self.sectionTally.votes[i] = blankVote.status;
        }
        
        self.parent = [rc_Realm_tally_parent new];
        [self.parent.tallies addObject:firstTally];
        RLMRealm *realm = RLMRealm.defaultRealm;
        [realm transactionWithBlock:^{
            [realm addObject:self.parent];
        }];
    }
    
    
    self.rc_headerYesVotes = 0;
    self.rc_headerNoVotes = 0;
    self.rc_headerUnknownVotes = 0;
    NSString *voteStatus = [[NSString alloc] init];
    NSInteger i;
    for (i=0; i<realmTally.voteCount; i++) {
        voteStatus = realmTally.votes[i].status;
        if ([voteStatus isEqual:@"Yea"]) {
            self.rc_headerYesVotes++;
        } else if ([voteStatus isEqual:@"Nay"]) {
            self.rc_headerNoVotes++;
        } else {
            self.rc_headerUnknownVotes++;
        }
    }
    
    
    
    //[tableView registerNib:[UINib nibWithNibName:@"CustomTableViewHeader" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CustomIdentifier"];
    
    //int i;
    
    //for (i=0; i<rowCount; i++)
    //{
    //    self.parent.tallies[0].votes[i] = [Realm_vote new];
    //    self.parent.tallies[0].votes[i].status = @"Unknown";
    //}

    [self.rc_peopleTable
     
     registerNib:[UINib nibWithNibName:@"VoteTallyHeaderView-iPhone" bundle:nil] forCellReuseIdentifier:@"TableHeader"];

    
    
    
    
    return rowCount;
}


-(void) sumVotes:(rc_Realm_tally *)realmTally {
    self.rc_headerYesVotes = 0;
    self.rc_headerNoVotes = 0;
    self.rc_headerUnknownVotes = 0;
    NSString *voteStatus = [[NSString alloc] init];
    NSInteger i;
    for (i=0; i<realmTally.voteCount; i++) {
        voteStatus = realmTally.votes[i].status;
        if ([voteStatus isEqual:@"Yea"]) {
            self.rc_headerYesVotes++;
        } else if ([voteStatus isEqual:@"Nay"]) {
            self.rc_headerNoVotes++;
        } else {
            self.rc_headerUnknownVotes++;
        }
    }
}


-(void) emailTallyButtonTapped:(UIButton *)sender forEvent:(UIEvent *)event {
    NSLog(@"Email Tally Button Tapped");
    
    ListSection *listSection = [self.rc_sections objectAtIndex:0];
    NSString *sectionTitle = listSection.title;
    
    NSString *sectionTitleEncoded = [sectionTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableArray *sharingArray = [[NSMutableArray alloc] init];
    [sharingArray addObject:@"Hey"];
    [self shareItemToOtherApp:sharingArray];
}


-(void) populateHeaderVotes:(rc_Realm_tally *)activeTally{
    [self sumVotes:activeTally];
    
    UILabel *yeaHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:11];
    yeaHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerYesVotes];
    
    UILabel *nayHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:12];
    nayHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerNoVotes];
    
    UILabel *undecidedHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:13];
    undecidedHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerUnknownVotes];
}


-(rc_Realm_tally *) getActiveTally {
    ListSection *listSection = [self.rc_sections objectAtIndex:0];
    NSString *sectionTitle = listSection.title;
    rc_Realm_tally *activeTally = [[rc_Realm_tally objectsWhere:@"name == %@ AND body == %@", sectionTitle, self.rc_committee.body] firstObject];
    return activeTally;
}

-(void) rc_yeaButtonTapped:(UIButton *)sender forEvent:(UIEvent *)event {

    NSInteger rowTapped = [sender.titleLabel.text integerValue];
    

    
    ListSection *listSection = [self.rc_sections objectAtIndex:0];
    NSString *sectionTitle = listSection.title;
    rc_Realm_tally *realmTally = [[rc_Realm_tally objectsWhere:@"name == %@ AND body == %@", sectionTitle, self.rc_committee.body] firstObject];

    
    
    

    
    NSString *yeaBoxStatus = [[NSString alloc] init];
    if ([realmTally.votes[rowTapped].status isEqual:@"Yea"]) {
        yeaBoxStatus = @"blank";
    } else {
        yeaBoxStatus = @"Yea";
    }
    
    RLMRealm *realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];
    realmTally.votes[rowTapped].status = yeaBoxStatus;
    [realm commitWriteTransaction];

    //if (self.committeeHeaderView!=nil) {
    //    rowTapped++;
    //}
    if ([realmTally.votes[rowTapped].status isEqualToString:@"Yea"]) {
        [sender setImage:[UIImage imageNamed:@"CheckYea.png"] forState:UIControlStateNormal];
        [self.sectionTally.nayButtonRef[rowTapped] setImage:[UIImage imageNamed:@"BlankNay.png"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"BlankYeaSlice.png"]forState:UIControlStateNormal];
    }
    
    //NSUInteger yeaCount = [[Realm_tally objectsWhere:@"name == %@ AND body == %@", sectionTitle, self.committee.body] count];
    
    self.rc_headerYesVotes = 0;
    self.rc_headerNoVotes = 0;
    self.rc_headerUnknownVotes = 0;
    NSString *voteStatus = [[NSString alloc] init];
    NSInteger i;
    for (i=0; i<realmTally.voteCount; i++) {
        voteStatus = realmTally.votes[i].status;
        if ([voteStatus isEqual:@"Yea"]) {
            self.rc_headerYesVotes++;
        } else if ([voteStatus isEqual:@"Nay"]) {
            self.rc_headerNoVotes++;
        } else {
            self.rc_headerUnknownVotes++;
        }
    }

    UILabel *yeaHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:11];
    yeaHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerYesVotes];

    UILabel *nayHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:12];
    nayHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerNoVotes];
    
    UILabel *undecidedHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:13];
    undecidedHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerUnknownVotes];
}



-(void) rc_nayCheckButtonTapped:(UIButton *) sender forEvent:(UIEvent *)event {
    
    NSInteger rowTapped = [sender.titleLabel.text integerValue];
    ListSection *listSection = [self.rc_sections objectAtIndex:0];
    NSString *sectionTitle = listSection.title;
    rc_Realm_tally *realmTally = [[rc_Realm_tally objectsWhere:@"name == %@ AND body == %@", sectionTitle, self.rc_committee.body] firstObject];
    
    NSString *nayBoxStatus = [[NSString alloc] init];
    if ([realmTally.votes[rowTapped].status isEqual:@"Nay"]) {
        nayBoxStatus = @"blank";
    } else {
        nayBoxStatus = @"Nay";
    }
    
    RLMRealm *realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];
    realmTally.votes[rowTapped].status = nayBoxStatus;
    [realm commitWriteTransaction];
    
    //if (self.committeeHeaderView!=nil) {
    //    rowTapped++;
    //}
    if ([realmTally.votes[rowTapped].status isEqualToString:@"Nay"]) {
        [sender setImage:[UIImage imageNamed:@"CheckNay.png"] forState:UIControlStateNormal];
        [self.sectionTally.yeaButtonRef[rowTapped] setImage:[UIImage imageNamed:@"BlankYeaSlice.png"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"BlankNay.png"]forState:UIControlStateNormal];
    }

    self.rc_headerYesVotes = 0;
    self.rc_headerNoVotes = 0;
    self.rc_headerUnknownVotes = 0;
    NSString *voteStatus = [[NSString alloc] init];
    NSInteger i;
    for (i=0; i<realmTally.voteCount; i++) {
        voteStatus = realmTally.votes[i].status;
        if ([voteStatus isEqual:@"Yea"]) {
            self.rc_headerYesVotes++;
        } else if ([voteStatus isEqual:@"Nay"]) {
            self.rc_headerNoVotes++;
        } else {
            self.rc_headerUnknownVotes++;
        }
    }
    
    UILabel *yeaHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:11];
    yeaHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerYesVotes];
    
    UILabel *nayHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:12];
    nayHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerNoVotes];
    
    UILabel *undecidedHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:13];
    undecidedHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerUnknownVotes];
    
    
//    NSInteger rowTapped = [sender.titleLabel.text integerValue];
//    
//    UITouch *touch = [[event allTouches] anyObject];
//    
//    if (touch.tapCount > 0) {
//        if ([self.sectionTally.votes[rowTapped] isEqual:@"Nay"]) {
//            self.sectionTally.votes[rowTapped] = @"blank";
//        } else {
//            self.sectionTally.votes[rowTapped] = @"Nay";
//        }
//    }
//    
//    if ([self.sectionTally.votes[rowTapped] isEqualToString:@"Nay"]) {
//        [sender setImage:[UIImage imageNamed:@"CheckNay.png"] forState:UIControlStateNormal];
//        [self.sectionTally.yeaButtonRef[rowTapped] setImage:[UIImage imageNamed:@"BlankYeaSlice.png"] forState:UIControlStateNormal];
//    } else {
//        [sender setImage:[UIImage imageNamed:@"BlankNay.png"]forState:UIControlStateNormal];
//    }
}


-(NSString *) getTallyReport {
    
    NSString *tallyReport = [[NSString alloc] init];
    
    ListSection *listSection = [self.rc_sections objectAtIndex:0];
    NSString *sectionTitle = listSection.title;
    rc_Realm_tally *activeTally = [[rc_Realm_tally objectsWhere:@"name == %@ AND body == %@", sectionTitle, self.rc_committee.body] firstObject];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *dateToday = [formatter stringFromDate:[NSDate date]];
    tallyReport = [NSString stringWithFormat:@"My %@ Vote Prediction of %@\nYeas: %ld  Nays: %ld  Unknown: %ld\n", sectionTitle, dateToday, (long)self.rc_headerYesVotes,
                   (long)self.rc_headerNoVotes, (long)self.rc_headerUnknownVotes];
    
    
    CommitteeMember *member = nil;
    NSDictionary *person = nil;

    for (int i=0; i < listSection.children.count; i++) {
        if ( [[listSection.children objectAtIndex:i] isKindOfClass:[CommitteeMember class]]) {
            
            member = [listSection.children objectAtIndex:i];
            person = member.person;
        } else {
            person = [listSection.children objectAtIndex:i];
        }
        tallyReport = [NSString stringWithFormat:@"%@%@ %@: %@\n", tallyReport, person.firstName, person.lastName, activeTally.votes[i].status];

    }

    NSLog(@"Tally Report %@", tallyReport);

    //if ( [[section.children objectAtIndex:row] isKindOfClass:[CommitteeMember class]]) {
        
    //    member = [section.children objectAtIndex:0];
    //    person = member.person;
    //} else {
    //    person = [section.children objectAtIndex:0];
    //}

    NSString *voteStatus = [[NSString alloc] init];


    
    
    return tallyReport;
}


-(void)shareItemToOtherApp:(NSMutableArray *)shareItems{

    ListSection *listSection = [self.rc_sections objectAtIndex:0];
    NSString *sectionTitle = listSection.title;
    NSString *tallyToShare = [[NSString alloc] init];
    
    tallyToShare = [self getTallyReport];
    
    NSArray* dataToShare = @[tallyToShare];
    //UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    //activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
    //[self.viewController presentViewController:activityViewController animated:YES completion:^{}];
    
    
    
    
    //UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    //activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
    //[self.viewController presentViewController:activityViewController animated:YES completion:^{}];
    
    
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *dateToday = [formatter stringFromDate:[NSDate date]];
    NSString *subject = [[NSString alloc] init];
    subject = [NSString stringWithFormat:@"My %@ Vote Tally, %@", sectionTitle, dateToday];
    


    
    
    
    //UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[text, URL, image] applicationActivities:nil];
    //activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList];
    
    // check if new API supported
    if ([activityViewController respondsToSelector:@selector(completionWithItemsHandler)]) {
        activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            [self sharingCompleted];
        };
    }
    
    
    
    
    
    
    
    
    [activityViewController setValue:subject forKey:@"subject"];
    [self.rc_viewController presentViewController:activityViewController animated:YES completion:NULL];
    
    
    //UIActivityViewController *shareController = [[UIActivityViewController alloc]
    //                                             initWithActivityItems: shareItems applicationActivities :nil];
    
    //[shareController setValue:@"Sharing" forKey:@"subject"];
    //shareController.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll];
    
    //UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    //[self.viewController presentViewController:controller animated:YES completion:nil];
    
    
    
    
    
    //shareController.completionHandler = ^(NSString *activityType, BOOL completed)
    //{
    //    NSLog(@" activityType: %@", activityType);
    //    NSLog(@" completed: %i", completed);
    //};
    
    //[self presentViewController: shareController animated: YES completion: nil];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(nullable UIActivityType)activityType {
    return @"Hey Mon Subject";
}


- (void) sharingCompleted {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OAEC Roll Call Tally"
                                                    message:@"Sharing complete"
                                                   delegate:self
                                          cancelButtonTitle:@"Clear"
                                          otherButtonTitles:@"Retain", nil];
    [alert show];
    [alert release];
}


- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alert buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Clear"])
    {
        [self clearCurrentTally];
    }

}

- (void) clearCurrentTally {

    RLMRealm *realm = RLMRealm.defaultRealm;
    rc_Realm_tally *activeTally = [[rc_Realm_tally alloc] init];
    activeTally = [self getActiveTally];
    
    [realm beginWriteTransaction];
    int i;
    for (i=0; i<activeTally.voteCount; i++) {
        activeTally.votes[i].status = @"Unknown";
    }
    [realm commitWriteTransaction];
    
    [self.rc_peopleTable reloadData];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *BlankCellIdentifier = @"BlankCell";
    UITableViewCell *blankCell = [tableView dequeueReusableCellWithIdentifier:BlankCellIdentifier];
    
    if (blankCell==nil) {
        blankCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BlankCellIdentifier];
        blankCell.selectionStyle=UITableViewCellSelectionStyleNone;
        blankCell.backgroundColor=[UIColor clearColor];
    }
    
    if (indexPath.section==0 && indexPath.row==0) {
        //return self.searchViewCell;
        return blankCell;
    }
    
    if (indexPath.section==1 && indexPath.row==0 && self.committeeHeaderView!=nil) {
        return self.committeeHeaderView;
    }

    NSInteger row = indexPath.row;
    
    if (indexPath.section==1 && self.committeeHeaderView!=nil) {
        row--;
    }
    
    ListSection *section = [[ListSection alloc] init];
    
    if (indexPath.section == 0) {
        section = [self.filteredSections objectAtIndex:(indexPath.section)];
    } else {
        section = [self.filteredSections objectAtIndex:(indexPath.section-1)];
    }
        
    if (row >= [section.children count]) {
        return blankCell;
    }
    
    CommitteeMember *member = nil;
    NSDictionary *person = nil;
    
    
    if ( [[section.children objectAtIndex:row] isKindOfClass:[CommitteeMember class]]) {
        
        member = [section.children objectAtIndex:row];
        person = member.person;
    } else {
        person = [section.children objectAtIndex:row];
    }
    

    
    static NSString *CellIdentifier = @"VotingListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        //cell =  [[[NSBundle mainBundle] loadNibNamed:@"PeopleListCell-iPhone" owner:nil options:nil] objectAtIndex:0];
        cell =  [[[NSBundle mainBundle] loadNibNamed:@"VotingListCell-iPhone" owner:nil options:nil] objectAtIndex:0];
    }
    


    
    if ([@"vacant" caseInsensitiveCompare:person.firstName]==NSOrderedSame) {
        CELL_NAME.text = @"Seat Vacant";
    } else {
        CELL_NAME.text = [NSString stringWithFormat:@"%@ %@",person.firstName,person.lastName];
    }
    
    CELL_TITLE.text=@"";
    CELL_SUBTITLE.text=@"";
    CELL_DISTRICT.text=@"";
    CELL_DISTRICT.textColor=[UIColor lightGrayColor];
    
    if ([person.party isEqualToString:@"R"]) CELL_DISTRICT.textColor=[UIColor redColor];
    if ([person.party isEqualToString:@"D"]) CELL_DISTRICT.textColor=[UIColor blueColor];
    
    CELL_TITLE.frame = CGRectMake(CELL_TITLE.frame.origin.x, CELL_TITLE.frame.origin.y, 124.0f, CELL_TITLE.frame.size.height);
    
    if ([person.type isEqualToString:STATE_HOUSE]) {
        CELL_TITLE.text=@"Oklahoma Representative";
        CELL_SUBTITLE.text=person.titleLeadership;
        CELL_DISTRICT.text = [NSString stringWithFormat:@"%@%@District %@",person.party,((person.party==nil || [[person.party trim] length]==0)?@"":@"-"),person.districtNumber];
    } else if ([person.type isEqualToString:STATE_SENATE]) {
        CELL_TITLE.text=@"Oklahoma Senator";
        CELL_SUBTITLE.text=person.titleLeadership;
        CELL_DISTRICT.text = [NSString stringWithFormat:@"%@%@District %@",person.party,((person.party==nil || [[person.party trim] length]==0)?@"":@"-"),person.districtNumber];
    } else if ([person.type isEqualToString:STATEWIDE]) {
        CELL_TITLE.text=person.titleLeadership;
        CELL_DISTRICT.text = person.party;
    } else if ([person.type isEqualToString:FEDERAL_HOUSE]) {
        CELL_TITLE.text=@"US Representative";
        CELL_SUBTITLE.text=person.titleLeadership;
        CELL_DISTRICT.text = [NSString stringWithFormat:@"%@%@District %@",person.party,((person.party==nil || [[person.party trim] length]==0)?@"":@"-"),person.districtNumber];
    } else if ([person.type isEqualToString:FEDERAL_SENATE]) {
        CELL_TITLE.text=@"US Senator";
        CELL_SUBTITLE.text=person.titleLeadership;
        CELL_DISTRICT.text = person.party;
    } else if ([person.type isEqualToString:OAEC_MEMBER]) {
        CELL_TITLE.frame = CGRectMake(CELL_TITLE.frame.origin.x, CELL_TITLE.frame.origin.y, 222.0f, CELL_TITLE.frame.size.height);
        CELL_TITLE.text=person.coopName;
        CELL_SUBTITLE.text=person.titleLeadership;
    } else if ([person.type isEqualToString:LEGISLATIVE_CONTACT]) {
        CELL_TITLE.frame = CGRectMake(CELL_TITLE.frame.origin.x, CELL_TITLE.frame.origin.y, 222.0f, CELL_TITLE.frame.size.height);
        CELL_TITLE.text=person.coopName;
        CELL_SUBTITLE.text=person.titleLeadership;
    } else if ([person.type isEqualToString:STATE_JUDICIARY]) {
        CELL_TITLE.frame = CGRectMake(CELL_TITLE.frame.origin.x, CELL_TITLE.frame.origin.y, 222.0f, CELL_TITLE.frame.size.height);
        CELL_TITLE.text=@"State Supreme Court Justice";
        CELL_SUBTITLE.text=person.titleLeadership;
    }
    
    if (member!=nil) {
        if (member.title!=nil) {
            CELL_SUBTITLE.text = member.title;
        } else {
            CELL_SUBTITLE.text = @"";
        }
    }
    
    
    BOOL hasPhoto=NO;
    if (person.photo!=nil && [person.photo length]>0) {
        
        
        CELL_HEADSHOT.image=[UIImage imageNamed:person.photo];
        
        //NSLog(@"Attempt to load photo %@ %@",person.photo,(CELL_HEADSHOT.image==nil?@"FAILED":@"SUCCEEDED"));
        
        if (CELL_HEADSHOT.image!=nil) hasPhoto=YES;
    }
    
    if (hasPhoto) {
        CELL_HEADSHOT.hidden=NO;
        CELL_PHOTO_NA.hidden=YES;
    } else {
        CELL_HEADSHOT.hidden=YES;
        CELL_HEADSHOT.image=nil;
        CELL_PHOTO_NA.hidden=NO;
    }
    
    [self.yeaVotes addObject:@"false"];
    [self.nayVotes addObject:@"false"];
    
    //BOOL yeaChecked =  [[self.itsToDoChecked objectAtIndex:indexPath.row] boolValue];
    

    NSString *governmentBody = self.rc_committee.body;
    self.rc_tallyGroupTitle = section.title;
    rc_Realm_tally *realmTally = [[rc_Realm_tally objectsWhere:@"name == %@ AND body == %@", self.rc_tallyGroupTitle, governmentBody] firstObject];
    
    UIImage *yeaImage = [[UIImage alloc] init];
    if ([realmTally.votes[row].status isEqual:@"Yea"]) {
        yeaImage = [UIImage imageNamed:@"CheckYea.png"];
    } else {
        yeaImage = [UIImage imageNamed:@"BlankYeaSlice.png"];
    }
    
    
    UIButton *yeaButton = CELL_YEA_VOTE;
    UIButton *nayButton = CELL_NAY_VOTE;
    self.sectionTally.yeaButtonRef[row] = yeaButton;
    self.sectionTally.nayButtonRef[row] = nayButton;
    

    [yeaButton setImage:yeaImage forState:UIControlStateNormal];
    [yeaButton setTitle:[NSString stringWithFormat:@"%ld",(long)row] forState:UIControlStateNormal];
    [yeaButton setTitleColor:yeaButton.backgroundColor forState:UIControlStateNormal];
    // set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
    [yeaButton addTarget:self action:@selector(rc_yeaButtonTapped:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    //BOOL checked =  [[itsToDoChecked objectAtIndex:indexPath.row] boolValue];
    //UIImage *nayImage = [UIImage imageNamed:@"BlankNay.png"];

    UIImage *nayImage = [[UIImage alloc] init];
    if ([realmTally.votes[row].status isEqual:@"Nay"]) {
        nayImage = [UIImage imageNamed:@"CheckNay.png"];
    } else {
        nayImage = [UIImage imageNamed:@"BlankNay.png"];
    }
    
    [nayButton setImage:nayImage forState:UIControlStateNormal];
    [nayButton setTitle:[NSString stringWithFormat:@"%ld",(long)row] forState:UIControlStateNormal];
    [nayButton setTitleColor:nayButton.backgroundColor forState:UIControlStateNormal];
    // set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
    [nayButton addTarget:self action:@selector(rc_nayCheckButtonTapped:forEvent:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

#pragma mark - Table view delegate

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    //CustomTableViewHeaderCell * customHeaderCell = [[CustomTableViewHeaderCell alloc] init];
    if (section == 1) {
        self.rc_customHeaderCell = [tableView dequeueReusableCellWithIdentifier:@"TableHeader"];
        self.rc_customHeaderCell
        
        
        
        .backgroundColor = [UIColor colorWithWhite: 1.0 alpha:1.0];
    
        //UILabel *label = (UILabel *)[self.customHeaderCell.contentView viewWithTag:21];
        //label.text = @"Hey man";
        //customHeaderCell.title.text = @"Hey";
        //customHeaderCell.title.text = @"Hey";
        
        
        
        UILabel *headerTitle = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:10];
        headerTitle.text = [NSString stringWithFormat:@"Your %@ Roll Call Tally", self.rc_tallyGroupTitle];
        

        
        UILabel *yeaHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:11];
        yeaHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerYesVotes];
        
        UILabel *nayHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:12];
        nayHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerNoVotes];
        
        UILabel *undecidedHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:13];
        undecidedHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerUnknownVotes];


        yeaHeaderLabel.layer.borderColor = [UIColor greenColor].CGColor;
        yeaHeaderLabel.layer.borderWidth = 4.0;
        nayHeaderLabel.layer.borderColor = [UIColor redColor].CGColor;
        nayHeaderLabel.layer.borderWidth = 4.0;
        undecidedHeaderLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        undecidedHeaderLabel.layer.borderWidth = 4.0;
        
        UIButton *emailTallyButton = (UIButton *)[self.rc_customHeaderCell.contentView viewWithTag:14];
        
        [emailTallyButton addTarget:self action:@selector(emailTallyButtonTapped:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        //PersonViewController *pvc = [[[PersonViewController alloc] initWithNibName:@"PersonView-iPhone" bundle:nil] autorelease];
        //[pvc emailButtonPressed:sender];

    }
    else {
        self.rc_customHeaderCell =  nil;
    }
    
    
    
   return self.rc_customHeaderCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 150.0;
    } else {
        return 0.0;
    }
}



- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0 && indexPath.row==0) {
        //return SEARCH_VIEW_HEIGHT;
        return 0;
    }
    
    if (indexPath.section==1 && indexPath.row==0 && self.committeeHeaderView!=nil) {
        
        if ( (self.rc_committee.dow==nil || [self.rc_committee.dow trim].length==0) &&
            (self.rc_committee.time==nil || [self.rc_committee.time trim].length==0) &&
            (self.rc_committee.room==nil || [self.rc_committee.room trim].length==0) ) {
            return 73.0;
        }
        NSLog(@"self.committeeHeaderView.frame.size.height = %f",self.committeeHeaderView.frame.size.height);
        return self.committeeHeaderView.frame.size.height;
    }
    
    return 104.0f;
}

-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //if (indexPath.section==0 && indexPath.row==0) return nil;
    //return indexPath;

    
    NSInteger rowTapped = indexPath.row;
    
    if (self.committeeHeaderView!=nil) {
        rowTapped--;
    }
    
    ListSection *listSection = [self.rc_sections objectAtIndex:0];
    NSString *sectionTitle = listSection.title;
    rc_Realm_tally *realmTally = [[rc_Realm_tally objectsWhere:@"name == %@ AND body == %@", sectionTitle, self.rc_committee.body] firstObject];
    
    
    NSString *voteStatus = [[NSString alloc] init];
    if ([realmTally.votes[rowTapped].status isEqual:@"Yea"]) {
        voteStatus = @"Nay";
    } else if ([realmTally.votes[rowTapped].status isEqual:@"Nay"]){
        voteStatus = @"Unknown";
    } else {
        voteStatus = @"Yea";
    }
    
    RLMRealm *realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];
    realmTally.votes[rowTapped].status = voteStatus;
    [realm commitWriteTransaction];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIButton *yeaButton = CELL_YEA_VOTE;
    UIButton *nayButton = CELL_NAY_VOTE;
    self.sectionTally.yeaButtonRef[rowTapped] = yeaButton;
    self.sectionTally.nayButtonRef[rowTapped] = nayButton;
    
    UIImage *yeaImage = [[UIImage alloc] init];
    if ([realmTally.votes[rowTapped].status isEqual:@"Yea"]) {
        yeaImage = [UIImage imageNamed:@"CheckYea.png"];
    } else {
        yeaImage = [UIImage imageNamed:@"BlankYeaSlice.png"];
    }
    [yeaButton setImage:yeaImage forState:UIControlStateNormal];
    
    //BOOL checked =  [[itsToDoChecked objectAtIndex:indexPath.row] boolValue];
    //UIImage *nayImage = [UIImage imageNamed:@"BlankNay.png"];
    
    UIImage *nayImage = [[UIImage alloc] init];
    if ([realmTally.votes[rowTapped].status isEqual:@"Nay"]) {
        nayImage = [UIImage imageNamed:@"CheckNay.png"];
    } else {
        nayImage = [UIImage imageNamed:@"BlankNay.png"];
    }
    [nayButton setImage:nayImage forState:UIControlStateNormal];
    
    self.rc_headerYesVotes = 0;
    self.rc_headerNoVotes = 0;
    self.rc_headerUnknownVotes = 0;
    NSInteger i;
    for (i=0; i<realmTally.voteCount; i++) {
        voteStatus = realmTally.votes[i].status;
        if ([voteStatus isEqual:@"Yea"]) {
            self.rc_headerYesVotes++;
        } else if ([voteStatus isEqual:@"Nay"]) {
            self.rc_headerNoVotes++;
        } else {
            self.rc_headerUnknownVotes++;
        }
    }
    
    UILabel *yeaHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:11];
    yeaHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerYesVotes];
    
    UILabel *nayHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:12];
    nayHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerNoVotes];
    
    UILabel *undecidedHeaderLabel = (UILabel *)[self.rc_customHeaderCell.contentView viewWithTag:13];
    undecidedHeaderLabel.text = [NSString stringWithFormat:@"%ld", (long)self.rc_headerUnknownVotes];
    
    
    
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    ListSection *section = [self.filteredSections objectAtIndex:(indexPath.section-1)];
    CommitteeMember *member = nil;
    NSDictionary *person = nil;
    
    NSInteger index = indexPath.row;
    
    if (indexPath.section==1 && self.committeeHeaderView!=nil && indexPath.row==0) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (self.rc_committee.website!=nil && [self.rc_committee.website trim].length>0) {
            NSURL *url = [NSURL URLWithString:[self.rc_committee.website trim]];
            [[UIApplication sharedApplication] openURL:url];
        }
        return;
    }
    
    if (indexPath.section==1 && self.committeeHeaderView!=nil) index-=1;
    
    if (index >= [section.children count]) return;
    
    if ([[section.children objectAtIndex:index] isKindOfClass:[CommitteeMember class]]) {
        member = [section.children objectAtIndex:index];
        person = member.person;
    } else {
        person = [section.children objectAtIndex:index];
    }
    
    PersonViewController *pvc = [[[PersonViewController alloc] initWithNibName:@"PersonView-iPhone" bundle:nil] autorelease];
    
    pvc.person=person;
    
}

- (void)dealloc
{
    //if (_searchViewCell!=nil) _searchViewCell.searchBar.delegate=nil;
    [SearchViewCell release];
    [_rc_sections release];
    [CommitteeHeaderView release];
    [super dealloc];
}

@end
