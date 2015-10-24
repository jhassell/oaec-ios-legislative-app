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
    NSLog(@"Preparing for segue");
    
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addChildViewController:self.navController];
    self.navController.view.frame=self.adjustmentContainerView.bounds;
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
