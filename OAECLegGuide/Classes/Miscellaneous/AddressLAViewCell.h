//
//  AddressLAViewCell.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 8/27/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonViewController.h"

@interface AddressLAViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *assistantTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *laNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *laEmailLabel;
@property (nonatomic, assign) PersonViewController *pvc;

- (IBAction)email:(id)sender;

@end
