//
//  NSString+Stuff.m
//  TMG Inspector
//
//  Created by Matt Galloway on 8/15/11.
//  Copyright 2011 Architactile LLC. All rights reserved.
//

#import "NSString+Stuff.h"


@implementation NSString (NSString_Stuff)

-(NSString *) trim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL) isOnlyNumbers {    
    if ([self length]==0) return NO;
    NSString *regexNonNumerics = @"[^0-9]";
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexNonNumerics
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];

    unsigned long numberOfMatched = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];

    return numberOfMatched==0;
}

-(unsigned long long) fileSize {
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    NSDictionary *fileInfo = [fm attributesOfItemAtPath:self error:nil];
    
    long long size = fileInfo.fileSize;

    [fm release];
    return size;
}

+ (BOOL) isBlankOrNil:(NSString *) string {
    return (string==nil || [[string trim] length]==0);
}

@end


