//
//  CommitteeViewCell.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 8/3/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "CommitteeViewCell.h"

@implementation CommitteeViewCell
@synthesize titleLabel;
@synthesize committeeNameLabel;
@synthesize grayBarView;

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
    [titleLabel release];
    [committeeNameLabel release];
    [grayBarView release];
    [super dealloc];
}

@end
