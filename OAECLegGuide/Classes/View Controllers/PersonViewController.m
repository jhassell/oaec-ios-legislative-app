//
//  PersonViewController.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 8/2/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "PersonViewController.h"
#import "NSDictionary+People.h"
#import "AppDelegate.h"
#import "NSString+Stuff.h"
#import "ListSection.h"
#import "Address.h"
#import "AddressViewCell.h"
#import "CommitteeViewCell.h"
#import "Committee.h"
#import "PeopleListViewController.h"
#import "MapsViewController.h"
#import "AddressLAViewCell.h"
#import "OutlinkCell.h"
#import "NotesViewController.h"
#import "Notes.h"
#import "EmailHelper.h"

#define SECTION_COUNTIES   @"Counties"
#define SECTION_COOP_PROFILE @"Co-op Profile"
#define SECTION_ADDRESSES  @"Addresses"
#define SECTION_COMMITTEE  @"Committee"
#define SECTION_NOTES      @"Notes"
#define SECTION_OUTLINK    @"Outlink"

#define ADDRESS_LINE_HEIGHT 38.0f
#define ADDRESS_LA_HEIGHT 55.0f

@interface PersonViewController () {
    CGFloat _scrollOffsetY;
    CGFloat noteHeight;
    BOOL firstLoad;
}

@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UITableView *table;
@property (retain, nonatomic) IBOutlet UIView *personHeaderView;
@property (retain, nonatomic) IBOutlet UILabel *officeLabel;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *partyAndDistrictLabel;
@property (retain, nonatomic) IBOutlet UILabel *termLimitLabel;

@property (retain, nonatomic) IBOutlet UIButton *mainEmailButton;
@property (retain, nonatomic) IBOutlet UIButton *facebookButton;
@property (retain, nonatomic) IBOutlet UIButton *twitterButton;
@property (retain, nonatomic) IBOutlet UIButton *linkedInButton;
@property (retain, nonatomic) IBOutlet UIButton *webpageButton;

@property (retain, nonatomic) IBOutlet UIView *photoNAView;
@property (retain, nonatomic) IBOutlet UIImageView *headshotView;
@property (retain, nonatomic) IBOutlet UITableViewCell *countiesCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *committeeHeaderCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *notesHeaderCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *notesCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *coopProfileCell;


@property (retain, nonatomic) IBOutlet UILabel *notesLabel;
@property (retain, nonatomic) IBOutlet UILabel *notesInstructionLabel;
@property (retain, nonatomic) IBOutlet UIButton *shareNotesButton;

@property (retain, nonatomic) NSString *noteText;

@property (retain, nonatomic) IBOutlet UITextView *countiesListLabel;
@property (retain, nonatomic) IBOutlet UILabel *countiesListTitleLabel;
@property (retain, nonatomic) IBOutlet UIButton *countyMapButton;

@property (retain, nonatomic) IBOutlet UILabel *typeOfCoopLabel;
@property (retain, nonatomic) IBOutlet UILabel *milesOfLineLabel;
@property (retain, nonatomic) IBOutlet UILabel *activeMetersLabel;
@property (retain, nonatomic) IBOutlet UILabel *activeMetersPerMileLabel;
@property (retain, nonatomic) IBOutlet UILabel *numberOfEmployeesLabel;

@property (retain, nonatomic) IBOutlet UIView *headshotModalView;
@property (retain, nonatomic) IBOutlet UIImageView *headshotImageView;
@property (retain, nonatomic) IBOutlet UIButton *headshotButton;

@property (retain, nonatomic) NSMutableArray *sections;

- (IBAction)headshotButtonPressed:(id)sender;
- (IBAction)headshotModelCloseButtonPressed:(id)sender;
- (IBAction)backButtonPressed:(id)sender;
- (IBAction)facebookButtonPressed:(id)sender;
- (IBAction)twitterButtonPressed:(id)sender;
- (IBAction)linkedInButtonPressed:(id)sender;
- (IBAction)webButtonPressed:(id)sender;
- (IBAction)districtMapButtonPressed:(id)sender;

@end

@implementation PersonViewController

