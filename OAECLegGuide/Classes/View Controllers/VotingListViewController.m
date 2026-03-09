//
//  VotingListViewController.m
//  OAECLegGuide
//
//  Created by User on 5/15/17.
//  Copyright © 2017 Architactile LLC. All rights reserved.
//





#import "VotingListViewController.h"
#import "RollCallListDelegate.h"
#import "AppDelegate.h"
#import "Committee.h"

#import <Realm/Realm.h>



@interface VotingListViewController ()

@property (nonatomic, retain) RollCallListDelegate *rollCallListDelegate;
@property (retain, nonatomic) IBOutlet UITableView *rc_peopleTable;

- (IBAction)backButtonPushed:(id)sender;
- (void)layoutRollCallScreen;

@end

@implementation VotingListViewController

//@synthesize rollCallListDelegate=_rollCallListDelegate;
//@synthesize rc_peopleTable=_rc_peopleTable;
//@synthesize rc_sections=_rc_sections;
//@synthesize rc_committee=_rc_committee;

#pragma mark - UI Hooks


-(IBAction) weblink {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] weblink];
}


- (IBAction)backButtonPushed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Lifecycle Stuff

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
    // Do any additional setup after loading the view.
    UIButton *backBtn = (UIButton *)[self.view viewWithTag:9001];
    if ([backBtn isKindOfClass:[UIButton class]]) {
        [backBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [backBtn setAttributedTitle:nil forState:UIControlStateNormal];
        [backBtn setAttributedTitle:nil forState:UIControlStateHighlighted];
        if (@available(iOS 13.0, *)) {
            UIImage *chevron = [UIImage systemImageNamed:@"chevron.left"];
            if (chevron) {
                UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium];
                chevron = [chevron imageByApplyingSymbolConfiguration:config];
                [backBtn setImage:chevron forState:UIControlStateNormal];
                [backBtn setTitle:nil forState:UIControlStateNormal];
                backBtn.tintColor = [UIColor labelColor];
            }
        } else {
            [backBtn setImage:nil forState:UIControlStateNormal];
            [backBtn setTitle:@"\u2039" forState:UIControlStateNormal];
            backBtn.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
            [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    if ([self.rc_peopleTable respondsToSelector:@selector(setSeparatorInset:)]) {
        self.rc_peopleTable.separatorInset = UIEdgeInsetsZero;
    }
    if ([self.rc_peopleTable respondsToSelector:@selector(setLayoutMargins:)]) {
        self.rc_peopleTable.layoutMargins = UIEdgeInsetsZero;
    }
    if ([self.rc_peopleTable respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.rc_peopleTable.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self layoutRollCallScreen];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self layoutRollCallScreen];
    if (self.rc_peopleTable.indexPathForSelectedRow!=nil) {
        [self.rc_peopleTable deselectRowAtIndexPath:self.rc_peopleTable.indexPathForSelectedRow animated:YES];
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self layoutRollCallScreen];
    if (self.rollCallListDelegate==nil) {
        self.rollCallListDelegate = [[[RollCallListDelegate alloc] init] autorelease];
        self.rollCallListDelegate.rc_viewController = self;
        self.rollCallListDelegate.rc_committee=self.rc_committee;
        self.rollCallListDelegate.rc_sections = self.rc_sections;
        self.rc_peopleTable.delegate=self.rollCallListDelegate;
        self.rc_peopleTable.dataSource=self.rollCallListDelegate;
        self.rc_peopleTable.contentOffset = CGPointZero;
        self.rollCallListDelegate.rc_peopleTable=self.rc_peopleTable;
        
        
        
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutRollCallScreen];
}

- (void)layoutRollCallScreen {
    const CGFloat backgroundGraphicAlpha = 0.10f;
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            subview.frame = self.view.bounds;
            subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            subview.alpha = backgroundGraphicAlpha;
            [self.view sendSubviewToBack:subview];
            continue;
        }

        if (subview.subviews.count == 1 && [subview.subviews.firstObject isKindOfClass:[UIImageView class]]) {
            UIImageView *backgroundImageView = (UIImageView *)subview.subviews.firstObject;
            subview.frame = self.view.bounds;
            subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            backgroundImageView.frame = subview.bounds;
            backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            backgroundImageView.alpha = backgroundGraphicAlpha;
            [self.view sendSubviewToBack:subview];
        }
    }

    UIButton *backBtn = (UIButton *)[self.view viewWithTag:9001];
    CGFloat top = 52.0f;
    if ([backBtn isKindOfClass:[UIButton class]]) {
        top = MAX(top, CGRectGetMaxY(backBtn.frame) + 8.0f);
    }
    self.rc_peopleTable.frame = CGRectMake(0.0f, top, self.view.bounds.size.width, self.view.bounds.size.height - top);
    self.rc_peopleTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)dealloc
{
    [_rc_committee release];
    [_rc_sections release];
    [_rc_peopleTable release];
    [_rollCallListDelegate release];
    [super dealloc];
}

@end
