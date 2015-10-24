//
//  NSString+Stuff.h
//  TMG Inspector
//
//  Created by Matt Galloway on 8/15/11.
//  Copyright 2011 Architactile LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NSString_Stuff)

- (NSString *) trim;
- (BOOL) isOnlyNumbers;
- (unsigned long long) fileSize;
+ (BOOL) isBlankOrNil:(NSString *) string;
@end
