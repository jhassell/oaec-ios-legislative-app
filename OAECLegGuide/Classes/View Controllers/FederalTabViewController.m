//
//  FederalTabViewController.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/21/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "FederalTabViewController.h"
#import "AppDelegate.h"
#import "ListSection.h"
#import "PeopleListDelegate.h"

@interface FederalTabViewController ()

@property (nonatomic, retain) PeopleListDelegate *peopleListDelegate;
@property (retain, nonatomic) IBOutlet UITableView *peopleTable;

@end

@implementation FederalTabViewController

@synthesize peopleListDelegate=_peopleListDelegate;
@synthesize peopleTable = _peopleTable;

-(IBAction) weblink {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] weblink];
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    self.tabBarController.selectedIndex = 0;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    if (@available(iOS 14.0, *)) {
        self.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeMinimal;
    }
    UIButton *backBtn = (UIButton *)[self.view viewWithTag:9001];
    if ([backBtn isKindOfClass:[UIButton class]]) {
        UIImage *chevron = [UIImage systemImageNamed:@"chevron.left"];
        if (chevron) {
            UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium];
            chevron = [chevron imageByApplyingSymbolConfiguration:config];
            [backBtn setImage:chevron forState:UIControlStateNormal];
            [backBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [backBtn setAttributedTitle:nil forState:UIControlStateNormal];
            [backBtn setAttributedTitle:nil forState:UIControlStateHighlighted];
            [backBtn setTitle:@"" forState:UIControlStateNormal];
            [backBtn setTitle:@"" forState:UIControlStateHighlighted];
            [backBtn setTitle:@"" forState:UIControlStateSelected];
            [backBtn setTitle:@"" forState:UIControlStateDisabled];
            backBtn.tintColor = [UIColor labelColor];
        }
    }
    self.peopleListDelegate = [[[PeopleListDelegate alloc] init] autorelease];
    self.peopleListDelegate.viewController = self;
    self.peopleListDelegate.peopleTable = self.peopleTable;
    self.peopleTable.delegate = self.peopleListDelegate;
    self.peopleTable.dataSource = self.peopleListDelegate;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (self.peopleTable.window != nil) {
        self.peopleTable.contentOffset = CGPointZero;
        [self.peopleTable reloadData];
    }
    if (self.peopleTable.indexPathForSelectedRow!=nil) {
        [self.peopleTable deselectRowAtIndexPath:self.peopleTable.indexPathForSelectedRow animated:YES];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    if (@available(iOS 14.0, *)) {
        self.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeMinimal;
    }
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *sections = [ListSection buildSectionsFrom:ad.all dividedBy:@"Type" catchAllKey:nil includeKeys:[NSArray arrayWithObjects:FEDERAL_SENATE, FEDERAL_HOUSE, nil]];
    
    if ([sections count]==2) {
        sections = [NSArray arrayWithObjects:[sections objectAtIndex:1],[sections objectAtIndex:0], nil];
    }
    
    self.peopleListDelegate.sections = sections;
}

- (void)dealloc
{
    [_peopleListDelegate release];
    [_peopleTable release];
    [super dealloc];
}

@end
