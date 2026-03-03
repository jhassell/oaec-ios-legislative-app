//
//  IOS7AdjustmentViewController.m
//  LegGuide
//
//  Created by Matt Galloway on 12/10/13.
//  Copyright (c) 2013 Architactile LLC. All rights reserved.
//

#import "IOS7AdjustmentViewController.h"
#import "OSVersionCheckMacros.h"

@interface IOS7AdjustmentViewController ()
@property (retain, nonatomic) IBOutlet UIView *adjustmentContainerView;
@property (retain, nonatomic) UINavigationController *navController;
- (void)attachContentControllerIfNeeded;

@end

@implementation IOS7AdjustmentViewController

-(BOOL) isContentSet {
    return self.navController!=nil;
}

- (void) setContentController: (UIViewController*) content;
{
    self.navController=(UINavigationController *)content;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        self.navController=segue.destinationViewController;
    }
    
}


-(void) popToRootViewControllerAnimated:(BOOL) animated {
    if (self.navController!=nil) {
        [self.navController popToRootViewControllerAnimated:animated];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        self.adjustmentContainerView.frame=self.view.frame;
    }
    [self attachContentControllerIfNeeded];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.adjustmentContainerView.frame = self.view.bounds;
    if (self.navController.view.superview == self.adjustmentContainerView) {
        self.navController.view.frame = self.adjustmentContainerView.bounds;
    }
}

- (void)attachContentControllerIfNeeded {
    if (self.navController == nil) return;
    if (self.navController.parentViewController == self) return;
    [self addChildViewController:self.navController];
    self.navController.view.frame = self.adjustmentContainerView.bounds;
    self.navController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.adjustmentContainerView addSubview:self.navController.view];
    [self.navController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_adjustmentContainerView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setAdjustmentContainerView:nil];
    [super viewDidUnload];
}
@end
