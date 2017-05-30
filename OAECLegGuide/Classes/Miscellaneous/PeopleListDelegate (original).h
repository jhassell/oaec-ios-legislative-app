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


@interface alert : UIViewController <UIAlertViewDelegate> {
}
@end


@interface PeopleListDelegate : NSObject <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>


@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, assign) UIViewController<UISearchBarDelegate> *viewController;
@property (nonatomic, assign) UITableView *peopleTable;
@property (nonatomic, assign) Committee *committee;
@property (nonatomic, strong) NSString *yeaVoteEntry;
@property (nonatomic, strong) NSString *nayVoteEntry;
@property (nonatomic, strong) CustomTableViewHeaderCell * customHeaderCell;
@property (nonatomic, strong) NSString *tallyGroupTitle;
@property (nonatomic) NSInteger headerYesVotes;
@property (nonatomic) NSInteger headerNoVotes;
@property (nonatomic) NSInteger headerUnknownVotes;



-(void) yeaButtonTapped:(UIButton *)sender forEvent:(UIEvent *)event;
-(void) nayCheckButtonTapped:(UIButton *) sender forEvent:(UIEvent *)event;

@end
