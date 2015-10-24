//
//  OutlinkCell.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 1/23/13.
//  Copyright (c) 2013 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GreenButton;

@interface OutlinkCell : UITableViewCell

@property (retain, nonatomic) IBOutlet GreenButton *linkButton;
@property (retain, nonatomic) NSString *linkUrlString;

- (IBAction)linkButtonPressed:(id)sender;

@end
