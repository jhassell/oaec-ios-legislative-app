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
    if ([[device model] isEqualToString:@"iPhone"]) {
        NSString *phoneNumber = [self.phoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]];
        
        if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
            [[UIApplication sharedApplication] openURL:phoneURL options:@{} completionHandler:^(BOOL success) {
                if (!success) {
                    NSLog(@"Failed to open phone URL: %@", phoneURL.absoluteString);
                }
            }];
        } else {
            NSLog(@"Cannot dial phone number: %@", phoneNumber);
        }
    } else {
        [self showAlertWithTitle:@"Alert" message:@"Sorry, but I can't seem to figure out how to dial the phone on this device."];
    }
}

- (IBAction)email:(id)sender {
    [pvc emailButtonPressed:sender];
}

- (IBAction)mapButtonPressed:(id)sender {
    NSString *addrurl = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@, %@", addressLine1.text, addressLine2.text];
    NSLog(@"addurl = %@", addrurl);
    
    NSString *escapedAddress = [addrurl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:escapedAddress];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            if (!success) {
                NSLog(@"Failed to open Maps URL: %@", url.absoluteString);
            }
        }];
    } else {
        [self showAlertWithTitle:@"Error" message:@"Cannot open the Maps URL."];
    }
}

// Helper method to show alerts using UIAlertController
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];

    [alertController addAction:okAction];

    // Present the alert on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
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
