//
//  CommitteeHeaderView.h
//  LegGuide
//
//  Created by Matt Galloway on 1/26/14.
//  Copyright (c) 2014 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommitteeHeaderView : UITableViewCell;

@property (retain, nonatomic) IBOutlet UILabel *chamberLabel;
@property (retain, nonatomic) IBOutlet UILabel *committeeNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *meetsLabel;
@property (retain, nonatomic) IBOutlet UILabel *roomLabel;
@property (retain, nonatomic) IBOutlet UILabel *committeeSubtypeLabel;


@property (retain, nonatomic) IBOutlet UILabel *meetsLabelLabel;
@property (retain, nonatomic) IBOutlet UILabel *roomLabelLabel;




@end
