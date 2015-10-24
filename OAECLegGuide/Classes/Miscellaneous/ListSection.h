//
//  ListSection.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/26/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListSection : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray  *children;
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) CGFloat firstRowHeight;

+(NSArray *) buildSectionsFrom:(NSArray *) items dividedBy:(NSString *) key catchAllKey:(NSString *)catchAllKey includeKeys:(NSArray *)includeKeys;
+(NSArray *) buildSectionsFrom:(NSArray *) items dividedBy:(NSString *) key catchAllKey:(NSString *)catchAllKey includeKeys:(NSArray *)includeKeys withTitlesOnly:(BOOL)withTitlesOnly;

@end
