//
//  NotesViewController.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 12/18/13.
//  Copyright (c) 2013 Architactile LLC. All rights reserved.
//

#import "NotesViewController.h"
#import "NSString+Stuff.h"
#import "NSDictionary+People.h"
#import "AppDelegate.h"
#import "Notes.h"
#import "EmailHelper.h"


@interface NotesViewController ()
@property (retain, nonatomic) IBOutlet UIView *headerView;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UILabel *notesForLabel;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UITextView *notesTextView;

@property (retain, nonatomic) Notes *notes;

@end

@implementation NotesViewController

#pragma mark - IB Hooks

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareButtonPressed:(id)sender {
    
    EmailHelper *emailHelper = [[EmailHelper alloc] init];
    [emailHelper emailNotes:[self.notesTextView.text trim] forName:self.notesForLabel.text fromViewController:self];
    
}

#pragma mark - UITextView Delegate Methods


- (void)textViewDidBeginEditing:(UITextView *)textView {
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.notes writeNotes:[textView.text trim]];
}


#pragma mark - Life Cycle Stuff

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (self.person!=nil) {
        
        self.notesForLabel.text = self.person.formattedFullNameWithTitle;
        self.headerView.backgroundColor=self.person.partyColor;
        
        self.notes = [[Notes alloc] init];
        self.notes.person=self.person;
        self.notesTextView.text = [self.notes readNotes];
        
        self.notesTextView.text = [NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",[self.notesTextView.text trim]];
        
        self.notesTextView.contentOffset=CGPointZero;
        
    } else {
        
        self.notesForLabel.text = @"";
    }
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (self.backButton) {
        [self.backButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self.backButton setAttributedTitle:nil forState:UIControlStateNormal];
        [self.backButton setAttributedTitle:nil forState:UIControlStateHighlighted];
        if (@available(iOS 13.0, *)) {
            UIImage *chevron = [UIImage systemImageNamed:@"chevron.left"];
            if (chevron) {
                UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium];
                chevron = [chevron imageByApplyingSymbolConfiguration:config];
                [self.backButton setImage:chevron forState:UIControlStateNormal];
                [self.backButton setTitle:nil forState:UIControlStateNormal];
                self.backButton.tintColor = [UIColor labelColor];
            }
        } else {
            [self.backButton setImage:nil forState:UIControlStateNormal];
            [self.backButton setTitle:@"\u2039" forState:UIControlStateNormal];
            self.backButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
            [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_person release];
    [_backButton release];
    [_notesForLabel release];
    [_shareButton release];
    [_notesTextView release];
    [_notes release];
    [super dealloc];
}
@end
