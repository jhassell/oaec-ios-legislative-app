//
//  Notes.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 12/18/13.
//  Copyright (c) 2013 Architactile LLC. All rights reserved.
//

#import "Notes.h"
#import "NSDictionary+People.h"
#import "NSString+Stuff.h"
#import "EmailHelper.h"

@implementation Notes

-(NSString *) notesFilename {
    
    NSString *filename = [NSString stringWithFormat:@"%@_%@_%@_%@",self.person.type,self.person.firstName,self.person.lastName,self.person.districtNumber];
    filename = [filename stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    filename = [filename stringByReplacingOccurrencesOfString:@"." withString:@""];
    filename = [filename stringByReplacingOccurrencesOfString:@")" withString:@""];
    filename = [filename stringByReplacingOccurrencesOfString:@"(" withString:@""];
    filename = [filename stringByReplacingOccurrencesOfString:@"," withString:@""];
    filename = [filename lowercaseString];
    filename = [filename stringByAppendingPathExtension:@"txt"];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSString *notesPath = [basePath stringByAppendingPathComponent:@"Notes"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:notesPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    return [notesPath stringByAppendingPathComponent:filename];
}

-(NSString *) readNotes {
    if (self.person==nil) return nil;
    
    NSString *notes = [NSString stringWithContentsOfFile:[self notesFilename] encoding:NSUTF8StringEncoding error:nil];
    
    return notes;
}

-(void) writeNotes:(NSString *) notes {
    if (self.person==nil) return;
    
    [notes writeToFile:[self notesFilename] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
