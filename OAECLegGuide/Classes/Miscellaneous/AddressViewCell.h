//
//  AddressViewCell.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 8/3/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonViewController.h"

@interface AddressViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UILabel *addressLine1;
@property (retain, nonatomic) IBOutlet UILabel *addressLine2;
@property (retain, nonatomic) IBOutlet UILabel *phoneNumber;
@property (retain, nonatomic) IBOutlet UILabel *emailAddress;

@property (retain, nonatomic) IBOutlet UIButton *phoneInvisibleButton;
@property (retain, nonatomic) IBOutlet UIButton *emailInvisibleButton;
@property (retain, nonatomic) IBOutlet UIButton *phoneButton;
@property (retain, nonatomic) IBOutlet UIButton *emailButton;
@property (retain, nonatomic) IBOutlet UIButton *mapButton;

@property (nonatomic, assign) PersonViewController *pvc;

- (IBAction)dial:(id)sender;
- (IBAction)email:(id)sender;
- (IBAction)mapButtonPressed:(id)sender;

@end
