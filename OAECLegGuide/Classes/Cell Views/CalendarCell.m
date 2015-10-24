//
//  CalendarCell.m
//  LegGuide
//
//  Created by Matt Galloway on 11/25/13.
//  Copyright (c) 2013 Architactile LLC. All rights reserved.
//

#import "CalendarCell.h"

@implementation CalendarCell

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
    [_dateLabel release];
    [_detailsTextView release];
    [super dealloc];
}
@end
