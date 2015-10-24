//
//  CustomTabBarController.m
//  LegGuide
//
//  Created by Matt Galloway on 12/10/13.
//  Copyright (c) 2013 Architactile LLC. All rights reserved.
//

#import "CustomTabBarController.h"
#import "IOS7AdjustmentViewController.h"

@interface CustomTabBarController ()

@property (nonatomic,strong) NSMutableArray *navControllers;

@end

@implementation CustomTabBarController

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

    if (self.selectedViewController==viewController) {
        [((IOS7AdjustmentViewController *)viewController) popToRootViewControllerAnimated:YES];
    }
    
    return YES;
    
}

-(void) viewDidLoad {
    [super viewDidLoad];
    self.delegate=self;
    
    self.navControllers = [NSMutableArray arrayWithCapacity:5];
    
    for (IOS7AdjustmentViewController *vc in self.viewControllers) {
        UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:vc.tabBarItem.title];
        [vc setContentController:nc];
    }
}

-(void) dealloc {
    [_navControllers release];
    [super dealloc];
}

@end
