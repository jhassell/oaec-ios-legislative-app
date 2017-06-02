//
//  CommitteeListViewController.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/31/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommitteeVoteListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, retain) NSArray *sections;

@end
