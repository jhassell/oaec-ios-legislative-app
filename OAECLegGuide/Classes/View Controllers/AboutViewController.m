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
#import "PersonViewController.h"
#import "NSDictionary+People.h"
#import "NSString+Stuff.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>

#define ABOUT_CELL_HEADSHOT       ((UIImageView *)[cell viewWithTag:100])
#define ABOUT_CELL_NAME           ((UILabel *)[cell viewWithTag:101])
#define ABOUT_CELL_TITLE          ((UILabel *)[cell viewWithTag:102])
#define ABOUT_CELL_SUBTITLE       ((UILabel *)[cell viewWithTag:103])
#define ABOUT_CELL_DISTRICT       ((UILabel *)[cell viewWithTag:104])
#define ABOUT_CELL_PHOTO_NA       ((UIView *)[cell viewWithTag:105])

static CGFloat const AboutCarouselBasePointsPerSecond = 72.0f;
static CGFloat const AboutCarouselBoostDecayDuration = 3.0f;
static CGFloat const AboutCarouselMaxPointsPerSecond = 192.0f;
static CGFloat const AboutCarouselSwipeVelocityMultiplier = 72.0f;
static CGFloat const AboutCarouselMinimumSwipeVelocity = 0.12f;
static CGFloat const AboutCarouselPauseHoldDuration = 0.25f;

static NSString *AboutDisplayNameForPerson(NSDictionary *person) {
    if (person == nil) return @"";
    if ([@"vacant" caseInsensitiveCompare:[person.firstName trim]] == NSOrderedSame) {
        return @"Seat Vacant";
    }
    NSString *firstName = [person.firstName trim];
    NSString *lastName = [person.lastName trim];
    if (firstName.length == 0 && lastName.length == 0) return @"";
    if (firstName.length == 0) return lastName;
    if (lastName.length == 0) return firstName;
    return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
}

static NSString *AboutNormalizedString(NSString *value) {
    return [[value trim] lowercaseString];
}

static NSString *AboutLastFirstStringForPerson(NSDictionary *person) {
    NSString *firstName = [person.firstName trim];
    NSString *lastName = [person.lastName trim];
    if (lastName.length == 0 && firstName.length == 0) return @"";
    if (lastName.length == 0) return firstName;
    if (firstName.length == 0) return lastName;
    return [NSString stringWithFormat:@"%@, %@", lastName, firstName];
}

static NSString *AboutDeduplicationKeyForPerson(NSDictionary *person) {
    if (person == nil) return @"";
    return [NSString stringWithFormat:@"%@|%@|%@|%@|%@",
            [person.type trim] ?: @"",
            [person.firstName trim] ?: @"",
            [person.lastName trim] ?: @"",
            [person.districtNumber trim] ?: @"",
            [person.coopName trim] ?: @""];
}

static NSArray *AboutArrayOrEmpty(id candidate, NSString *label) {
    if ([candidate isKindOfClass:[NSArray class]]) {
        return candidate;
    }
    if (candidate != nil) {
        NSLog(@"[OAEC][About] Expected array for %@ but received %@.",
              label,
              NSStringFromClass([candidate class]));
    }
    return @[];
}

static NSInteger AboutSearchScoreForPerson(NSDictionary *person, NSString *query) {
    NSString *normalizedQuery = AboutNormalizedString(query);
    if (normalizedQuery.length == 0) return 0;

    NSString *firstName = [person.firstName trim] ?: @"";
    NSString *lastName = [person.lastName trim] ?: @"";
    NSString *fullName = AboutDisplayNameForPerson(person) ?: @"";
    NSString *lastFirst = AboutLastFirstStringForPerson(person);
    NSString *statewideTitle = @"";
    if ([person.type isEqualToString:STATEWIDE]) {
        statewideTitle = [person.titleLeadership trim] ?: @"";
    }

    NSString *normalizedFirst = AboutNormalizedString(firstName);
    NSString *normalizedLast = AboutNormalizedString(lastName);
    NSString *normalizedFull = AboutNormalizedString(fullName);
    NSString *normalizedLastFirst = AboutNormalizedString(lastFirst);
    NSString *normalizedTitle = AboutNormalizedString(statewideTitle);
    NSString *normalizedDistrict = AboutNormalizedString([person.districtNumber trim] ?: @"");
    unichar firstCharacter = [normalizedQuery characterAtIndex:0];
    BOOL queryStartsWithDigit = [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:firstCharacter];

    NSInteger score = 0;
    if (queryStartsWithDigit &&
        ([person.type isEqualToString:STATE_HOUSE] || [person.type isEqualToString:STATE_SENATE])) {
        NSInteger districtScore = [person.type isEqualToString:STATE_SENATE] ? 690 : 700;
        NSInteger districtPrefixScore = [person.type isEqualToString:STATE_SENATE] ? 630 : 640;
        if ([normalizedDistrict isEqualToString:normalizedQuery]) {
            score = MAX(score, districtScore);
        } else if ([normalizedDistrict hasPrefix:normalizedQuery]) {
            score = MAX(score, districtPrefixScore);
        }
    }

    if ([normalizedLast hasPrefix:normalizedQuery]) score = MAX(score, 600);
    if ([normalizedFirst hasPrefix:normalizedQuery]) score = MAX(score, 560);
    if ([normalizedTitle hasPrefix:normalizedQuery]) score = MAX(score, 540);
    if ([normalizedLastFirst hasPrefix:normalizedQuery]) score = MAX(score, 530);
    if ([normalizedFull hasPrefix:normalizedQuery]) score = MAX(score, 520);

    if ([normalizedLast containsString:normalizedQuery]) score = MAX(score, 470);
    if ([normalizedFirst containsString:normalizedQuery]) score = MAX(score, 430);
    if ([normalizedTitle containsString:normalizedQuery]) score = MAX(score, 410);
    if ([normalizedLastFirst containsString:normalizedQuery]) score = MAX(score, 390);
    if ([normalizedFull containsString:normalizedQuery]) score = MAX(score, 380);

    if (score > 0) {
        NSInteger comparisonLength = MAX((NSInteger)normalizedLast.length, (NSInteger)normalizedFirst.length);
        comparisonLength = MAX(comparisonLength, (NSInteger)normalizedTitle.length);
        score -= ABS(comparisonLength - (NSInteger)normalizedQuery.length);
    }
    return score;
}

