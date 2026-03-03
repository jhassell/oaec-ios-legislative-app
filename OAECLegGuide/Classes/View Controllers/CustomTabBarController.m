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
- (void)resetSelectedControllerToRoot:(UIViewController *)selected animated:(BOOL)animated;

@end

@implementation CustomTabBarController

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedViewController == viewController) {
        [self resetSelectedControllerToRoot:viewController animated:NO];
        return NO;
    }
    
    return YES;
    
}

- (void)resetSelectedControllerToRoot:(UIViewController *)selected animated:(BOOL)animated {
    if ([selected isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)selected;
        [nav popToRootViewControllerAnimated:animated];
        [nav setNavigationBarHidden:YES animated:NO];
        return;
    }

    if ([selected isKindOfClass:[IOS7AdjustmentViewController class]]) {
        [((IOS7AdjustmentViewController *)selected) popToRootViewControllerAnimated:animated];
        return;
    }

    if (selected.navigationController != nil) {
        [selected.navigationController popToRootViewControllerAnimated:animated];
        [selected.navigationController setNavigationBarHidden:YES animated:NO];
    }
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
