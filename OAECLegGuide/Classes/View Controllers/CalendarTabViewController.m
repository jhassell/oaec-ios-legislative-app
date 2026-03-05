//
//  CalendarTabViewController.m
//  LegGuide
//
//  Created by Matt Galloway on 11/25/13.
//  Copyright (c) 2013 Architactile LLC. All rights reserved.
//

#import "CalendarTabViewController.h"
#import "AppDelegate.h"
#import "NSDictionary+Calendar.h"
#import "CalendarCell.h"

@interface CalendarTabViewController ()

@property (nonatomic, strong) NSArray *calendar;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation CalendarTabViewController

@synthesize calendar=_calendar;
@synthesize dateFormatter=_dateFormatter;

#pragma mark - Table view data source

- (IBAction)backButtonPressed:(id)sender {
    self.tabBarController.selectedIndex = 0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *event = self.calendar[indexPath.row];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 10.0)];
    label.numberOfLines=0;
    label.font=[UIFont systemFontOfSize:18.0];
    label.text = event.details;
    [label sizeToFit];
    
    return label.frame.size.height+50.0;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.calendar count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CalendarCell";
    CalendarCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    

    NSDictionary *event = self.calendar[indexPath.row];

    cell.dateLabel.text=[NSString stringWithFormat:@" %@",[self.dateFormatter stringFromDate:event.date]];

    cell.detailsLabel.frame=CGRectMake(cell.detailsLabel.frame.origin.x,
                                    cell.detailsLabel.frame.origin.y,
                                    300.0, 10.0);
    cell.detailsLabel.numberOfLines=0;
    cell.detailsLabel.font=[UIFont systemFontOfSize:18.0];
    cell.detailsLabel.text=event.details;
    [cell.detailsLabel sizeToFit];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


#pragma mark - Life Cycle Stuff

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    if (@available(iOS 14.0, *)) {
        self.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeMinimal;
    }
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
        [backBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [backBtn setAttributedTitle:nil forState:UIControlStateNormal];
        [backBtn setAttributedTitle:nil forState:UIControlStateHighlighted];
        [backBtn setTitle:@"" forState:UIControlStateNormal];
        [backBtn setTitle:@"" forState:UIControlStateHighlighted];
        [backBtn setTitle:@"" forState:UIControlStateSelected];
        [backBtn setTitle:@"" forState:UIControlStateDisabled];
        if (@available(iOS 13.0, *)) {
            UIImage *chevron = [UIImage systemImageNamed:@"chevron.left"];
            if (chevron) {
                UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium];
                chevron = [chevron imageByApplyingSymbolConfiguration:config];
                [backBtn setImage:chevron forState:UIControlStateNormal];
                backBtn.tintColor = [UIColor labelColor];
            }
        } else {
            [backBtn setImage:nil forState:UIControlStateNormal];
            [backBtn setTitle:@"\u2039" forState:UIControlStateNormal];
            backBtn.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
            [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    [self.dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    AppDelegate *ad = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.calendar=ad.calendar;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_calendar release];
    [_tableView release];
    [_dateFormatter release];
    [super dealloc];
}

@end