@interface AboutViewController () {
    BOOL firstLaunch;
}

@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UILabel *subtitleLabel;
@property (retain, nonatomic) UIView *searchCueView;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) UIView *launchCaretView;
@property (retain, nonatomic) UIView *resultsContainerView;
@property (retain, nonatomic) UITableView *resultsTableView;
@property (retain, nonatomic) UILabel *emptyStateLabel;
@property (retain, nonatomic) NSArray *searchablePeople;
@property (retain, nonatomic) NSArray *launchCarouselPeople;
@property (retain, nonatomic) NSArray *launchLoopPeople;
@property (retain, nonatomic) NSMutableArray *filteredPeople;
@property (retain, nonatomic) NSString *currentSearchText;
@property (retain, nonatomic) CADisplayLink *carouselDisplayLink;
@property (assign, nonatomic) CFTimeInterval lastCarouselTimestamp;
@property (retain, nonatomic) UILongPressGestureRecognizer *carouselHoldGestureRecognizer;
@property (assign, nonatomic) CFTimeInterval carouselBoostStartTimestamp;
@property (assign, nonatomic) CGFloat carouselBoostStartSpeed;
@property (assign, nonatomic) BOOL carouselTouchHolding;
@property (assign, nonatomic) BOOL carouselUserDragging;
@property (assign, nonatomic) BOOL carouselPausedByHold;
@property (assign, nonatomic) BOOL carouselPausedByDownwardDrag;
@property (assign, nonatomic) BOOL carouselDecayStopsAfterBoost;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)legislatureButtonPressed:(id)sender;
- (IBAction)memberSystemsButtonPressed:(id)sender;
- (IBAction)legContactsButtonPressed:(id)sender;
- (void)setupSearchInterface;
- (void)reloadSearchablePeople;
- (void)rebuildLaunchCarouselPeople;
- (void)applySearchText:(NSString *)searchText;
- (void)refreshSpreadsheetBackedContentPreservingCarouselState;
- (void)spreadsheetDataDidReload:(NSNotification *)notification;
- (UITableViewCell *)aboutResultsCellForTableView:(UITableView *)tableView;
- (void)configureAboutResultCell:(UITableViewCell *)cell withPerson:(NSDictionary *)person emphasized:(BOOL)emphasized;
- (void)updateEmptyState;
- (void)updateLaunchCueVisibility;
- (void)startCarouselIfNeeded;
- (void)stopCarousel;
- (void)handleCarouselDisplayLink:(CADisplayLink *)displayLink;
- (BOOL)isShowingSearchResults;
- (UITextField *)aboutSearchTextField;
- (NSDictionary *)personForIndexPath:(NSIndexPath *)indexPath;
- (void)normalizeCarouselOffsetIfNeeded;
- (void)snapCarouselToRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)resumeCarouselIfAppropriate;
- (void)beginCarouselSpeedDecayFromSpeed:(CGFloat)boostSpeed timestamp:(CFTimeInterval)timestamp;
- (CGFloat)carouselSpeedForTimestamp:(CFTimeInterval)timestamp;
- (CGFloat)carouselContentHeightForCount:(NSUInteger)count;
- (CGFloat)normalizedCarouselOffset:(CGFloat)offset contentHeight:(CGFloat)contentHeight;
- (void)reloadResultsTableWithoutAnimation;
- (void)handleCarouselHoldGesture:(UILongPressGestureRecognizer *)gestureRecognizer;

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

- (IBAction)zButton:(id)sender {
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    firstLaunch = YES;
    [self setPrimaryButtonTitle:self.legislatureButton text:@"60th LEGISLATURE"];
    [self setPrimaryButtonTitle:self.aboutOAECButton text:@"ABOUT OAEC"];
    self.filteredPeople = [NSMutableArray array];
    self.currentSearchText = @"";
    [self setupSearchInterface];
    [self reloadSearchablePeople];
    [self rebuildLaunchCarouselPeople];
    [self applySearchText:nil];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadSearchablePeople];
    [self rebuildLaunchCarouselPeople];
    [self applySearchText:self.searchBar.text];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (firstLaunch) {
        firstLaunch=NO;
        AppDelegate *ap = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [ap loadBoundaries];
    }
    [self updateLaunchCueVisibility];
    [self startCarouselIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopCarousel];
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