@synthesize backButton=_backButton;
@synthesize table=_table;
@synthesize personHeaderView=_personHeaderView;
@synthesize officeLabel=_officeLabel;
@synthesize nameLabel=_nameLabel;
@synthesize titleLabel=_titleLabel;
@synthesize partyAndDistrictLabel=_partyAndDistrictLabel;
@synthesize termLimitLabel = _termLimitLabel;
@synthesize mainEmailButton=_mainEmailButton;
@synthesize facebookButton=_facebookButton;
@synthesize twitterButton=_twitterButton;
@synthesize linkedInButton=_linkedInButton;
@synthesize webpageButton=_webpageButton;
@synthesize photoNAView = _photoNAView;
@synthesize headshotView = _headshotView;
@synthesize countiesCell = _countiesCell;
@synthesize committeeHeaderCell = _committeeHeaderCell;
@synthesize notesHeaderCell = _notesHeaderCell;
@synthesize notesCell = _notesCell;
@synthesize countiesListLabel = _countiesListLabel;
@synthesize countiesListTitleLabel = _countiesListTitleLabel;
@synthesize countyMapButton = _countyMapButton;
@synthesize sections=_sections;

@synthesize person=_person;

-(NSString *) addNewLineForStates:(NSString *)countiesConvered {
    
    NSString *newString = [NSString stringWithString:countiesConvered];
    
    newString = [newString stringByReplacingOccurrencesOfString:@"AL:" withString:@"\nAL:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"AK:" withString:@"\nAK:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"AZ:" withString:@"\nAZ:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"AR:" withString:@"\nAR:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"CA:" withString:@"\nCA:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"CO:" withString:@"\nCO:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"CT:" withString:@"\nCT:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"DE:" withString:@"\nDE:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"FL:" withString:@"\nFL:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"GA:" withString:@"\nGA:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"HI:" withString:@"\nHI:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"ID:" withString:@"\nID:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"IL:" withString:@"\nIL:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"IN:" withString:@"\nIN:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"IA:" withString:@"\nIA:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"KS:" withString:@"\nKS:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"KY:" withString:@"\nKY:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"LA:" withString:@"\nLA:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"ME:" withString:@"\nME:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"MD:" withString:@"\nMD:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"MA:" withString:@"\nMA:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"MI:" withString:@"\nMI:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"MN:" withString:@"\nMN:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"MS:" withString:@"\nMS:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"MO:" withString:@"\nMO:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"MT:" withString:@"\nMT:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"NE:" withString:@"\nNE:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"NV:" withString:@"\nNV:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"NH:" withString:@"\nNH:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"NJ:" withString:@"\nNJ:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"NM:" withString:@"\nNM:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"NY:" withString:@"\nNY:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"NC:" withString:@"\nNC:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"ND:" withString:@"\nND:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"OH:" withString:@"\nOH:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"OK:" withString:@"\nOK:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"OR:" withString:@"\nOR:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"PA:" withString:@"\nPA:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"RI:" withString:@"\nRI:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"SC:" withString:@"\nSC:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"SD:" withString:@"\nSD:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"TN:" withString:@"\nTN:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"TX:" withString:@"\nTX:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"UT:" withString:@"\nUT:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"VT:" withString:@"\nVT:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"VA:" withString:@"\nVA:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"WA:" withString:@"\nWA:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"WV:" withString:@"\nWV:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"WI:" withString:@"\nWI:"];
    newString = [newString stringByReplacingOccurrencesOfString:@"WY:" withString:@"\nWY:"];
    
    if ([@"\n" isEqualToString:[newString substringToIndex:1]]) {
        
        newString = [newString substringFromIndex:1];
    
    }
    
    return newString;
    
}

-(IBAction) weblink {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] weblink];
}

#pragma mark - Mailer Delegate Stuff

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UI Hooks

- (IBAction)headshotButtonPressed:(id)sender {
    
    self.headshotModalView.alpha=0.0;
    self.headshotModalView.hidden = NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    self.headshotModalView.alpha = 1.0;
    
    [UIView commitAnimations];
    
}

-(void) hideHeadhotModal {
    self.headshotModalView.hidden=YES;
}

- (IBAction)headshotModelCloseButtonPressed:(id)sender {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.headshotModalView.alpha = 0.0;
    [UIView commitAnimations];
    
    [self performSelector:@selector(hideHeadhotModal) withObject:nil afterDelay:0.6];
    
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)emailButtonPressed:(id)sender {

    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@""];
        NSArray *toRecipients = [NSArray arrayWithObjects:[self.person.email trim], nil];
        [mailer setToRecipients:toRecipients];
        
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        
//        [self presentModalViewController:mailer animated:YES];
        [self presentViewController:mailer animated:YES completion:nil];
        [mailer release];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Send Mail"
                                                        message:@"Sorry, your device doesn't support sending email."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
}

