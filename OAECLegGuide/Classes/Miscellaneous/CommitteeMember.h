//
//  CommitteeMember.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/30/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Committee.h"

@interface CommitteeMember : NSObject

@property (nonatomic, retain) NSDictionary *person;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *sortTitle;
@property (nonatomic, retain) Committee *committee;

@end
