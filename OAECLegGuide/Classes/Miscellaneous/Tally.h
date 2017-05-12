//
//  Tally.h
//  voteTest
//
//  Created by User on 5/9/17.
//  Copyright © 2017 ZigBeef. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Tally : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *votes;
@property (nonatomic, strong) NSMutableArray *yeaButtonRef;
@property (nonatomic, strong) NSMutableArray *nayButtonRef;


-(instancetype)initWithParams:(NSInteger)voteCount;


@end
