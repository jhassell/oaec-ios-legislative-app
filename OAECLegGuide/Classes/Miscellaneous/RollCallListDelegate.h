//
//  PeopleListDelegate.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/26/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewHeaderCell.h"


#define SEARCH_VIEW_HEIGHT 88.0f

@class Committee;


@interface rc_alert : UIViewController <UIAlertViewDelegate> {
}
@end


@interface RollCallListDelegate : NSObject <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>


@property (nonatomic, strong) NSArray *rc_sections;
@property (nonatomic, assign) UIViewController<UISearchBarDelegate> *rc_viewController;
@property (nonatomic, assign) UITableView *rc_peopleTable;
@property (nonatomic, assign) Committee *rc_committee;
@property (nonatomic, strong) NSString *rc_yeaVoteEntry;
@property (nonatomic, strong) NSString *rc_nayVoteEntry;
@property (nonatomic, strong) CustomTableViewHeaderCell * rc_customHeaderCell;
@property (nonatomic, strong) NSString *rc_tallyGroupTitle;
@property (nonatomic) NSInteger rc_headerYesVotes;
@property (nonatomic) NSInteger rc_headerNoVotes;
@property (nonatomic) NSInteger rc_headerUnknownVotes;



-(void) rc_yeaButtonTapped:(UIButton *)sender forEvent:(UIEvent *)event;
-(void) rc_nayCheckButtonTapped:(UIButton *) sender forEvent:(UIEvent *)event;

@end
