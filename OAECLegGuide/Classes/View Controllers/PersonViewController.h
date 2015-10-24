//
//  PersonViewController.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 8/2/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface PersonViewController : UIViewController <MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource,UITextViewDelegate>

@property (retain, nonatomic) NSDictionary *person;
- (IBAction)emailButtonPressed:(id)sender;


@end