- (IBAction)facebookButtonPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:[self.person.facebook trim]];
    if (![[UIApplication sharedApplication] openURL:url])
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}

- (IBAction)twitterButtonPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:[self.person.twitter trim]];
    if (![[UIApplication sharedApplication] openURL:url])
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}

- (IBAction)linkedInButtonPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:[self.person.linkedIn trim]];
    if (![[UIApplication sharedApplication] openURL:url])
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}

- (IBAction)webButtonPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:[self.person.webpage trim]];
    if (![[UIApplication sharedApplication] openURL:url])
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}

- (IBAction)districtMapButtonPressed:(id)sender {
    
    MapsViewController *mvp = [[[MapsViewController alloc] initWithNibName:@"MapView-iPhone" bundle:nil] autorelease];
    
    mvp.person = self.person;
    
    [self.navigationController pushViewController:mvp animated:YES];
    
}

- (IBAction)shareButtonPressed:(id)sender {
    
    EmailHelper *emailHelper = [[EmailHelper alloc] init];
    [emailHelper emailNotes:[self.noteText trim] forName:self.person.formattedFullNameWithTitle fromViewController:self];
    
}


#pragma mark - Populate Notes

-(void) populateNotes {
    self.notesLabel.numberOfLines=0;
    Notes *notes = [[Notes alloc] init];
    notes.person=self.person;
    self.noteText = [notes readNotes];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.sections==nil) return 0;
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.sections==nil) return 0;
    ListSection *listSection = [self.sections objectAtIndex:section];
    if (listSection.children==nil) return 0; 
    return [listSection.children count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Cell for %i->%i",indexPath.section,indexPath.row);

    UITableViewCell *cell=nil;
    
    //static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    ListSection *listSection = [self.sections objectAtIndex:indexPath.section];
    
    if ([listSection.title isEqualToString:SECTION_COUNTIES]) {
        cell=self.countiesCell;
        self.countiesListLabel.text = [self addNewLineForStates:[self.person.countiesCovered stringByReplacingOccurrencesOfString:@"~" withString:@","]];
        
        if (([self.person.type isEqualToString:STATE_HOUSE] || [self.person.type isEqualToString:STATE_SENATE]) && self.person.homeCity!=nil && [self.person.homeCity trim].length>0) {
            
            self.countiesListLabel.text = [NSString stringWithFormat:@"Home Town: %@\nCounties: %@",self.person.homeCity,self.countiesListLabel.text];
        }

    } else if ([listSection.title isEqualToString:SECTION_NOTES]) {
        
        cell=self.notesCell;
        
        [self populateNotes];
        
        if ([NSString isBlankOrNil:self.noteText]) {
            self.notesInstructionLabel.hidden=NO;
            self.shareNotesButton.hidden=YES;
        } else {
            self.notesInstructionLabel.hidden=YES;
            self.shareNotesButton.hidden=NO;
        }
        
        self.notesLabel.text=self.noteText;
        
        NSLog(@"*%@*",self.notesLabel.text);

        self.notesLabel.numberOfLines=0;
        self.notesLabel.frame = CGRectMake(self.notesLabel.frame.origin.x,
                                           self.notesLabel.frame.origin.y,
                                           300.0, 10.0);
        [self.notesLabel sizeToFit];

    } else if ([listSection.title isEqualToString:SECTION_COOP_PROFILE]) {

        NSNumberFormatter *numberFormat = [[[NSNumberFormatter alloc] init] autorelease];
        numberFormat.usesGroupingSeparator = YES;
        numberFormat.groupingSeparator = @",";
        numberFormat.groupingSize = 3;
        
        cell=self.coopProfileCell;
        self.typeOfCoopLabel.text=self.person.coopType;
        self.milesOfLineLabel.text= [numberFormat stringFromNumber:[NSNumber numberWithInt:[self.person.milesOfLines intValue]]];
        self.numberOfEmployeesLabel.text=[numberFormat stringFromNumber:[NSNumber numberWithInt:[self.person.employees intValue]]];
        self.activeMetersLabel.text=[numberFormat stringFromNumber:[NSNumber numberWithInt:[self.person.activeMeters intValue]]];
        self.activeMetersPerMileLabel.text=[numberFormat stringFromNumber:[NSNumber numberWithInt:[self.person.activeMetersMiles intValue]]];
        
    } else if ([listSection.title isEqualToString:SECTION_ADDRESSES] && [[listSection.children objectAtIndex:indexPath.row] isKindOfClass:[Address class]] ) {

        Address *address = [listSection.children objectAtIndex:indexPath.row];
                
        static NSString *AddressCellIdentifier = @"AddressCell";
        AddressViewCell *addressCell = [tableView dequeueReusableCellWithIdentifier:AddressCellIdentifier];
        
        if (addressCell == nil) {
            addressCell = [[[NSBundle mainBundle] loadNibNamed:@"PersonViewAddressCell-iPhone" owner:nil options:nil] objectAtIndex:0];
        }
        
        CGFloat baseHeight = 165.0f;
        
        //NSLog(@"baseHeight %f",baseHeight);
        
        if (address.phone==nil || [[address.phone trim] length]==0) {
            baseHeight-=ADDRESS_LINE_HEIGHT;
        }
        
        if (address.email==nil || [[address.email trim] length]==0) {
            baseHeight-=ADDRESS_LINE_HEIGHT;
        }
        
        //NSLog(@"Resetting frame height to %f",baseHeight);
        
        addressCell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, baseHeight);
        
        addressCell.pvc=self;
        addressCell.name.text = address.name;
        addressCell.addressLine1.text = [NSString stringWithFormat:@"%@%@%@",address.address,([NSString isBlankOrNil:address.roomNumber]?@"":@", "),([NSString isBlankOrNil:address.roomNumber]?@"":address.roomNumber)];
        
        if (address.city==nil || [[address.city trim] length]==0) {
            addressCell.addressLine2.text = [NSString stringWithFormat:@"%@ %@",address.state,address.zip];
        } else {
            addressCell.addressLine2.text = [NSString stringWithFormat:@"%@, %@ %@",address.city,address.state,address.zip];
        }
        
        if ([NSString isBlankOrNil:address.email]) {
            addressCell.emailAddress.text=nil;
            addressCell.emailAddress.hidden=YES;
            addressCell.emailButton.hidden=YES;
            addressCell.emailInvisibleButton.hidden=YES;
        } else {
            addressCell.emailAddress.text=address.email;
            addressCell.emailAddress.hidden=NO;
            addressCell.emailButton.hidden=NO;
            addressCell.emailInvisibleButton.hidden=NO;
        }

        if ([NSString isBlankOrNil:address.phone]) {
            addressCell.phoneNumber.text=nil;
            addressCell.phoneNumber.hidden=YES;
            addressCell.phoneButton.hidden=YES;
            addressCell.phoneInvisibleButton.hidden=YES;
        } else {
            addressCell.phoneNumber.text=address.phone;
            addressCell.phoneNumber.hidden=NO;
            addressCell.phoneButton.hidden=NO;
            addressCell.phoneInvisibleButton.hidden=NO;
        }
        
        UIDevice *device = [UIDevice currentDevice];
        
        if (![[device model] isEqualToString:@"iPhone"] ) {
            addressCell.phoneButton.hidden=YES;
            addressCell.phoneInvisibleButton.hidden=YES;
            addressCell.phoneNumber.textColor=[UIColor whiteColor];
        } else {
            addressCell.phoneNumber.textColor=addressCell.emailAddress.textColor;
        }
        
        cell=addressCell;
    } else if ([listSection.title isEqualToString:SECTION_ADDRESSES]) {
        
        static NSString *AddressLACellIdentifier = @"AddressLACell";
       AddressLAViewCell *laCell = [tableView dequeueReusableCellWithIdentifier:AddressLACellIdentifier];

        if (laCell == nil) {
            laCell = [[[NSBundle mainBundle] loadNibNamed:@"PersonViewAddressLACell-iPhone" owner:nil options:nil] objectAtIndex:0];
        }
        
        laCell.laNameLabel.text = [listSection.children objectAtIndex:indexPath.row];
        
        
        if ([self.person.type isEqualToString:STATE_SENATE]) {
            laCell.assistantTitleLabel.text = @"Executive Assistant";
        }

        cell=laCell;
         
    } else if ([listSection.title isEqualToString:SECTION_COMMITTEE] && indexPath.row==0) {

        cell=self.committeeHeaderCell;
        
    } else if ([listSection.title isEqualToString:SECTION_COMMITTEE]) {
        
        Committee *committee = [listSection.children objectAtIndex:indexPath.row];
        
        static NSString *CommitteeCellIdentifier = @"CommitteeCell";
        CommitteeViewCell *committeeCell = [tableView dequeueReusableCellWithIdentifier:CommitteeCellIdentifier];
        
        if (committeeCell == nil) {
            committeeCell = [[[NSBundle mainBundle] loadNibNamed:@"PersonViewCommitteeCell-iPhone" owner:nil options:nil] objectAtIndex:0];
        }
    
        committeeCell.titleLabel.text = [NSString stringWithFormat:@"%@ on",committee.type];
        committeeCell.committeeNameLabel.text = committee.name;
        
        if (indexPath.row % 2 != 0) {
            committeeCell.grayBarView.hidden = YES;
            committeeCell.titleLabel.textColor=[UIColor lightGrayColor];
        } else {
            committeeCell.grayBarView.hidden = NO;
            committeeCell.titleLabel.textColor=[UIColor darkGrayColor];            
        }
        
        cell=committeeCell;
    } else if ([listSection.title isEqualToString:SECTION_OUTLINK]) {
        
        cell = [listSection.children objectAtIndex:0];

    }
    
    return cell;
}

