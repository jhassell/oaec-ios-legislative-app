//
//  RedButton.m
//
//  Created by Matt Galloway on 6/4/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "RedButton.h"

@implementation RedButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self useRedDeleteStyle];
    }
    return self;
}

@end

@implementation GreenButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self useGreenConfirmStyle];
    }
    return self;    
}

@end

@implementation OrangeButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self useSimpleOrangeStyle ];
    }
    return self;
}

@end

@implementation BlueButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self useAlertStyle];
    }
    return self;
}

@end

@implementation BlackButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self useBlackStyle ];
    }
    return self;
}

@end