- (void)setupSearchInterface {
    UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    titleLabel.text = @"OAEC's Oklahoma\nLegislative Guide";
    titleLabel.font = [UIFont systemFontOfSize:26.0f weight:UIFontWeightBold];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithRed:0.11f green:0.51f blue:0.34f alpha:1.0f];
    titleLabel.numberOfLines = 2;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.adjustsFontSizeToFitWidth = NO;
    self.titleLabel = titleLabel;
    [self.view addSubview:self.titleLabel];

    UILabel *subtitleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    subtitleLabel.text = @"";
    subtitleLabel.font = [UIFont systemFontOfSize:1.0f weight:UIFontWeightMedium];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.textColor = [UIColor clearColor];
    subtitleLabel.numberOfLines = 1;
    self.subtitleLabel = subtitleLabel;
    [self.view addSubview:self.subtitleLabel];

    UIView *searchCueView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    searchCueView.userInteractionEnabled = NO;
    searchCueView.backgroundColor = [UIColor clearColor];
    searchCueView.layer.borderWidth = 2.0f;
    searchCueView.layer.borderColor = [UIColor colorWithRed:0.11f green:0.51f blue:0.34f alpha:0.80f].CGColor;
    searchCueView.layer.shadowColor = [UIColor colorWithRed:0.11f green:0.51f blue:0.34f alpha:1.0f].CGColor;
    searchCueView.layer.shadowOpacity = 0.25f;
    searchCueView.layer.shadowRadius = 12.0f;
    searchCueView.layer.shadowOffset = CGSizeZero;
    self.searchCueView = searchCueView;
    [self.view addSubview:self.searchCueView];

    UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectZero] autorelease];
    searchBar.delegate = self;
    searchBar.placeholder = @"Search legislators and officials";
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeWords;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.returnKeyType = UIReturnKeySearch;
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar = searchBar;
    [self.view addSubview:self.searchBar];

    UITextField *searchField = [self aboutSearchTextField];
    if (searchField != nil) {
        searchField.autocorrectionType = UITextAutocorrectionTypeNo;
        searchField.spellCheckingType = UITextSpellCheckingTypeNo;
        if (@available(iOS 11.0, *)) {
            searchField.smartQuotesType = UITextSmartQuotesTypeNo;
            searchField.smartDashesType = UITextSmartDashesTypeNo;
            searchField.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
        }
        searchField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.96f];
        searchField.layer.cornerRadius = 12.0f;
        searchField.layer.masksToBounds = YES;
    }

    UIView *launchCaretView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    launchCaretView.userInteractionEnabled = NO;
    launchCaretView.backgroundColor = [UIColor colorWithRed:0.11f green:0.51f blue:0.34f alpha:1.0f];
    launchCaretView.layer.cornerRadius = 1.0f;
    self.launchCaretView = launchCaretView;
    [self.view addSubview:self.launchCaretView];

    UIView *resultsContainerView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    resultsContainerView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.88f];
    resultsContainerView.layer.cornerRadius = 18.0f;
    resultsContainerView.clipsToBounds = YES;
    if (@available(iOS 13.0, *)) {
        resultsContainerView.layer.cornerCurve = kCACornerCurveContinuous;
    }
    self.resultsContainerView = resultsContainerView;
    [self.view addSubview:self.resultsContainerView];

    UITableView *resultsTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    resultsTableView.delegate = self;
    resultsTableView.dataSource = self;
    resultsTableView.backgroundColor = [UIColor clearColor];
    resultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    resultsTableView.rowHeight = 104.0f;
    resultsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    resultsTableView.showsVerticalScrollIndicator = NO;
    self.resultsTableView = resultsTableView;
    [self.resultsContainerView addSubview:self.resultsTableView];

    UILongPressGestureRecognizer *holdGestureRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                         action:@selector(handleCarouselHoldGesture:)] autorelease];
    holdGestureRecognizer.minimumPressDuration = AboutCarouselPauseHoldDuration;
    holdGestureRecognizer.cancelsTouchesInView = NO;
    holdGestureRecognizer.delegate = self;
    self.carouselHoldGestureRecognizer = holdGestureRecognizer;
    [self.resultsTableView addGestureRecognizer:self.carouselHoldGestureRecognizer];

    UILabel *emptyStateLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    emptyStateLabel.numberOfLines = 0;
    emptyStateLabel.textAlignment = NSTextAlignmentCenter;
    emptyStateLabel.font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightMedium];
    emptyStateLabel.textColor = [UIColor colorWithWhite:0.38f alpha:1.0f];
    self.emptyStateLabel = emptyStateLabel;
    [self.resultsContainerView addSubview:self.emptyStateLabel];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(spreadsheetDataDidReload:)
                                                 name:OAECSpreadsheetDataDidReloadNotification
                                               object:nil];
}

- (UITextField *)aboutSearchTextField {
    if (@available(iOS 13.0, *)) {
        return self.searchBar.searchTextField;
    }

    UITextField *searchField = nil;
    @try {
        searchField = [self.searchBar valueForKey:@"_searchField"];
    } @catch (__unused NSException *exception) {
        searchField = nil;
    }
    return searchField;
}

- (void)reloadSearchablePeople {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *aggregatedPeople = [NSMutableArray array];
    NSMutableSet *seenKeys = [NSMutableSet set];
    NSArray *sourceArrays = @[
        AboutArrayOrEmpty(ad.stateSenate, @"stateSenate"),
        AboutArrayOrEmpty(ad.stateHouse, @"stateHouse"),
        AboutArrayOrEmpty(ad.statewide, @"statewide"),
        AboutArrayOrEmpty(ad.federalSenate, @"federalSenate"),
        AboutArrayOrEmpty(ad.federalHouse, @"federalHouse"),
        AboutArrayOrEmpty(ad.stateJudiciary, @"stateJudiciary"),
        AboutArrayOrEmpty(ad.oaecMembers, @"oaecMembers"),
        AboutArrayOrEmpty(ad.legislativeContacts, @"legislativeContacts")
    ];

    for (NSArray *source in sourceArrays) {
        for (NSDictionary *person in source) {
            if (![person isKindOfClass:[NSDictionary class]]) continue;
            NSString *dedupeKey = AboutDeduplicationKeyForPerson(person);
            if (dedupeKey.length == 0 || [seenKeys containsObject:dedupeKey]) continue;
            [seenKeys addObject:dedupeKey];
            [aggregatedPeople addObject:person];
        }
    }

    [aggregatedPeople sortUsingComparator:^NSComparisonResult(NSDictionary *personA, NSDictionary *personB) {
        return [AboutDisplayNameForPerson(personA) localizedCaseInsensitiveCompare:AboutDisplayNameForPerson(personB)];
    }];

    self.searchablePeople = aggregatedPeople;
}

