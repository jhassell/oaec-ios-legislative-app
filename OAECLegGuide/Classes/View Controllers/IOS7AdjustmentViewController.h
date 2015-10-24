//
//  IOS7AdjustmentViewController.h
//  LegGuide
//
//  Created by Matt Galloway on 12/10/13.
//  Copyright (c) 2013 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IOS7AdjustmentViewController : UIViewController

-(void) popToRootViewControllerAnimated:(BOOL) animated;
-(void) setContentController: (UIViewController*) content;

@property (nonatomic, assign) BOOL isContentSet;

@end
