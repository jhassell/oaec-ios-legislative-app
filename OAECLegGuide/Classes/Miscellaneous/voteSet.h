//
//  voteSet.h
//  voteTest
//
//  Created by User on 5/10/17.
//  Copyright © 2017 ZigBeef. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface voteSet : NSObject

@property (nonatomic) NSString *yeaVoteEntry;
@property (nonatomic) NSString *nayVoteEntry;
- (void)setYeaVote:(NSString *)yeaVoteStatus;
- (void)setNayVote:(NSString *)nayVoteStatus;

@end
