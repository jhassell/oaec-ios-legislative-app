//
//  CustomTableViewHeaderCell.m
//  OAECLegGuide
//
//  Created by User on 5/21/17.
//  Copyright © 2017 Architactile LLC. All rights reserved.
//

#import "CustomTableViewHeaderCell.h"

@implementation CustomTableViewHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)dealloc {

    [super dealloc];
}


- (IBAction)CaucusPressed:(id)sender {
    NSLog(@"Something To Print");
}
@end
