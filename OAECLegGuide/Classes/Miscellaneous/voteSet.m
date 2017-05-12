//
//  voteSet.m
//  voteTest
//
//  Created by User on 5/10/17.
//  Copyright © 2017 ZigBeef. All rights reserved.
//

#import "voteSet.h"

@implementation voteSet

- (void)setYeaVote:(NSString *)yeaVoteStatus {
    if ([self.yeaVoteEntry isEqualToString:@"checked"]) {
        self.yeaVoteEntry = @"blank";
    } else {
        self.yeaVoteEntry = @"checked";
        self.nayVoteEntry = @"blank";
    }
}

- (void)setNayVote:(NSString *)nayVoteStatus {
    if ([self.nayVoteEntry isEqualToString:@"checked"]) {
        self.nayVoteEntry = @"blank";
    } else {
        self.nayVoteEntry = @"checked";
        self.yeaVoteEntry = @"blank";
    }}


@end
