//
//  OutlinkCell.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 1/23/13.
//  Copyright (c) 2013 Architactile LLC. All rights reserved.
//

#import "OutlinkCell.h"
#import "RedButton.h"

@implementation OutlinkCell

- (IBAction)linkButtonPressed:(id)sender {
    
    if (self.linkUrlString==nil) return;
    
    NSURL *url = [NSURL URLWithString:self.linkUrlString];
    
    if (![[UIApplication sharedApplication] openURL:url])
        
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
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
    [_linkButton release];
    [_linkUrlString release];
    [super dealloc];
}
@end