#pragma mark - Table view delegate

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Height for %li->%i",(long)indexPath.section,(int)indexPath.row);
    ListSection *listSection = [self.sections objectAtIndex:indexPath.section];
    
    if (indexPath.row==0 && listSection.firstRowHeight>0.5) {
        NSLog(@"Returning %f",listSection.firstRowHeight);
        
        return listSection.firstRowHeight;
    } else if  ([listSection.title isEqualToString:SECTION_NOTES]) {
        
        CGFloat delta = 125.0-76.0;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 10.0)];
        label.numberOfLines=0;
        label.font=[UIFont systemFontOfSize:20.0];
        label.text = self.noteText;
        [label sizeToFit];
        NSLog(@"label.text = *%@*",label.text);
        CGSize size = label.frame.size;
        
        if (size.height<76.0) {
            return 125.0;
        } else {
            return delta + size.height;
        }
        
    } else if ([listSection.title isEqualToString:SECTION_ADDRESSES] && [[listSection.children objectAtIndex:indexPath.row] isKindOfClass:[Address class]]) {
        
        CGFloat baseHeight = listSection.rowHeight;
        
        Address *address = [listSection.children objectAtIndex:indexPath.row];
        
        if (address.phone==nil || [[address.phone trim] length]==0) {
            baseHeight-=ADDRESS_LINE_HEIGHT;
        }
        
        if (address.email==nil || [[address.email trim] length]==0) {
            baseHeight-=ADDRESS_LINE_HEIGHT;
        }
        
        NSLog(@"2 returning cell height of %f",baseHeight);
        
        return baseHeight;
    } else if ([listSection.title isEqualToString:SECTION_ADDRESSES]) {
        
        NSLog(@"3 returning cell height of %f",ADDRESS_LA_HEIGHT);

        return ADDRESS_LA_HEIGHT;
    }

    NSLog(@"4 returning cell height of %f",listSection.rowHeight);

    return listSection.rowHeight;
}


