//
//  PeopleListDelegate.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/26/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "VotingListDelegate.h"
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
//#import "voteButton.h"
#import <Realm/Realm.h>

#define CELL_HEADSHOT       ((UIImageView *)[cell viewWithTag:100])
#define CELL_NAME           ((UILabel *)[cell viewWithTag:101])
#define CELL_TITLE          ((UILabel *)[cell viewWithTag:102])
#define CELL_SUBTITLE       ((UILabel *)[cell viewWithTag:103])
#define CELL_DISTRICT       ((UILabel *)[cell viewWithTag:104])
#define CELL_PHOTO_NA       ((UIView *)[cell viewWithTag:105])
#define CELL_YEA_VOTE       ((UIButton *)[cell viewWithTag:106])
#define CELL_NAY_VOTE       ((UIButton *)[cell viewWithTag:107])


// Data models: GroupParent contains all of the data for a TableView, with a
// Group per section and an Entry per row in each section
RLM_ARRAY_TYPE(Realm_vote)
RLM_ARRAY_TYPE(Realm_tally)

@interface Realm_vote : RLMObject
@property (nonatomic, strong) NSString *status;
@end

@interface Realm_tally : RLMObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *body;
@property (nonatomic) NSInteger voteCount;
@property (nonatomic, strong) RLMArray<Realm_vote *><Realm_vote> *votes;
@end

@interface Realm_tally_parent : RLMObject
@property (nonatomic, strong) RLMArray<Realm_tally *><Realm_tally> *tallies;
@end

@implementation Realm_vote
// Nothing needed
@end
@implementation Realm_tally
// Nothing needed
@end
@implementation Realm_tally_parent
// Nothing needed
@end






@interface VotingListDelegate ()

@property (readonly) SearchViewCell *searchViewCell;
@property (nonatomic, strong) NSMutableArray *filteredSections;
@property (retain, nonatomic) UITableViewCell *committeeHeaderView;
@property (nonatomic, strong) NSMutableArray *yeaVotes;
@property (nonatomic, strong) NSMutableArray *nayVotes;
@property (nonatomic, strong) Tally *sectionTally;
@property (nonatomic, strong) Realm_tally_parent *parent;



-(void) buildDisplaySections;

@end

@implementation VotingListDelegate