- (void)rebuildLaunchCarouselPeople {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *launchCarouselPeople = [NSMutableArray array];
    [launchCarouselPeople addObjectsFromArray:AboutArrayOrEmpty(ad.statewide, @"statewide carousel")];
    [launchCarouselPeople addObjectsFromArray:AboutArrayOrEmpty(ad.stateSenate, @"stateSenate carousel")];
    [launchCarouselPeople addObjectsFromArray:AboutArrayOrEmpty(ad.stateHouse, @"stateHouse carousel")];
    [launchCarouselPeople addObjectsFromArray:AboutArrayOrEmpty(ad.stateJudiciary, @"stateJudiciary carousel")];
    [launchCarouselPeople addObjectsFromArray:AboutArrayOrEmpty(ad.federalSenate, @"federalSenate carousel")];
    [launchCarouselPeople addObjectsFromArray:AboutArrayOrEmpty(ad.federalHouse, @"federalHouse carousel")];
    self.launchCarouselPeople = launchCarouselPeople;

    NSMutableArray *launchLoopPeople = [NSMutableArray array];
    if (launchCarouselPeople.count > 0) {
        [launchLoopPeople addObjectsFromArray:launchCarouselPeople];
        [launchLoopPeople addObjectsFromArray:launchCarouselPeople];
    }
    self.launchLoopPeople = launchLoopPeople;
}

- (BOOL)isShowingSearchResults {
    return ([[self.currentSearchText trim] length] > 0);
}

- (void)applySearchText:(NSString *)searchText {
    self.currentSearchText = [searchText trim] ?: @"";
    [self.filteredPeople removeAllObjects];

    if ([self isShowingSearchResults]) {
        NSString *lowercaseQuery = [self.currentSearchText lowercaseString];
        NSMutableArray *rankedMatches = [NSMutableArray array];
        for (NSDictionary *person in self.searchablePeople) {
            NSInteger score = AboutSearchScoreForPerson(person, lowercaseQuery);
            if (score <= 0) continue;
            [rankedMatches addObject:@{
                @"person": person,
                @"score": [NSNumber numberWithInteger:score],
                @"name": AboutDisplayNameForPerson(person) ?: @""
            }];
        }

        [rankedMatches sortUsingComparator:^NSComparisonResult(NSDictionary *matchA, NSDictionary *matchB) {
            NSInteger scoreA = [[matchA objectForKey:@"score"] integerValue];
            NSInteger scoreB = [[matchB objectForKey:@"score"] integerValue];
            if (scoreA > scoreB) return NSOrderedAscending;
            if (scoreA < scoreB) return NSOrderedDescending;
            return [[matchA objectForKey:@"name"] localizedCaseInsensitiveCompare:[matchB objectForKey:@"name"]];
        }];

        for (NSDictionary *match in rankedMatches) {
            [self.filteredPeople addObject:[match objectForKey:@"person"]];
        }

        [self stopCarousel];
    } else {
        self.carouselTouchHolding = NO;
        self.carouselUserDragging = NO;
        self.carouselPausedByHold = NO;
        self.carouselPausedByDownwardDrag = NO;
        self.carouselBoostStartSpeed = 0.0f;
        self.carouselBoostStartTimestamp = 0.0;
        self.carouselDecayStopsAfterBoost = NO;
        [self.resultsTableView setContentOffset:CGPointZero animated:NO];
        [self startCarouselIfNeeded];
    }

    [self.resultsTableView reloadData];
    [self updateEmptyState];
    [self updateLaunchCueVisibility];
}

- (CGFloat)carouselContentHeightForCount:(NSUInteger)count {
    if (count == 0) return 0.0f;
    return self.resultsTableView.rowHeight * (CGFloat)count;
}

- (CGFloat)normalizedCarouselOffset:(CGFloat)offset contentHeight:(CGFloat)contentHeight {
    if (contentHeight <= 0.0f) return 0.0f;
    CGFloat normalizedOffset = fmod(offset, contentHeight);
    if (normalizedOffset < 0.0f) {
        normalizedOffset += contentHeight;
    }
    return normalizedOffset;
}

- (void)reloadResultsTableWithoutAnimation {
    [UIView performWithoutAnimation:^{
        [self.resultsTableView reloadData];
        [self.resultsTableView layoutIfNeeded];
    }];
}

- (void)refreshSpreadsheetBackedContentPreservingCarouselState {
    BOOL showingSearchResults = [self isShowingSearchResults];
    CGFloat previousOffsetY = self.resultsTableView.contentOffset.y;
    CGFloat previousCarouselHeight = [self carouselContentHeightForCount:self.launchCarouselPeople.count];

    [self stopCarousel];
    [self reloadSearchablePeople];
    [self rebuildLaunchCarouselPeople];

    if (showingSearchResults) {
        [self applySearchText:self.currentSearchText];
        return;
    }

    [self reloadResultsTableWithoutAnimation];

    CGFloat newCarouselHeight = [self carouselContentHeightForCount:self.launchCarouselPeople.count];
    CGPoint offset = self.resultsTableView.contentOffset;
    if (previousCarouselHeight > 0.0f && newCarouselHeight > 0.0f) {
        CGFloat normalizedOffset = [self normalizedCarouselOffset:previousOffsetY contentHeight:previousCarouselHeight];
        offset.y = [self normalizedCarouselOffset:normalizedOffset contentHeight:newCarouselHeight];
    } else {
        offset.y = 0.0f;
    }
    [self.resultsTableView setContentOffset:offset animated:NO];
    [self normalizeCarouselOffsetIfNeeded];
    [self updateEmptyState];
    [self updateLaunchCueVisibility];
    [self resumeCarouselIfAppropriate];
}

