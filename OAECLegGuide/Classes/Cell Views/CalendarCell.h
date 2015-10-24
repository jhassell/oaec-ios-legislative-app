//
//  CalendarCell.h
//  LegGuide
//
//  Created by Matt Galloway on 11/25/13.
//  Copyright (c) 2013 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UITextView *detailsTextView;
@property (retain, nonatomic) IBOutlet UILabel *detailsLabel;

@end