@synthesize sections=_sections;
@synthesize viewController=_viewController;
@synthesize searchViewCell=_searchViewCell;
@synthesize peopleTable=_peopleTable;
@synthesize filteredSections=_filteredSections;
@synthesize committee=_committee;
@synthesize committeeHeaderView=_committeeHeaderView;

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
    [self.peopleTable reloadData];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    // called when bookmark button pressed
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    // called when cancel button pressed
    [self buildDisplaySections];
    [self.peopleTable reloadData];

    if (self.peopleTable!=nil && self.filteredSections!=nil && [self.filteredSections count]>0) {
        [self.peopleTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    [self.peopleTable reloadData];
}

#pragma mark - Filter 

-(void)setSections:(NSArray *)sections {

    if (_sections!=nil) {
        [_sections release];
        _sections=nil; 
    }
    
    _sections = [sections retain];
    [self buildDisplaySections];
}

-(void) buildDisplaySections {

    [self buildDisplaySectionsWithFilterType:99 filterText:nil];
}

-(void) buildDisplaySectionsWithFilterType:(NSInteger)filterType filterText:(NSString *) filterText {

    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (self.filteredSections==nil) {
        self.filteredSections = [NSMutableArray arrayWithCapacity:[self.sections count]];
        [defaults setObject:false forKey:@"yeaStatus"];
    }
    [self.filteredSections removeAllObjects];
    
    if ([self.sections count]==0) return;
    
    
    for(ListSection *section in self.sections) {
        
        
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
    
    if (_searchViewCell==nil) {
        _searchViewCell = [[[[NSBundle mainBundle] loadNibNamed:@"PeopleListSearchCell-iPhone" owner:self options:nil] objectAtIndex:0] retain];
        _searchViewCell.searchBar.delegate=self;
        _searchViewCell.searchBar.showsCancelButton=NO;
    }
    
    return _searchViewCell;
}

#pragma mark - Property Overides

-(void) setCommittee:(Committee *)committee {
    if (committee==nil) {
        self.committeeHeaderView=nil;
        _committee=nil;
    } else {
        
        _committee=committee;
        
        NSLog(@"SETTING COMMITTEE: %@ %@ %@",committee.room,committee.time,committee.dow);
        
        CommitteeHeaderView *chv = [[[NSBundle mainBundle] loadNibNamed:@"CommitteeHeaderView-iPhone" owner:self options:nil] lastObject];
        
        chv.chamberLabel.text=self.committee.body;
        chv.committeeNameLabel.text=self.committee.name;
        
        //if ((self.committee.dow != nil) && (self.committee.time != nil)) {
            chv.meetsLabel.text = [NSString stringWithFormat:@"%@%@%@",
                ([self.committee.dow length]==0?@"":self.committee.dow),
                ([self.committee.time length]==0?@"":@" "),
                ([self.committee.time length]==0?@"":[NSString stringWithFormat:@"@ %@",self.committee.time])
                ];
        //} else {
        //    chv.meetsLabel.text=nil;
        //}

            
        chv.committeeSubtypeLabel.text=self.committee.type;
        
        CGSize size = [chv.meetsLabel sizeThatFits:chv.meetsLabel.frame.size];
        
        chv.meetsLabel.frame = CGRectMake(chv.meetsLabel.frame.origin.x,
                                          chv.meetsLabel.frame.origin.y,
                                          size.width,
                                          size.height);
        chv.roomLabel.text = self.committee.room;
        
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
    if (self.filteredSections==nil) return nil;

    if (section==0) return nil;
    
    if (section==1 && self.committeeHeaderView!=nil) return nil;
    
    if ([self.filteredSections count]<=(section-1)) return nil;
    ListSection *listSection = [self.filteredSections objectAtIndex:(section-1)];
    return listSection.title;
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
    

    //RLMRealm *realm = RLMRealm.defaultRealm;
    
    
    
    
    
    self.parent = Realm_tally_parent.allObjects.firstObject;
    NSLog(@"%@", self.parent.tallies[0].votes[0].status);
    NSLog(@"%@", self.parent.tallies[0].votes[1].status);
    NSLog(@"%@", self.parent.tallies[0].votes[2].status);
    NSLog(@"%@", self.parent.tallies[0].votes[3].status);
    NSLog(@"%@", self.parent.tallies[0].votes[4].status);

    NSString *listSectionTitle = listSection.title;
    NSLog(@"Section title: %@", listSection.title);
    Realm_tally *realmTally = [[Realm_tally objectsWhere:@"name == %@ AND body == %@", listSectionTitle, self.committee.body] firstObject];
    NSLog(@"Here's the name of the found entity: %@ in body: %@", realmTally.name, self.committee.body);

    if (realmTally) {
        int i;
        for (i=0; i<rowCount; i++) {
            //self.sectionTally.votes[i] = realmTally.votes[i].status;
        }
    } else {

        Realm_tally *firstTally = [[Realm_tally alloc] init];
        firstTally.name = listSectionTitle;
        firstTally.body = self.committee.body;
        firstTally.voteCount = rowCount;
        int i;
        for (i=0; i<rowCount; i++) {
            Realm_vote *blankVote = [[Realm_vote alloc] init];
            blankVote.status = @"Unknown";
            [firstTally.votes addObject:blankVote];
            self.sectionTally.votes[i] = blankVote.status;
        }
        
        self.parent = [Realm_tally_parent new];
        [self.parent.tallies addObject:firstTally];
        RLMRealm *realm = RLMRealm.defaultRealm;
        [realm transactionWithBlock:^{
            [realm addObject:self.parent];
        }];
    }
    

    
    //int i;
    
    //for (i=0; i<rowCount; i++)
    //{
    //    self.parent.tallies[0].votes[i] = [Realm_vote new];
    //    self.parent.tallies[0].votes[i].status = @"Unknown";
    //}
    
    
    return rowCount;
}

-(void) yeaButtonTapped:(UIButton *)sender forEvent:(UIEvent *)event {

    NSInteger rowTapped = [sender.titleLabel.text integerValue];
    ListSection *listSection = [self.sections objectAtIndex:0];
    NSString *sectionTitle = listSection.title;
    Realm_tally *realmTally = [[Realm_tally objectsWhere:@"name == %@ AND body == %@", sectionTitle, self.committee.body] firstObject];
    
    NSString *yeaBoxStatus = [[NSString alloc] init];
    if ([realmTally.votes[rowTapped].status isEqual:@"yea"]) {
        yeaBoxStatus = @"blank";
    } else {
        yeaBoxStatus = @"yea";
    }
    
    RLMRealm *realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];
    realmTally.votes[rowTapped].status = yeaBoxStatus;
    [realm commitWriteTransaction];

    if ([realmTally.votes[rowTapped].status isEqualToString:@"yea"]) {
        [sender setImage:[UIImage imageNamed:@"CheckYea.png"] forState:UIControlStateNormal];
        [self.sectionTally.nayButtonRef[rowTapped] setImage:[UIImage imageNamed:@"BlankNay.png"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"BlankYeaSlice.png"]forState:UIControlStateNormal];
    }
}


-(void) nayCheckButtonTapped:(UIButton *) sender forEvent:(UIEvent *)event {
    
    NSInteger rowTapped = [sender.titleLabel.text integerValue];
    ListSection *listSection = [self.sections objectAtIndex:0];
    NSString *sectionTitle = listSection.title;
    Realm_tally *realmTally = [[Realm_tally objectsWhere:@"name == %@ AND body == %@", sectionTitle, self.committee.body] firstObject];
    
    NSString *nayBoxStatus = [[NSString alloc] init];
    if ([realmTally.votes[rowTapped].status isEqual:@"nay"]) {
        nayBoxStatus = @"blank";
    } else {
        nayBoxStatus = @"nay";
    }
    
    RLMRealm *realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];
    realmTally.votes[rowTapped].status = nayBoxStatus;
    [realm commitWriteTransaction];
    
    if ([realmTally.votes[rowTapped].status isEqualToString:@"nay"]) {
        [sender setImage:[UIImage imageNamed:@"CheckNay.png"] forState:UIControlStateNormal];
        [self.sectionTally.yeaButtonRef[rowTapped] setImage:[UIImage imageNamed:@"BlankYeaSlice.png"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"BlankNay.png"]forState:UIControlStateNormal];
    }
    
//    NSInteger rowTapped = [sender.titleLabel.text integerValue];
//    
//    UITouch *touch = [[event allTouches] anyObject];
//    
//    if (touch.tapCount > 0) {
//        if ([self.sectionTally.votes[rowTapped] isEqual:@"nay"]) {
//            self.sectionTally.votes[rowTapped] = @"blank";
//        } else {
//            self.sectionTally.votes[rowTapped] = @"nay";
//        }
//    }
//    
//    if ([self.sectionTally.votes[rowTapped] isEqualToString:@"nay"]) {
//        [sender setImage:[UIImage imageNamed:@"CheckNay.png"] forState:UIControlStateNormal];
//        [self.sectionTally.yeaButtonRef[rowTapped] setImage:[UIImage imageNamed:@"BlankYeaSlice.png"] forState:UIControlStateNormal];
//    } else {
//        [sender setImage:[UIImage imageNamed:@"BlankNay.png"]forState:UIControlStateNormal];
//    }
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0 && indexPath.row==0) {
        return self.searchViewCell;
    }
    
    if (indexPath.section==1 && indexPath.row==0 && self.committeeHeaderView!=nil) {
        return self.committeeHeaderView;
    }

    NSInteger row = indexPath.row;
    
    if (indexPath.section==1 && self.committeeHeaderView!=nil) {
        row--;
    }
    
    ListSection *section = [self.filteredSections objectAtIndex:(indexPath.section-1)];
    
    if (row >= [section.children count]) {
        
        static NSString *BlankCellIdentifier = @"BlankCell";
        UITableViewCell *blankCell = [tableView dequeueReusableCellWithIdentifier:BlankCellIdentifier];

        if (blankCell==nil) {
            blankCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BlankCellIdentifier];
            blankCell.selectionStyle=UITableViewCellSelectionStyleNone;
            blankCell.backgroundColor=[UIColor clearColor];
        }
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
    

    NSString *governmentBody = self.committee.body;
    NSString *listSectionTitle = section.title;
    Realm_tally *realmTally = [[Realm_tally objectsWhere:@"name == %@ AND body == %@", listSectionTitle, governmentBody] firstObject];
    
    UIImage *yeaImage = [[UIImage alloc] init];
    if ([realmTally.votes[row].status isEqual:@"yea"]) {
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
    [yeaButton addTarget:self action:@selector(yeaButtonTapped:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    //BOOL checked =  [[itsToDoChecked objectAtIndex:indexPath.row] boolValue];
    //UIImage *nayImage = [UIImage imageNamed:@"BlankNay.png"];

    UIImage *nayImage = [[UIImage alloc] init];
    if ([realmTally.votes[row].status isEqual:@"nay"]) {
        nayImage = [UIImage imageNamed:@"CheckNay.png"];
    } else {
        nayImage = [UIImage imageNamed:@"BlankNay.png"];
    }
    
    [nayButton setImage:nayImage forState:UIControlStateNormal];
    [nayButton setTitle:[NSString stringWithFormat:@"%ld",(long)row] forState:UIControlStateNormal];
    [nayButton setTitleColor:nayButton.backgroundColor forState:UIControlStateNormal];
    // set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
    [nayButton addTarget:self action:@selector(nayCheckButtonTapped:forEvent:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}



- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

    NSLog(@"At accessoryButtonTappedForRowWithIndexPath" );

    //BOOL checked = [[itsToDoChecked objectAtIndex:indexPath.row] boolValue];
    //[itsToDoChecked removeObjectAtIndex:indexPath.row];
    //[itsToDoChecked insertObject:(checked) ? @"FALSE":@"TRUE" atIndex:indexPath.row];
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //UIButton *button = (UIButton *)cell.accessoryView;
    
    //UIImage *newImage = (checked) ? [UIImage imageNamed:@"unchecked.png"] : [UIImage imageNamed:@"checked.png"];
    //[button setBackgroundImage:newImage forState:UIControlStateNormal];
    
    //UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
    //                                                               //style:UIBarButtonItemStylePlain target:self action:@selector(saveChecklist:)];
    //self.navigationItem.rightBarButtonItem = backButton;
    //[backButton release];
    
}



#pragma mark - Table view delegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0 && indexPath.row==0) {
        return SEARCH_VIEW_HEIGHT;
    }
    
    if (indexPath.section==1 && indexPath.row==0 && self.committeeHeaderView!=nil) {
        
        if ( (self.committee.dow==nil || [self.committee.dow trim].length==0) &&
            (self.committee.time==nil || [self.committee.time trim].length==0) &&
            (self.committee.room==nil || [self.committee.room trim].length==0) ) {
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
        if (self.committee.website!=nil && [self.committee.website trim].length>0) {
            NSURL *url = [NSURL URLWithString:[self.committee.website trim]];
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
    
    //JWH [self.viewController.navigationController pushViewController:pvc animated:YES];

    
    /*
    if (indexPath.row>=[section.children count]) return;
    
    if ( [[section.children objectAtIndex:indexPath.row] isKindOfClass:[CommitteeMember class]]) {
        member = [section.children objectAtIndex:indexPath.row];
        person = member.person;
    } else {
        person = [section.children objectAtIndex:indexPath.row];
    }

    PersonViewController *pvc = [[[PersonViewController alloc] initWithNibName:@"PersonView-iPhone" bundle:nil] autorelease];
    
    pvc.person=person;
    
    [self.viewController.navigationController pushViewController:pvc animated:YES];
     
     */

}

- (void)dealloc
{
    if (_searchViewCell!=nil) _searchViewCell.searchBar.delegate=nil;
    [_searchViewCell release];
    [_sections release];
    [_committeeHeaderView release];
    [super dealloc];
}

@end
