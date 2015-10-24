//
//  PeopleListViewController.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/29/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Committee;

@interface PeopleListViewController : UIViewController <UISearchBarDelegate>

@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) Committee *committee;

@end
