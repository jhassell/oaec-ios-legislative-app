//
//  PeopleListViewController.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/29/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "PeopleListViewController.h"
#import "PeopleListDelegate.h"
#import "AppDelegate.h"
#import "Committee.h"

@interface PeopleListViewController ()

@property (nonatomic, retain) PeopleListDelegate *peopleListDelegate;
@property (retain, nonatomic) IBOutlet UITableView *peopleTable;

- (IBAction)backButtonPushed:(id)sender;

@end

@implementation PeopleListViewController

@synthesize peopleListDelegate=_peopleListDelegate;
@synthesize peopleTable=_peopleTable;
@synthesize sections=_sections;
@synthesize committee=_committee;

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
    if (self.peopleTable.indexPathForSelectedRow!=nil) {
        [self.peopleTable deselectRowAtIndexPath:self.peopleTable.indexPathForSelectedRow animated:YES];
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (self.peopleListDelegate==nil) {
        self.peopleListDelegate = [[[PeopleListDelegate alloc] init] autorelease];
        self.peopleListDelegate.viewController = self;
        self.peopleListDelegate.committee=self.committee;
        self.peopleListDelegate.sections = self.sections;
        self.peopleTable.delegate=self.peopleListDelegate;
        self.peopleTable.dataSource=self.peopleListDelegate;
        self.peopleTable.contentOffset = CGPointZero;
        self.peopleListDelegate.peopleTable=self.peopleTable;
    }
}

- (void)dealloc
{
    [_committee release];
    [_sections release];
    [_peopleTable release];
    [_peopleListDelegate release];
    [super dealloc];
}

@end
