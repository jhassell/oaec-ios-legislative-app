//
//  CommitteeListViewCell.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 9/22/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "CommitteeListViewCell.h"

@implementation CommitteeListViewCell
@synthesize committeeNameLabel;

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
    [committeeNameLabel release];
    [super dealloc];
}
@end