-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ListSection *listSection = [self.sections objectAtIndex:indexPath.section];
    
    if ([listSection.title isEqualToString:SECTION_COMMITTEE] && indexPath.row>0) return indexPath;

    if ([listSection.title isEqualToString:SECTION_NOTES] ) return indexPath;
    
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ListSection *listSection = [self.sections objectAtIndex:indexPath.section];
    
    if ([listSection.title isEqualToString:SECTION_COMMITTEE] && indexPath.row>0) {
        
        Committee *committee = [listSection.children objectAtIndex:indexPath.row];
        
        PeopleListViewController *plvc = [[[PeopleListViewController alloc] initWithNibName:@"PeopleListView-iPhone" bundle:nil] autorelease];
        
        ListSection *ls1 = [[[ListSection alloc] init] autorelease];
        
        ls1.title = committee.name;
        ls1.children = committee.members;
        
        plvc.sections = [NSArray arrayWithObject:ls1];
        
        plvc.committee = committee;
        
        [self.navigationController pushViewController:plvc animated:YES];
        
    } else if ([listSection.title isEqualToString:SECTION_NOTES]) {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        NotesViewController *notesController = [sb instantiateViewControllerWithIdentifier:@"Notes"];
        notesController.person=self.person;
        [self.navigationController pushViewController:notesController animated:YES];
        
    }
    
}