- (void)spreadsheetDataDidReload:(NSNotification *)notification {
    if (![notification.object isKindOfClass:[AppDelegate class]]) return;
    [self refreshSpreadsheetBackedContentPreservingCarouselState];
}

- (void)updateEmptyState {
    BOOL showingSearchResults = [self isShowingSearchResults];
    BOOL hasSearchResults = (self.filteredPeople.count > 0);
    BOOL hasCarousel = (self.launchLoopPeople.count > 0);

    self.resultsTableView.hidden = (!showingSearchResults && !hasCarousel) || (showingSearchResults && !hasSearchResults);
    self.emptyStateLabel.hidden = (showingSearchResults ? hasSearchResults : hasCarousel);

    if (showingSearchResults && !hasSearchResults) {
        self.emptyStateLabel.text = @"No matching officials were found.";
    } else if (!hasCarousel) {
        self.emptyStateLabel.text = @"Loading officials for the launch carousel...";
    } else {
        self.emptyStateLabel.text = @"";
    }
}

- (void)updateLaunchCueVisibility {
    BOOL editingSearchField = [[self aboutSearchTextField] isFirstResponder];
    BOOL showCue = (![self isShowingSearchResults] &&
                    !editingSearchField &&
                    ![[self.searchBar.text trim] length]);

    self.searchCueView.hidden = !showCue;
    self.launchCaretView.hidden = !showCue;

    [self.searchCueView.layer removeAnimationForKey:@"pulse"];
    [self.launchCaretView.layer removeAnimationForKey:@"blink"];

    if (showCue) {
        CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        pulse.fromValue = @0.15f;
        pulse.toValue = @0.40f;
        pulse.duration = 0.9;
        pulse.autoreverses = YES;
        pulse.repeatCount = HUGE_VALF;
        [self.searchCueView.layer addAnimation:pulse forKey:@"pulse"];

        CABasicAnimation *blink = [CABasicAnimation animationWithKeyPath:@"opacity"];
        blink.fromValue = @1.0f;
        blink.toValue = @0.15f;
        blink.duration = 0.7;
        blink.autoreverses = YES;
        blink.repeatCount = HUGE_VALF;
        [self.launchCaretView.layer addAnimation:blink forKey:@"blink"];
    }
}

- (void)startCarouselIfNeeded {
    if ([self isShowingSearchResults]) return;
    if (self.launchCarouselPeople.count == 0 || self.view.window == nil) return;
    if ([[self aboutSearchTextField] isFirstResponder]) return;
    if (self.carouselTouchHolding || self.carouselUserDragging || self.carouselPausedByHold || self.carouselPausedByDownwardDrag) return;
    if (self.carouselDisplayLink != nil) return;
    [self normalizeCarouselOffsetIfNeeded];
    self.lastCarouselTimestamp = 0;
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleCarouselDisplayLink:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.carouselDisplayLink = displayLink;
}

- (void)stopCarousel {
    [self.carouselDisplayLink invalidate];
    self.carouselDisplayLink = nil;
    self.lastCarouselTimestamp = 0;
}

- (NSDictionary *)personForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == nil) return nil;

    if ([self isShowingSearchResults]) {
        if (indexPath.row < 0 || indexPath.row >= self.filteredPeople.count) return nil;
        id person = [self.filteredPeople objectAtIndex:indexPath.row];
        return [person isKindOfClass:[NSDictionary class]] ? person : nil;
    }

    if (self.launchCarouselPeople.count == 0) return nil;
    NSInteger normalizedIndex = indexPath.row % self.launchCarouselPeople.count;
    if (normalizedIndex < 0 || normalizedIndex >= self.launchCarouselPeople.count) return nil;
    id person = [self.launchCarouselPeople objectAtIndex:normalizedIndex];
    return [person isKindOfClass:[NSDictionary class]] ? person : nil;
}

- (void)normalizeCarouselOffsetIfNeeded {
    if ([self isShowingSearchResults] || self.launchCarouselPeople.count == 0) return;

    CGFloat originalHeight = self.resultsTableView.rowHeight * (CGFloat)self.launchCarouselPeople.count;
    if (originalHeight <= 0.0f) return;

    CGPoint offset = self.resultsTableView.contentOffset;
    if (offset.y < 0.0f) {
        offset.y = 0.0f;
    } else if (offset.y >= originalHeight) {
        offset.y = fmod(offset.y, originalHeight);
    }
    [self.resultsTableView setContentOffset:offset animated:NO];
}

- (void)snapCarouselToRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isShowingSearchResults] || self.launchCarouselPeople.count == 0 || indexPath == nil) return;

    NSInteger normalizedIndex = indexPath.row % self.launchCarouselPeople.count;
    if (normalizedIndex < 0) {
        normalizedIndex += self.launchCarouselPeople.count;
    }
    CGFloat rowHeight = self.resultsTableView.rowHeight;
    CGPoint offset = self.resultsTableView.contentOffset;
    offset.y = rowHeight * (CGFloat)normalizedIndex;
    [self.resultsTableView setContentOffset:offset animated:NO];
}

- (void)resumeCarouselIfAppropriate {
    if ([self isShowingSearchResults]) return;
    if ([[self aboutSearchTextField] isFirstResponder]) return;
    if (self.carouselTouchHolding || self.carouselUserDragging || self.carouselPausedByHold || self.carouselPausedByDownwardDrag) return;
    [self startCarouselIfNeeded];
}

