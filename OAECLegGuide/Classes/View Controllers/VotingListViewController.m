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
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (self.rc_peopleTable.indexPathForSelectedRow!=nil) {
        [self.rc_peopleTable deselectRowAtIndexPath:self.rc_peopleTable.indexPathForSelectedRow animated:YES];
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
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

- (void)dealloc
{
    [_rc_committee release];
    [_rc_sections release];
    [_rc_peopleTable release];
    [_rollCallListDelegate release];
    [super dealloc];
}

@end
