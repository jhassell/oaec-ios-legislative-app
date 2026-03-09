//
//  AboutViewController.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/21/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (retain, nonatomic) IBOutlet UIButton *legislatureButton;
@property (retain, nonatomic) IBOutlet UIButton *aboutOAECButton;
@property (retain, nonatomic) IBOutlet UIButton *graphicOverlayButton;

@end
