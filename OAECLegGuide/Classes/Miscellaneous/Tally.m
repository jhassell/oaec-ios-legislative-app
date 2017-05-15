//
//  Tally.m
//  voteTest
//
//  Created by User on 5/9/17.
//  Copyright © 2017 ZigBeef. All rights reserved.
//

#import "Tally.h"
#import <Realm/Realm.h>


@implementation Tally

-(instancetype)initWithParams:(NSInteger)voteCount
{

    int i;
    self = [super init];
    self.votes = [[NSMutableArray alloc] init];
    self.yeaButtonRef = [[NSMutableArray alloc] init];
    self.nayButtonRef = [[NSMutableArray alloc] init];
    if (self) {
        for (i=0; i< voteCount; i++)
        {
            self.votes[i] = [[NSString alloc] initWithFormat:@"%@", @"unknown"];
            self.yeaButtonRef[i] = [UIButton alloc];
            self.nayButtonRef[i] = [UIButton alloc];
        }
    }
    
    return self;
    
}


- (NSString *)description {
    return self.name;
}

@end