#pragma mark - Life Cycle Stuff

-(void) setButton:(UIButton *) button forValue:(NSString *)value {
    if (value==nil || [[value trim] length]==0) {
        button.enabled=NO;
        button.alpha=0.30f;
    } else {
        button.enabled=YES;
        button.alpha=1.00f;
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    if (firstLoad) {
        firstLoad=NO;
        self.table.tableHeaderView=self.personHeaderView;
        
        if ([@"VACANT" caseInsensitiveCompare:[self.person.firstName trim]]==NSOrderedSame) {
            self.nameLabel.text  = @"Seat Vacant";
        } else {
            self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",self.person.firstName,self.person.lastName];
        }
        
        [self setButton:self.mainEmailButton forValue:self.person.email];
        [self setButton:self.facebookButton forValue:self.person.facebook];
        [self setButton:self.twitterButton forValue:self.person.twitter];
        [self setButton:self.linkedInButton forValue:self.person.linkedIn];
        [self setButton:self.webpageButton forValue:self.person.webpage];
        
        self.officeLabel.text=@"";
        self.titleLabel.text=@"";
        self.partyAndDistrictLabel.text=@"";
        self.partyAndDistrictLabel.textColor=[UIColor darkGrayColor];
        self.termLimitLabel.text=@"";
        
        self.partyAndDistrictLabel.textColor=[UIColor whiteColor];
        self.partyAndDistrictLabel.backgroundColor = [UIColor clearColor];
        
        if ([self.person.party isEqualToString:@"R"]) self.partyAndDistrictLabel.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
        if ([self.person.party isEqualToString:@"D"]) self.partyAndDistrictLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5];
        
        if (self.person.termLimit!=nil && [[self.person.termLimit trim] length]>0) {
            self.termLimitLabel.text=[NSString stringWithFormat:@"Term Limit %@",self.person.termLimit];
        }
        
        
        NSString *workAddressName = @"Legislative Office";
        self.countyMapButton.hidden=NO;
        
        
        if ([self.person.type isEqualToString:STATE_HOUSE]) {
            self.officeLabel.text=@"Oklahoma Representative";
            self.titleLabel.text=self.person.titleLeadership;
            self.partyAndDistrictLabel.text = [NSString stringWithFormat:@"%@%@District %@",self.person.party,((self.person.party==nil || [[self.person.party trim] length]==0)?@"":@"-"),self.person.districtNumber];
            self.countiesListTitleLabel.text = [NSString stringWithFormat:@"District %@ Counties",self.person.districtNumber];
        } else if ([self.person.type isEqualToString:STATE_SENATE]) {
            self.officeLabel.text=@"Oklahoma Senator";
            self.titleLabel.text=self.person.titleLeadership;
            self.partyAndDistrictLabel.text = [NSString stringWithFormat:@"%@%@District %@",self.person.party,((self.person.party==nil || [[self.person.party trim] length]==0)?@"":@"-"),self.person.districtNumber];
            self.countiesListTitleLabel.text = [NSString stringWithFormat:@"District %@ Counties",self.person.districtNumber];
        } else if ([self.person.type isEqualToString:STATEWIDE]) {
            self.officeLabel.text=self.person.titleLeadership;
            self.partyAndDistrictLabel.text = self.person.party;
        } else if ([self.person.type isEqualToString:FEDERAL_HOUSE]) {
            self.officeLabel.text=@"US Representative";
            self.titleLabel.text=self.person.titleLeadership;
            self.partyAndDistrictLabel.text = [NSString stringWithFormat:@"%@%@District %@",self.person.party,((self.person.party==nil || [[self.person.party trim] length]==0)?@"":@"-"),self.person.districtNumber];
            self.countiesListTitleLabel.text = [NSString stringWithFormat:@"District %@ Counties",self.person.districtNumber];
        } else if ([self.person.type isEqualToString:FEDERAL_SENATE]) {
            self.officeLabel.text=@"US Senator";
            self.titleLabel.text=self.person.titleLeadership;
            self.partyAndDistrictLabel.text = self.person.party;
        } else if ([self.person.type isEqualToString:STATE_JUDICIARY]) {
            self.officeLabel.text=@"Oklahoma Supreme Court Justice";
            self.titleLabel.text=self.person.titleLeadership;
            self.partyAndDistrictLabel.text = self.person.party;
        } else if ([self.person.type isEqualToString:OAEC_MEMBER]) {
            workAddressName = @"Contact Info";
            self.countiesListTitleLabel.text=@"Counties Covered";
            self.countyMapButton.hidden=YES;
            self.titleLabel.text=self.person.titleLeadership;
            self.officeLabel.text = self.person.coopName;
        } else if ([self.person.type isEqualToString:LEGISLATIVE_CONTACT]) {
            workAddressName = @"Contact Info";
            self.countyMapButton.hidden=YES;
            self.titleLabel.text=self.person.titleLeadership;
            self.officeLabel.text = self.person.coopName;
        }
        
        BOOL hasPhoto=NO;
        
        if (self.person.photo!=nil && [self.person.photo length]>0) {
            self.headshotView.image=[UIImage imageNamed:self.person.photo];
            if (self.headshotView.image!=nil) {
                hasPhoto=YES;
                self.headshotImageView.image=[UIImage imageNamed:self.person.photo];
                self.headshotButton.enabled=YES;
        } else {
            //Attempt retrieve for photo in device Documents folder
            NSArray *dirPaths;
            NSString *docsDir;
            dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            docsDir = [dirPaths objectAtIndex:0];
            NSString *docsPhotoFilename = [NSString stringWithFormat:@"%@/%@", docsDir, self.person.photo];
            self.headshotView.image = [UIImage imageNamed:docsPhotoFilename];
            
            if (self.headshotView.image != nil) {
                hasPhoto=YES;
                self.headshotImageView.image = [UIImage imageNamed:docsPhotoFilename];
                self.headshotButton.enabled=YES;
            } else {
                hasPhoto=NO;
                self.headshotButton.enabled=NO;
            }
        }
    }
    
        if (hasPhoto) {
            self.headshotView.hidden=NO;
            self.photoNAView.hidden=YES;
        } else {
            self.headshotView.hidden=YES;
            self.headshotView.image=nil;
            self.photoNAView.hidden=NO;
        }
        
        self.sections=[NSMutableArray arrayWithCapacity:5];
        
        if ([self.person.type isEqualToString:OAEC_MEMBER]) {
            
            [self populateNotes];
            
            ListSection *section = [[[ListSection alloc] init] autorelease];
            section.title = SECTION_COOP_PROFILE;
            section.children = [NSMutableArray arrayWithCapacity:1];
            [section.children addObject:SECTION_COOP_PROFILE];
            section.rowHeight=165.0f;
            section.firstRowHeight=0.0f;
            
            [self.sections addObject:section];
        }
        
        if (self.person.countiesCovered!=nil && [[self.person.countiesCovered trim] length]>0) {
            
            ListSection *section = [[[ListSection alloc] init] autorelease];
            
            section.title = SECTION_COUNTIES;
            section.children = [NSMutableArray arrayWithCapacity:1];
            [section.children addObject:[NSString stringWithString:self.person.countiesCovered]];
            section.rowHeight=165.0f;
            section.firstRowHeight=0.0f;
            
            [self.sections addObject:section];
        }
        
        NSString *email = nil;
        
        if (![NSString isBlankOrNil:self.person.email]) {
            email = [self.person.email trim];
        }
        
        ListSection *addressSection = [[[ListSection alloc] init] autorelease];
        
        addressSection.title = SECTION_ADDRESSES;
        addressSection.children = [NSMutableArray arrayWithCapacity:1];
        addressSection.rowHeight=165.0f;
        addressSection.firstRowHeight=0.0f;
        
        Address *address1 = [[[Address alloc] init] autorelease];
        
        address1.name = workAddressName;
        address1.address = self.person.officeAddress;
        address1.roomNumber = self.person.officeRmNumber;
        address1.city = self.person.officeCity;
        address1.state = self.person.officeState;
        address1.zip = self.person.officeZip;
        address1.phone = self.person.officePhone;
        address1.email = email;
        
        if (![address1 isEmpty]) {
            [addressSection.children addObject:address1];
        }
        
        if (self.person.laName!=nil && [[self.person.laName trim] length]>0) {
            
            [addressSection.children addObject:self.person.laName];
            
        }
        
        Address *address2 = [[[Address alloc] init] autorelease];
        
        address2.name = @"District Office";
        address2.address = self.person.homeAddress;
        address2.roomNumber = nil;
        address2.city = self.person.homeCity;
        address2.state = self.person.homeState;
        address2.zip = self.person.homeZip;
        address2.phone = self.person.districtPhone;
        address2.email = email;
        
        if (![address2 isEmpty] && address2.address!=nil && [[address2.address trim] length]>0) {
            [addressSection.children addObject:address2];
        }
        
        if ([addressSection.children count]>0) {
            [self.sections addObject:addressSection];
        }
        
        if (self.person.committees!=nil && [self.person.committees count]>0) {
            ListSection *committeeSection = [[[ListSection alloc] init] autorelease];
            
            committeeSection.title = SECTION_COMMITTEE;
            committeeSection.children = [NSMutableArray arrayWithCapacity:1];
            committeeSection.rowHeight=85.0f;
            committeeSection.firstRowHeight=50.0;
            
            [committeeSection.children addObject:@"Committees"];
            
            for(Committee *committee in self.person.committees) {
                NSLog(@"Person %@ %@ Committee %@",self.person.firstName,self.person.lastName,committee.name);
                [committeeSection.children addObject:committee];
            }
            
            [self.sections addObject:committeeSection];
        }
        
        if (![self.person.type isEqualToString:OAEC_MEMBER]) {
            ListSection *section = [[[ListSection alloc] init] autorelease];
            section.title = SECTION_NOTES;
            section.children = [NSMutableArray arrayWithCapacity:1];
            [section.children addObject:SECTION_NOTES];
            section.rowHeight=125.0f;
            section.firstRowHeight=0.0f;
            [self.sections addObject:section];
            
        }
        
        
        
        ListSection *findAnErrorSection = [[[ListSection alloc] init] autorelease];
        
        findAnErrorSection.title = SECTION_OUTLINK;
        findAnErrorSection.children = [NSMutableArray arrayWithCapacity:1];
        findAnErrorSection.rowHeight=104.0f;
        findAnErrorSection.firstRowHeight=104.0f;
        
        OutlinkCell *outlinkCell = [[[NSBundle mainBundle] loadNibNamed:@"OutlinkCell-iPhone" owner:nil options:nil] objectAtIndex:0];
        
        outlinkCell.linkUrlString=@"mailto:showeth@oaec.coop,jreese@oaec.coop,intern@okl.coop?subject=OAEC%20iPhone%20App,%20Inaccuracy";
        
        [findAnErrorSection.children addObject:outlinkCell];
        [self.sections addObject:findAnErrorSection];
        
        [self.table reloadData];

    } else {
        [self populateNotes];
        [self.table reloadData];
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self populateNotes];
    firstLoad=YES;
}

- (void)viewDidUnload
{
    [self setShareNotesButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
    [_backButton release];
    [_table release];
    [_personHeaderView release];
    [_officeLabel release];
    [_nameLabel release];
    [_titleLabel release];
    [_partyAndDistrictLabel release];
    [_mainEmailButton release];
    [_facebookButton release];
    [_twitterButton release];
    [_linkedInButton release];
    [_webpageButton release];
    [_photoNAView release];
    [_headshotView release];
    [_countiesCell release];
    [_committeeHeaderCell release];
    [_notesHeaderCell release];
    [_notesCell release];
    [_notesLabel release];
    [_countiesListLabel release];
    [_countiesListTitleLabel release];
    [_termLimitLabel release];
    [_countyMapButton release];
    [_coopProfileCell release];
    [_typeOfCoopLabel release];
    [_milesOfLineLabel release];
    [_activeMetersLabel release];
    [_activeMetersPerMileLabel release];
    [_numberOfEmployeesLabel release];
    [_headshotModalView release];
    [_headshotImageView release];
    [_headshotButton release];
    [_noteText release];
    [_shareNotesButton release];
    [super dealloc];
}
@end
