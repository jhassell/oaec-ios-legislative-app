//
//  voteButton.h
//  OAECLegGuide
//
//  Created by User on 5/11/17.
//  Copyright © 2017 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface voteButton : UIButton {
    voteButton *otherButton;
}

@property (nonatomic, strong) voteButton *otherButton;

@end
