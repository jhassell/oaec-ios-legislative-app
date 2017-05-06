//
//  VoteView.h
//  OAECLegGuide
//
//  Created by User on 5/4/17.
//  Copyright © 2017 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VoteButton;
@interface VoteView : UIView

@property (retain, nonatomic) IBOutlet VoteButton *voteButton;

- (IBAction)voteButtonPressed:(id)sender;

@end
