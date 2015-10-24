//
//  Notes.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 12/18/13.
//  Copyright (c) 2013 Architactile LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notes : NSObject

@property (nonatomic, strong) NSDictionary *person;


-(NSString *) readNotes;
-(void) writeNotes:(NSString *) notes;

@end
