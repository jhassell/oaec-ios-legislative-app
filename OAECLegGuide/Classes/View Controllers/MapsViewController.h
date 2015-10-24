//
//  MapsViewController.h
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/21/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapsViewController : UIViewController <MKMapViewDelegate>

-(IBAction) reframeButtonPressed;

@property (nonatomic, assign) NSDictionary *person;


@end
