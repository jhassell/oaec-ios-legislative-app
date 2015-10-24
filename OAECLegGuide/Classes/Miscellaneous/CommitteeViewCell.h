//
//  CommitteeViewCell.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 8/3/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommitteeViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *committeeNameLabel;
@property (retain, nonatomic) IBOutlet UIView *grayBarView;

@end