- (void)beginCarouselSpeedDecayFromSpeed:(CGFloat)boostSpeed timestamp:(CFTimeInterval)timestamp {
    self.carouselBoostStartSpeed = MIN(AboutCarouselMaxPointsPerSecond, boostSpeed);
    self.carouselBoostStartTimestamp = timestamp;
}

- (CGFloat)carouselSpeedForTimestamp:(CFTimeInterval)timestamp {
    if (self.carouselTouchHolding || self.carouselUserDragging || self.carouselPausedByDownwardDrag) {
        return 0.0f;
    }

    if (self.carouselBoostStartSpeed <= 0.0f || self.carouselBoostStartTimestamp <= 0.0) {
        return AboutCarouselBasePointsPerSecond;
    }

    CFTimeInterval elapsed = timestamp - self.carouselBoostStartTimestamp;
    if (elapsed >= AboutCarouselBoostDecayDuration) {
        self.carouselBoostStartSpeed = 0.0f;
        self.carouselBoostStartTimestamp = 0.0;
        if (self.carouselDecayStopsAfterBoost) {
            [self stopCarousel];
            return 0.0f;
        }
        return AboutCarouselBasePointsPerSecond;
    }

    CGFloat progress = (CGFloat)(elapsed / AboutCarouselBoostDecayDuration);
    CGFloat remaining = 1.0f - progress;
    CGFloat easedRemaining = remaining * remaining;
    if (self.carouselDecayStopsAfterBoost) {
        return MAX(0.0f, self.carouselBoostStartSpeed * easedRemaining);
    }
    return AboutCarouselBasePointsPerSecond + ((self.carouselBoostStartSpeed - AboutCarouselBasePointsPerSecond) * easedRemaining);
}

- (void)handleCarouselDisplayLink:(CADisplayLink *)displayLink {
    if ([self isShowingSearchResults]) {
        [self stopCarousel];
        return;
    }
    if (self.launchCarouselPeople.count == 0) return;

    CGFloat originalHeight = self.resultsTableView.rowHeight * (CGFloat)self.launchCarouselPeople.count;
    if (originalHeight <= 0.0f) return;

    if (self.lastCarouselTimestamp == 0) {
        self.lastCarouselTimestamp = displayLink.timestamp;
        return;
    }

    CFTimeInterval elapsed = displayLink.timestamp - self.lastCarouselTimestamp;
    self.lastCarouselTimestamp = displayLink.timestamp;

    CGFloat pointsPerSecond = [self carouselSpeedForTimestamp:displayLink.timestamp];
    if (pointsPerSecond <= 0.0f) return;
    CGPoint offset = self.resultsTableView.contentOffset;
    offset.y += (CGFloat)(pointsPerSecond * elapsed);
    if (offset.y >= originalHeight) {
        offset.y = 0.0f;
    }
    [self.resultsTableView setContentOffset:offset animated:NO];
}

