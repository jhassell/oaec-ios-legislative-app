//
//  CommitteeHeaderView.m
//  LegGuide
//
//  Created by Matt Galloway on 1/26/14.
//  Copyright (c) 2014 Architactile LLC. All rights reserved.
//

#import "CommitteeHeaderView.h"

@implementation CommitteeHeaderView

- (void)dealloc {
    [_chamberLabel release];
    [_committeeNameLabel release];
    [_meetsLabel release];
    [_roomLabel release];
    [_meetsLabelLabel release];
    [_roomLabelLabel release];
    [_committeeSubtypeLabel release];
    [super dealloc];
}
@end
