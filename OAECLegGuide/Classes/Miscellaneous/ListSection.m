//
//  ListSection.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/26/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "ListSection.h"
#import "NSDictionary+People.h"

@implementation ListSection

@synthesize title=_title;
@synthesize children=_children;
@synthesize rowHeight=_rowHeight;
@synthesize firstRowHeight=_firstRowHeight;

+(NSArray *) buildSectionsFrom:(NSArray *) items dividedBy:(NSString *) key catchAllKey:(NSString *)catchAllKey includeKeys:(NSArray *)includeKeys {
    return [ListSection buildSectionsFrom:items dividedBy:key catchAllKey:catchAllKey includeKeys:includeKeys withTitlesOnly:NO];
}

+(NSArray *) buildSectionsFrom:(NSArray *) items dividedBy:(NSString *) key catchAllKey:(NSString *)catchAllKey includeKeys:(NSArray *)includeKeys withTitlesOnly:(BOOL)withTitlesOnly {
    
    NSMutableDictionary * sectionsDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    NSArray *filteredItems = items;

    if (includeKeys!=nil) {
        NSString *predFormat = [NSString stringWithFormat:@"%@ IN %%@",key];
        NSPredicate *filter = [NSPredicate predicateWithFormat:predFormat,includeKeys];
        filteredItems = [items filteredArrayUsingPredicate:filter];
    }
    
    
    for (NSDictionary *item in filteredItems) {
        
        BOOL skip = NO;
        if (withTitlesOnly) {
            if (item.titleLeadership==nil || [item.titleLeadership length]==0) skip=YES;
        }
        
        if (!skip) {
            
            NSString *keyValue = [item objectForKey:key];
            if (keyValue==nil) {
                if (catchAllKey==nil) {
                    keyValue=@"Other";
                } else {
                    keyValue=catchAllKey;
                }
            }
            
            ListSection *section = [sectionsDict objectForKey:keyValue];
            if (section==nil) {
                section = [[[ListSection alloc] init] autorelease];
                section.title = keyValue;
                section.children = [NSMutableArray arrayWithCapacity:1];
                [sectionsDict setValue:section forKey:keyValue];
            }
            
            [section.children addObject:item];
        }
    }

    NSArray *unsortedSections = [sectionsDict allValues];

    NSSortDescriptor *sortByTitle = [[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES] autorelease];

    NSArray *sortedSections = [unsortedSections sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByTitle]];
    
    return sortedSections;
}

- (void)dealloc
{
    [_title release];
    [_children release];
    [super dealloc];
}

@end