- (UITableViewCell *)aboutResultsCellForTableView:(UITableView *)tableView {
    static NSString *CellIdentifier = @"PeopleListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PeopleListCell-iPhone" owner:nil options:nil] objectAtIndex:0];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configureAboutResultCell:(UITableViewCell *)cell withPerson:(NSDictionary *)person emphasized:(BOOL)emphasized {
    if (!cell || !person) return;

    ABOUT_CELL_NAME.text = AboutDisplayNameForPerson(person);
    ABOUT_CELL_TITLE.text = @"";
    ABOUT_CELL_SUBTITLE.text = @"";
    ABOUT_CELL_DISTRICT.text = @"";
    ABOUT_CELL_DISTRICT.textColor = [UIColor lightGrayColor];

    if ([person.party isEqualToString:@"R"]) ABOUT_CELL_DISTRICT.textColor = [UIColor redColor];
    if ([person.party isEqualToString:@"D"]) ABOUT_CELL_DISTRICT.textColor = [UIColor blueColor];

    CGRect titleFrame = ABOUT_CELL_TITLE.frame;
    titleFrame.size.width = 124.0f;
    ABOUT_CELL_TITLE.frame = titleFrame;

    if ([person.type isEqualToString:STATE_HOUSE]) {
        ABOUT_CELL_TITLE.text = @"Oklahoma Representative";
        ABOUT_CELL_SUBTITLE.text = person.titleLeadership;
        ABOUT_CELL_DISTRICT.text = [NSString stringWithFormat:@"%@%@District %@", person.party, ((person.party == nil || [[person.party trim] length] == 0) ? @"" : @"-"), person.districtNumber];
    } else if ([person.type isEqualToString:STATE_SENATE]) {
        ABOUT_CELL_TITLE.text = @"Oklahoma Senator";
        ABOUT_CELL_SUBTITLE.text = person.titleLeadership;
        ABOUT_CELL_DISTRICT.text = [NSString stringWithFormat:@"%@%@District %@", person.party, ((person.party == nil || [[person.party trim] length] == 0) ? @"" : @"-"), person.districtNumber];
    } else if ([person.type isEqualToString:STATEWIDE]) {
        ABOUT_CELL_TITLE.text = person.titleLeadership;
        ABOUT_CELL_DISTRICT.text = person.party;
    } else if ([person.type isEqualToString:FEDERAL_HOUSE]) {
        ABOUT_CELL_TITLE.text = @"US Representative";
        ABOUT_CELL_SUBTITLE.text = person.titleLeadership;
        ABOUT_CELL_DISTRICT.text = [NSString stringWithFormat:@"%@%@District %@", person.party, ((person.party == nil || [[person.party trim] length] == 0) ? @"" : @"-"), person.districtNumber];
    } else if ([person.type isEqualToString:FEDERAL_SENATE]) {
        ABOUT_CELL_TITLE.text = @"US Senator";
        ABOUT_CELL_SUBTITLE.text = person.titleLeadership;
        ABOUT_CELL_DISTRICT.text = person.party;
    } else if ([person.type isEqualToString:OAEC_MEMBER] || [person.type isEqualToString:LEGISLATIVE_CONTACT]) {
        titleFrame = ABOUT_CELL_TITLE.frame;
        titleFrame.size.width = 222.0f;
        ABOUT_CELL_TITLE.frame = titleFrame;
        ABOUT_CELL_TITLE.text = person.coopName;
        ABOUT_CELL_SUBTITLE.text = person.titleLeadership;
    } else if ([person.type isEqualToString:STATE_JUDICIARY]) {
        titleFrame = ABOUT_CELL_TITLE.frame;
        titleFrame.size.width = 222.0f;
        ABOUT_CELL_TITLE.frame = titleFrame;
        ABOUT_CELL_TITLE.text = @"State Supreme Court Justice";
        ABOUT_CELL_SUBTITLE.text = person.titleLeadership;
    }

    BOOL hasPhoto = NO;
    if (person.photo != nil && [person.photo length] > 0) {
        ABOUT_CELL_HEADSHOT.image = [UIImage imageNamed:person.photo];
        if (ABOUT_CELL_HEADSHOT.image == nil) {
            NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docsDir = [dirPaths objectAtIndex:0];
            NSString *docsPhotoFilename = [NSString stringWithFormat:@"%@/%@", docsDir, person.photo];
            ABOUT_CELL_HEADSHOT.image = [UIImage imageNamed:docsPhotoFilename];
        }
        if (ABOUT_CELL_HEADSHOT.image != nil) hasPhoto = YES;
    }

    if (hasPhoto) {
        ABOUT_CELL_HEADSHOT.hidden = NO;
        ABOUT_CELL_PHOTO_NA.hidden = YES;
    } else {
        ABOUT_CELL_HEADSHOT.hidden = YES;
        ABOUT_CELL_HEADSHOT.image = nil;
        ABOUT_CELL_PHOTO_NA.hidden = NO;
    }

    cell.layer.cornerRadius = 16.0f;
    cell.clipsToBounds = YES;
    if (@available(iOS 13.0, *)) {
        cell.layer.cornerCurve = kCACornerCurveContinuous;
    }
    cell.contentView.backgroundColor = emphasized ? [UIColor colorWithRed:0.90f green:0.96f blue:0.92f alpha:1.0f] : [UIColor colorWithWhite:1.0f alpha:0.95f];
    cell.layer.borderWidth = emphasized ? 1.0f : 0.0f;
    cell.layer.borderColor = [UIColor colorWithRed:0.11f green:0.51f blue:0.34f alpha:0.45f].CGColor;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect bounds = self.view.bounds;
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    CGFloat safeTop = 0.0f;
    CGFloat safeBottom = 0.0f;
    if (@available(iOS 11.0, *)) {
        safeTop = self.view.safeAreaInsets.top;
        safeBottom = self.view.safeAreaInsets.bottom;
    }

    CGFloat horizontalPadding = 16.0f;
    CGFloat bottomPadding = 24.0f;
    CGFloat buttonHeight = 56.0f;
    CGFloat buttonGap = 16.0f;
    CGFloat titleTop = safeTop + 12.0f;

    self.backgroundImage.frame = bounds;
    self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImage.clipsToBounds = YES;
    self.backgroundImage.alpha = 0.12f;

    self.titleLabel.frame = CGRectMake(horizontalPadding, titleTop, width - (horizontalPadding * 2.0f), 68.0f);
    self.subtitleLabel.frame = CGRectMake(horizontalPadding, CGRectGetMaxY(self.titleLabel.frame), width - (horizontalPadding * 2.0f), 0.0f);

    CGFloat searchY = CGRectGetMaxY(self.titleLabel.frame) + 8.0f;
    self.searchCueView.frame = CGRectMake(horizontalPadding, searchY, width - (horizontalPadding * 2.0f), 56.0f);
    self.searchCueView.layer.cornerRadius = 14.0f;
    self.searchBar.frame = self.searchCueView.frame;

    UITextField *searchField = [self aboutSearchTextField];
    if (searchField != nil) {
        CGRect searchFieldFrame = [self.view convertRect:searchField.bounds fromView:searchField];
        CGFloat caretX = CGRectGetMaxX(searchFieldFrame) - 18.0f;
        CGFloat caretY = CGRectGetMidY(searchFieldFrame) - 8.0f;
        self.launchCaretView.frame = CGRectMake(caretX, caretY, 2.0f, 16.0f);
    }

    CGFloat bottomButtonY = height - safeBottom - bottomPadding - buttonHeight;
    CGFloat upperButtonY = bottomButtonY - buttonGap - buttonHeight;
    CGFloat buttonWidth = width - (horizontalPadding * 2.0f);
    self.legislatureButton.frame = CGRectMake(horizontalPadding, upperButtonY, buttonWidth, buttonHeight);
    self.aboutOAECButton.frame = CGRectMake(horizontalPadding, bottomButtonY, buttonWidth, buttonHeight);
    [self stylePrimaryButton:self.legislatureButton];
    [self stylePrimaryButton:self.aboutOAECButton];

    CGFloat resultsTop = CGRectGetMaxY(self.searchBar.frame) + 14.0f;
    CGFloat resultsBottom = upperButtonY - 14.0f;
    CGFloat resultsHeight = MAX(180.0f, resultsBottom - resultsTop);
    self.resultsContainerView.frame = CGRectMake(horizontalPadding, resultsTop, width - (horizontalPadding * 2.0f), resultsHeight);
    self.resultsTableView.frame = self.resultsContainerView.bounds;
    self.emptyStateLabel.frame = CGRectInset(self.resultsContainerView.bounds, 24.0f, 20.0f);

    if (self.graphicOverlayButton) {
        self.graphicOverlayButton.hidden = YES;
        self.graphicOverlayButton.userInteractionEnabled = NO;
    }
}

