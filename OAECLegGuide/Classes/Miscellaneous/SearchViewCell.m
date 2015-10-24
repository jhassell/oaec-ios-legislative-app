//
//  SearchViewCell.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 8/14/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "SearchViewCell.h"

@interface SearchViewCell()


@end


@implementation SearchViewCell
@synthesize searchBar;

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
    [searchBar release];
    [super dealloc];
}
@end
