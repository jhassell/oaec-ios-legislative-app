//
//  AboutViewController.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/21/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "AboutViewController.h"
#import "AppDelegate.h"
#import "PeopleListViewController.h"
#import "ListSection.h"
#import <QuartzCore/QuartzCore.h>

@interface AboutViewController () {
    BOOL firstLaunch;
}
- (IBAction)backButtonPressed:(id)sender;
- (IBAction)legislatureButtonPressed:(id)sender;
- (IBAction)memberSystemsButtonPressed:(id)sender;
- (IBAction)legContactsButtonPressed:(id)sender;


@end

@implementation AboutViewController


- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)bPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)jPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)kButton:(UIButton *)sender {
}

- (IBAction)mButton:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)zButton:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)legislatureButtonPressed:(id)sender {
    UINavigationController *nc = [self.tabBarController.viewControllers objectAtIndex:1];
    [nc popToRootViewControllerAnimated:NO];
    [self.tabBarController setSelectedIndex:1];
}

-(IBAction) weblink {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] weblink];
}

- (IBAction)memberSystemsButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PeopleListViewController *plvc = [[[PeopleListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
    plvc.sections = [ListSection buildSectionsFrom:ad.all dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects:OAEC_MEMBER, nil]];
    
    [self.navigationController pushViewController:plvc animated:YES];
    
}

- (IBAction)legContactsButtonPressed:(id)sender {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PeopleListViewController *plvc = [[[PeopleListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
    plvc.sections = [ListSection buildSectionsFrom:ad.all dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects:LEGISLATIVE_CONTACT, nil]];
    
    [self.navigationController pushViewController:plvc animated:YES];
    
}



-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //if ([[UIScreen mainScreen]bounds].size.height - 480.0 > DBL_EPSILON) {
    //    NSLog(@"Use bigger image");
    //    self.backgroundImage.image=[UIImage imageNamed:@"AboutBackground-iPhone5@2x.png"];
    //}
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (firstLaunch) {
        firstLaunch=NO;
        AppDelegate *ap = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [ap loadBoundaries];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    firstLaunch = YES;
    [self setPrimaryButtonTitle:self.legislatureButton text:@"60th LEGISLATURE"];
    [self setPrimaryButtonTitle:self.aboutOAECButton text:@"ABOUT OAEC"];
}

- (void)setPrimaryButtonTitle:(UIButton *)button text:(NSString *)text {
    if (!button || !text.length) return;
    UIFont *font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightSemibold];
    NSDictionary *attrs = @{
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: font
    };
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:text attributes:attrs];
    [button setAttributedTitle:title forState:UIControlStateNormal];
    [title release];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect bounds = self.view.bounds;
    CGFloat w = bounds.size.width;
    CGFloat h = bounds.size.height;
    CGFloat safeTop = 0;
    CGFloat safeBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeTop = self.view.safeAreaInsets.top;
        safeBottom = self.view.safeAreaInsets.bottom;
    }
    CGFloat graphicTopInset = safeTop + 16.0f + (CGFloat)(0.03 * h);
    CGFloat horizontalPadding = 16.0f;
    CGFloat buttonHeight = 56.0f;
    CGFloat buttonVerticalGap = 24.0f;
    CGFloat bottomPadding = 24.0f;
    CGFloat totalButtonHeight = 2.0f * buttonHeight + buttonVerticalGap;
    CGFloat buttonY = h - safeBottom - totalButtonHeight - bottomPadding;
    buttonY -= (CGFloat)(0.15 * h);
    buttonY += (CGFloat)(0.10 * h);
    CGFloat graphicBottom = buttonY - 40.0f;
    if (graphicBottom < graphicTopInset + 100.0f) graphicBottom = graphicTopInset + (h - graphicTopInset) * 0.5f;
    CGFloat graphicHeight = graphicBottom - graphicTopInset;
    self.backgroundImage.frame = CGRectMake(0, graphicTopInset, w, graphicHeight);
    self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImage.clipsToBounds = YES;
    if (self.graphicOverlayButton) {
        self.graphicOverlayButton.frame = CGRectMake(horizontalPadding, graphicTopInset, w - 2.0f * horizontalPadding, graphicHeight);
    }
    CGFloat buttonWidth = w - 2.0f * horizontalPadding;
    if (self.legislatureButton) {
        self.legislatureButton.frame = CGRectMake(horizontalPadding, buttonY, buttonWidth, buttonHeight);
        [self stylePrimaryButton:self.legislatureButton];
    }
    if (self.aboutOAECButton) {
        self.aboutOAECButton.frame = CGRectMake(horizontalPadding, buttonY + buttonHeight + buttonVerticalGap, buttonWidth, buttonHeight);
        [self stylePrimaryButton:self.aboutOAECButton];
    }
}

- (void)stylePrimaryButton:(UIButton *)button {
    button.layer.cornerRadius = 12.0f;
    button.clipsToBounds = YES;
    if (@available(iOS 13.0, *)) {
        button.layer.cornerCurve = kCACornerCurveContinuous;
    }
}

- (void)viewDidUnload
{
    [self setBackgroundImage:nil];
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




- (void)dealloc {
    [_backgroundImage release];
    [_legislatureButton release];
    [_aboutOAECButton release];
    [_graphicOverlayButton release];
    [super dealloc];
}
@end
