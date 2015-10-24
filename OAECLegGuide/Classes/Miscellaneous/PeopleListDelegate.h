//
//  PeopleListDelegate.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/26/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SEARCH_VIEW_HEIGHT 88.0f

@class Committee;

@interface PeopleListDelegate : NSObject <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, assign) UIViewController<UISearchBarDelegate> *viewController;
@property (nonatomic, assign) UITableView *peopleTable;
@property (nonatomic, assign) Committee *committee;


@end
