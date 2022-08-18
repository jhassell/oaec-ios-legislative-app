//
//  AddressLAViewCell.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 8/27/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "AddressLAViewCell.h"

@implementation AddressLAViewCell
@synthesize laNameLabel;
@synthesize laEmailLabel;
@synthesize pvc;


- (IBAction)email:(id)sender {
    [pvc emailButtonPressed:sender];
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
    [laNameLabel release];
    [laEmailLabel release];
    [_assistantTitleLabel release];
    [super dealloc];
}
@end
