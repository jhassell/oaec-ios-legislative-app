//
//  AddressViewCell.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 8/3/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "AddressViewCell.h"

@implementation AddressViewCell
@synthesize name;
@synthesize addressLine1;
@synthesize addressLine2;
@synthesize phoneNumber;
@synthesize emailAddress;
@synthesize phoneInvisibleButton;
@synthesize emailInvisibleButton;
@synthesize phoneButton;
@synthesize emailButton;
@synthesize mapButton;
@synthesize pvc;


- (IBAction)dial:(id)sender {
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:/open?addresses=%@",self.phoneNumber.text]]];
    } else {
        UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Sorry, but I can't seem to figure out how to dial the phone on this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [Notpermitted show];
        [Notpermitted release];
    }
}

- (IBAction)email:(id)sender {
    [pvc emailButtonPressed:sender];
}

- (IBAction)mapButtonPressed:(id)sender {
    NSString *addrurl = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@, %@",addressLine1.text,addressLine2.text];
    NSLog(@"addurl = %@",addrurl);
    
    NSURL *url = [NSURL URLWithString:[addrurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];

}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [name release];
    [addressLine1 release];
    [addressLine2 release];
    [phoneNumber release];
    [emailAddress release];
    [phoneInvisibleButton release];
    [emailInvisibleButton release];
    [phoneButton release];
    [emailButton release];
    [mapButton release];
    [super dealloc];
}
@end