- (void)stylePrimaryButton:(UIButton *)button {
    button.layer.cornerRadius = 12.0f;
    button.clipsToBounds = YES;
    if (@available(iOS 13.0, *)) {
        button.layer.cornerCurve = kCACornerCurveContinuous;
    }
}

#pragma mark - Search/Table

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    [self stopCarousel];
    [self updateLaunchCueVisibility];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    [self updateLaunchCueVisibility];
    if (![[searchBar.text trim] length]) {
        [self startCarouselIfNeeded];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self applySearchText:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self applySearchText:searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [self applySearchText:nil];
    [searchBar resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isShowingSearchResults]) {
        return self.filteredPeople.count;
    }
    return self.launchLoopPeople.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self aboutResultsCellForTableView:tableView];
    NSDictionary *person = nil;
    BOOL emphasized = NO;

    if ([self isShowingSearchResults]) {
        person = [self.filteredPeople objectAtIndex:indexPath.row];
        emphasized = (indexPath.row == 0);
    } else if (self.launchCarouselPeople.count > 0) {
        person = [self.launchCarouselPeople objectAtIndex:(indexPath.row % self.launchCarouselPeople.count)];
    }

    [self configureAboutResultCell:cell withPerson:person emphasized:emphasized];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *person = [self personForIndexPath:indexPath];
    if (person == nil) return;

    [self stopCarousel];
    [self snapCarouselToRowAtIndexPath:indexPath];
    PersonViewController *pvc = [[[PersonViewController alloc] initWithNibName:@"PersonView-iPhone" bundle:nil] autorelease];
    pvc.person = person;
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView != self.resultsTableView || [self isShowingSearchResults]) return;
    self.carouselUserDragging = YES;
    [self stopCarousel];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView != self.resultsTableView || [self isShowingSearchResults]) return;

    BOOL isDownwardSwipe = (velocity.y <= -AboutCarouselMinimumSwipeVelocity);
    BOOL shouldResumeFromPausedHold = (self.carouselPausedByHold && velocity.y > AboutCarouselMinimumSwipeVelocity);
    BOOL shouldResumeFromDownwardPause = (self.carouselPausedByDownwardDrag && velocity.y > AboutCarouselMinimumSwipeVelocity);

    if (isDownwardSwipe) {
        self.carouselPausedByDownwardDrag = YES;
        self.carouselBoostStartSpeed = 0.0f;
        self.carouselBoostStartTimestamp = 0.0;
        self.carouselDecayStopsAfterBoost = NO;
    } else if (velocity.y >= AboutCarouselMinimumSwipeVelocity) {
        CGFloat boostedSpeed = AboutCarouselBasePointsPerSecond + (velocity.y * AboutCarouselSwipeVelocityMultiplier);
        self.carouselDecayStopsAfterBoost = !(shouldResumeFromPausedHold || shouldResumeFromDownwardPause);
        if (shouldResumeFromPausedHold) {
            self.carouselPausedByHold = NO;
        }
        if (shouldResumeFromDownwardPause) {
            self.carouselPausedByDownwardDrag = NO;
        }
        [self beginCarouselSpeedDecayFromSpeed:boostedSpeed timestamp:CACurrentMediaTime()];
    } else {
        self.carouselBoostStartSpeed = 0.0f;
        self.carouselBoostStartTimestamp = 0.0;
        self.carouselDecayStopsAfterBoost = NO;
    }
    if (targetContentOffset != NULL) {
        CGFloat originalHeight = self.resultsTableView.rowHeight * (CGFloat)self.launchCarouselPeople.count;
        if (originalHeight > 0.0f && targetContentOffset->y >= originalHeight) {
            targetContentOffset->y = fmod(targetContentOffset->y, originalHeight);
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView != self.resultsTableView || [self isShowingSearchResults]) return;
    self.carouselUserDragging = NO;
    if (!decelerate) {
        [self normalizeCarouselOffsetIfNeeded];
        [self resumeCarouselIfAppropriate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.resultsTableView || [self isShowingSearchResults]) return;
    [self normalizeCarouselOffsetIfNeeded];
    [self resumeCarouselIfAppropriate];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.carouselHoldGestureRecognizer || otherGestureRecognizer == self.carouselHoldGestureRecognizer) {
        return YES;
    }
    return NO;
}

- (void)handleCarouselHoldGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer != self.carouselHoldGestureRecognizer || [self isShowingSearchResults]) return;

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.carouselTouchHolding = YES;
        self.carouselPausedByHold = YES;
        self.carouselDecayStopsAfterBoost = NO;
        [self stopCarousel];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
               gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
               gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        self.carouselTouchHolding = NO;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopCarousel];
    [_backgroundImage release];
    [_legislatureButton release];
    [_aboutOAECButton release];
    [_graphicOverlayButton release];
    [_titleLabel release];
    [_subtitleLabel release];
    [_searchCueView release];
    [_searchBar release];
    [_launchCaretView release];
    [_resultsContainerView release];
    [_resultsTableView release];
    [_emptyStateLabel release];
    [_searchablePeople release];
    [_launchCarouselPeople release];
    [_launchLoopPeople release];
    [_filteredPeople release];
    [_currentSearchText release];
    [_carouselHoldGestureRecognizer release];
    [_carouselDisplayLink release];
    [super dealloc];
}

@end
