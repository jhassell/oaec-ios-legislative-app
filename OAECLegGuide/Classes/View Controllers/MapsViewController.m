//
//  MapsViewController.m
//  OAECLegGuide
//
//  Created by Matt Galloway on 7/21/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "MapsViewController.h"
#import <CoreFoundation/CoreFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Boundary.h"
#import "BoundaryPolygon.h"
#import "UIColor-Expanded.h"
#import "AppDelegate.h"
#import "NSDictionary+People.h"
#import "NSString+Stuff.h"
#import "PersonViewController.h"
#import "ModalAlert.h"

#import "GetLocationViewController.h"
#import "LocationDetailViewController.h"
#import "SetupViewController.h"
#import "CLLocation+Strings.h"

#define METERS_PER_MILE 1609.344

@interface MapsViewController () <CLLocationManagerDelegate> {
    BOOL firstLoad;
    BOOL isMapPage;
}

@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) IBOutlet UILabel *personNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *personTitleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *personImageView;
@property (retain, nonatomic) IBOutlet UIView *nameBackgroundView;
@property (retain, nonatomic) IBOutlet UIButton *leftArrowButton;
@property (retain, nonatomic) IBOutlet UIButton *rightArrowButton;
@property (retain, nonatomic) IBOutlet UILabel *mapTitleLabel;
@property (retain, nonatomic) IBOutlet UIView *mapTitleBackgroundView;

@property (retain, nonatomic) NSMutableArray *countyBoundaries;
@property (retain, nonatomic) NSMutableArray *districtBoundaries;
@property (retain, nonatomic) Boundary       *districtBoundary;
@property (assign) NSInteger mapSelectIndex;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSMutableArray *locationMeasurements;
@property (nonatomic, strong) CLLocation *bestEffortAtLocation;

@property (nonatomic, assign) IBOutlet UIButton *startButton;
@property (nonatomic, assign) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, assign) IBOutlet UITableView *tableView;
@property (nonatomic, strong) SetupViewController* setupViewController;
@property (nonatomic, copy) NSString *stateString;

@property (retain, nonatomic) UIAlertController *instructionView;

- (IBAction)rightArrowButtonPressed:(id)sender;
- (IBAction)leftArrowButtonPressed:(id)sender;
- (void) displayCurrentMapOverlays;
- (void) getPinFor:(CLLocation *)location;
- (void)layoutTopMapChrome;
- (void)layoutBottomInfoChrome;
- (IBAction)personInfoButtonPressed:(id)sender;

@end

@implementation MapsViewController

@synthesize mapView=_mapView;
@synthesize personNameLabel = _personNameLabel;
@synthesize personTitleLabel = _personTitleLabel;
@synthesize personImageView = _personImageView;
@synthesize nameBackgroundView = _nameBackgroundView;
@synthesize leftArrowButton = _leftArrowButton;
@synthesize rightArrowButton = _rightArrowButton;
@synthesize mapTitleLabel = _mapTitleLabel;
@synthesize mapTitleBackgroundView = _mapTitleBackgroundView;
@synthesize countyBoundaries=_countyBoundaries;
@synthesize districtBoundary=_districtBoundary;
@synthesize districtBoundaries=_districtBoundaries;
@synthesize mapSelectIndex=_mapSelectIndex;
@synthesize instructionView=_instructionView;
@synthesize person=_person;


#pragma mark - Gesture Recognizer Handler

-(IBAction) weblink {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] weblink];
}


- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    CLLocation *touchMapLocation = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
    
    [self performSelector:@selector(getPinFor:) withObject:touchMapLocation afterDelay:0.1];
    
}

#pragma mark - Map Kit Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
    
    if (!pinView)
    {
        // if an existing pin view was not available, create one
        MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
                                               initWithAnnotation:annotation reuseIdentifier:@"pin"] autorelease];
        customPinView.pinTintColor = [UIColor greenColor];
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = NO;        
        return customPinView;
    } else {
        pinView.annotation = annotation;
    }
    
    return pinView;
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    BoundaryPolygon *boundaryPolygon = (BoundaryPolygon *) overlay;
    
//    MKPolygonView *view = [[MKPolygonView alloc] initWithPolygon:boundaryPolygon.polygon];
    MKPolygonRenderer *view = [[MKPolygonRenderer alloc] initWithPolygon:boundaryPolygon.polygon];
    view.lineWidth=1;
    view.fillColor=[boundaryPolygon.boundary.color colorWithAlphaComponent:0.3];
    view.strokeColor=[boundaryPolygon.boundary.color colorWithAlphaComponent:1.0];
    return view;
}

#pragma mark - IB Hooks

- (IBAction)rightArrowButtonPressed:(id)sender {
    self.mapSelectIndex++;
    [self displayCurrentMapOverlays];
}

- (IBAction)leftArrowButtonPressed:(id)sender {
    self.mapSelectIndex--;
    [self displayCurrentMapOverlays];
}


- (IBAction)backButtonPushed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) reframeButtonPressed {
    CLLocationCoordinate2D zoomLocation;
    
    if (self.bestEffortAtLocation != nil) {
        zoomLocation = self.bestEffortAtLocation.coordinate;
    } else {
        zoomLocation.latitude = 35.404143;
        zoomLocation.longitude = -98.727400;
    }
        
    MKCoordinateRegion viewRegion = MKCoordinateRegionMake(zoomLocation, MKCoordinateSpanMake(8.498936, 9.247016));
    [self.mapView setRegion:viewRegion animated:YES];
    if (self.bestEffortAtLocation != nil) {
        [self getPinFor:self.bestEffortAtLocation];
    }

}



- (IBAction)personInfoButtonPressed:(id)sender {
    
    if (self.person==nil) return;
    
    if (isMapPage) {
        PersonViewController *pvc = [[[PersonViewController alloc] initWithNibName:@"PersonView-iPhone" bundle:nil] autorelease];
        pvc.person=self.person;
        [self.navigationController pushViewController:pvc animated:YES];
    } else {
        [self backButtonPushed:sender];
    }
}

#pragma mark - Map Manipulation



-(void) getPinFor:(CLLocation *)location {
    
    self.person=nil;
    self.countyBoundaries=nil;
    self.districtBoundaries=nil;
    self.districtBoundary=nil;
    
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation.title=@"Here.";
    pointAnnotation.coordinate=coordinate;
    [self.mapView addAnnotation:pointAnnotation];
    
    self.countyBoundaries=nil;
    self.districtBoundary=nil;
    
    if (self.districtBoundaries==nil) {
        self.districtBoundaries=[NSMutableArray arrayWithCapacity:5];   
    } else {
        [self.districtBoundaries removeAllObjects];
    }
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    for(Boundary *boundary in [ad.stateHouseBoundaries allValues]) {
        if ([boundary pointInside:coordinate]) {
            boundary.color=[UIColor grayColor];
            [self.districtBoundaries addObject:boundary];
        }
    }

    for(Boundary *boundary in [ad.stateSenateBoundaries allValues]) {
        if ([boundary pointInside:coordinate]) {
            boundary.color=[UIColor grayColor];
            [self.districtBoundaries addObject:boundary];
        }
    }
    
    for(Boundary *boundary in [ad.congressionalBoundaries allValues]) {
        if ([boundary pointInside:coordinate]) {
            boundary.color=[UIColor grayColor];
            [self.districtBoundaries addObject:boundary];
        }
    }

    for(Boundary *boundary in [ad.coopBoundaries allValues]) {
        if ([boundary pointInside:coordinate]) {
            boundary.color=[UIColor grayColor];
            [self.districtBoundaries addObject:boundary];
        }
    }
    
    [self displayCurrentMapOverlays];
    
}

-(void) displayCurrentMapOverlays {
    
    if (self.districtBoundary!=nil) {
        
        //This should one district and it's counties for an individual.
        
        [self.mapView removeOverlays:self.mapView.overlays];

        if (self.mapSelectIndex<0) self.mapSelectIndex=[self.countyBoundaries count];
        if (self.mapSelectIndex>[self.countyBoundaries count]) self.mapSelectIndex=0;
        
        Boundary *boundaryToFrame = self.districtBoundary;
        self.mapTitleLabel.text=[NSString stringWithFormat:@"District %i",[self.districtBoundary.name intValue]];
        
        int index=0;
        for(Boundary *countyBoundary in self.countyBoundaries) {
            if (index==self.mapSelectIndex) {
                countyBoundary.color = [UIColor greenColor];
                boundaryToFrame=countyBoundary;
                self.mapTitleLabel.text=[NSString stringWithFormat:@"%@ County",[countyBoundary.name capitalizedString]];
            } else {
                countyBoundary.color = [UIColor grayColor];            
            }
            [self.mapView addOverlays:countyBoundary.polygons];   
            index++;
        }
        
        [self.mapView addOverlays:self.districtBoundary.polygons];
        
        MKMapRect allRect=MKMapRectNull;
        for (MKPolygon *polygon in boundaryToFrame.polygons) {
            allRect = MKMapRectUnion(allRect, [polygon boundingMapRect]);
        }
        
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionForMapRect(allRect)];   
        
        [self.mapView setRegion:adjustedRegion animated:YES];    
        
    } else if (self.districtBoundaries!=nil && [self.districtBoundaries count]>0) {
        
        // This shows all of the boundaries for a given point
        
        [self.mapView removeOverlays:self.mapView.overlays];

        if (self.mapSelectIndex<0) self.mapSelectIndex=[self.districtBoundaries count]-1;

        if (self.mapSelectIndex>=[self.districtBoundaries count]) self.mapSelectIndex=0;

        Boundary *boundaryToFrame = [self.districtBoundaries objectAtIndex:self.mapSelectIndex];
        
        AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSString *districtNumber = nil;
        NSArray *peopleList=nil;
        NSString *title=nil;
        
        if ([boundaryToFrame.type isEqualToString:BOUNDARY_TYPE_STATE_HOUSE ]) {
            districtNumber = [NSString stringWithFormat:@"%i",[boundaryToFrame.name intValue]];
            peopleList=ad.stateHouse;
            title = [NSString stringWithFormat:@"OK House Dist. %@",districtNumber];
        } else if ([boundaryToFrame.type isEqualToString:BOUNDARY_TYPE_STATE_SENATE]) {
            districtNumber = [NSString stringWithFormat:@"%i",[boundaryToFrame.name intValue]];
            peopleList=ad.stateSenate;
            title = [NSString stringWithFormat:@"OK Senate Dist. %@",districtNumber];
        } else if ([boundaryToFrame.type isEqualToString:BOUNDARY_TYPE_FEDERAL_HOUSE ]) {
            districtNumber = [NSString stringWithFormat:@"%i",[boundaryToFrame.name intValue]];
            peopleList=ad.federalHouse;
            title = [NSString stringWithFormat:@"US House Dist. %@",districtNumber];
        } else if ([boundaryToFrame.type isEqualToString:BOUNDARY_TYPE_COOP ]) {
            peopleList=ad.oaecMembers;
            title = boundaryToFrame.name;
        } else {
            NSLog(@"[OAEC][Map] Unknown boundary type '%@' for boundary '%@'", boundaryToFrame.type, boundaryToFrame.name);
        }
        
        
        if (title!=nil) {
            self.mapTitleLabel.text = title;
        } else {
            self.mapTitleLabel.text = @"";
        }
        
        NSArray *peopleArray;
        
        if ([boundaryToFrame.type isEqualToString:BOUNDARY_TYPE_COOP ]) {
            peopleArray = [peopleList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"CoopRegionName=%@",boundaryToFrame.name]];
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"Sort Order" ascending:YES];
            peopleArray = [peopleArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        } else {
            peopleArray = [peopleList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"DistrictNumber=%@",districtNumber]];
        }
        
        
        
        if ([peopleArray count]>0) {
            self.person=[peopleArray objectAtIndex:0];
            [self updatePersonInfo];
        }
        
        int index=0;
        for(Boundary *boundary in self.districtBoundaries) {
            if (index!=self.mapSelectIndex) {
                boundary.color = [UIColor grayColor];
                [self.mapView addOverlays:boundary.polygons];
            }
            index++;
        }

        if ([self.person.party isEqualToString:@"R"]) {
           boundaryToFrame.color=[UIColor redColor];   
        } else if ([self.person.party isEqualToString:@"D"]) {
            boundaryToFrame.color=[UIColor blueColor];   
        } else {
            boundaryToFrame.color=[UIColor greenColor];
        }
        
        [self.mapView addOverlays:boundaryToFrame.polygons];

        MKMapRect allRect=MKMapRectNull;
        for (MKPolygon *polygon in boundaryToFrame.polygons) {
            allRect = MKMapRectUnion(allRect, [polygon boundingMapRect]);
        }

        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionForMapRect(allRect)];   

        [self.mapView setRegion:adjustedRegion animated:YES];    
        

        
    } else {
        if (self.personImageView!=nil) self.personImageView.hidden=YES;
        if (self.personNameLabel!=nil) self.personNameLabel.hidden=YES;
        if (self.personTitleLabel!=nil) self.personTitleLabel.hidden=YES;
        if (self.nameBackgroundView!=nil) self.nameBackgroundView.hidden=YES;
        if (self.mapTitleBackgroundView!=nil) self.mapTitleBackgroundView.hidden=YES;
    }
}

-(void) addBoundary:(Boundary *)boundary {
    [self.mapView addOverlays:boundary.polygons];
    MKMapRect allRect=MKMapRectNull;
    for (MKPolygon *polygon in boundary.polygons) {
        allRect = MKMapRectUnion(allRect, [polygon boundingMapRect]);
    }
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:MKCoordinateRegionForMapRect(allRect)];   
    [self.mapView setRegion:adjustedRegion animated:YES];
}

-(void) displayDistrictForPerson {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (self.person!=nil) {
        NSString *districtNumber = nil;
        NSDictionary *districtBoundaries=nil;
        
        if ([self.person.type isEqualToString:STATE_HOUSE]) {
//            districtNumber = [NSString stringWithFormat:@"%03i",[self.person.districtNumber intValue]];
            districtNumber = [NSString stringWithFormat:@"%i",[self.person.districtNumber intValue]];
            districtBoundaries=ad.stateHouseBoundaries;
        } else if ([self.person.type isEqualToString:STATE_SENATE]) {
//            districtNumber = [NSString stringWithFormat:@"%03i",[self.person.districtNumber intValue]];
            districtNumber = [NSString stringWithFormat:@"%i",[self.person.districtNumber intValue]];
            districtBoundaries=ad.stateSenateBoundaries;
        } else if ([self.person.type isEqualToString:STATEWIDE]) {
        } else if ([self.person.type isEqualToString:FEDERAL_HOUSE]) {
//            districtNumber = [NSString stringWithFormat:@"%02i",[self.person.districtNumber intValue]];
            districtNumber = [NSString stringWithFormat:@"%i",[self.person.districtNumber intValue]];
            districtBoundaries=ad.congressionalBoundaries;
        } else if ([self.person.type isEqualToString:FEDERAL_SENATE]) {
        }   
        
        if (districtBoundaries!=nil) {
            
            //Counties Covered
            
            self.districtBoundaries=nil;
            
            if (self.countyBoundaries==nil) {
                self.countyBoundaries=[NSMutableArray arrayWithCapacity:5];   
            } else {
                [self.countyBoundaries removeAllObjects];
            }
            
            NSArray *counties = [self.person.countiesCovered componentsSeparatedByString:@"~"];
            for (NSString *county in counties) {
                Boundary *countyBoundary = [ad.countyBoundaries objectForKey:[[county uppercaseString] trim]];
                if (countyBoundary!=nil) {
                    [self.countyBoundaries addObject:countyBoundary];
                } else {
                }
            }
            
            // NEED TO SORT COUNTIES BY NAME
            
            NSSortDescriptor *sortByName = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
            [self.countyBoundaries sortUsingDescriptors:sortDescriptors];
            
            self.mapSelectIndex = [self.countyBoundaries count];
            self.districtBoundary = [districtBoundaries objectForKey:districtNumber];
            self.districtBoundary.color=self.nameBackgroundView.backgroundColor;
            
            [self displayCurrentMapOverlays];
            
        } else {
            
            [self reframeButtonPressed];
            
        }
        
        
    } 

}

-(void) updatePersonInfo {
    
    if (self.person!=nil) {
        
        NSString *prefix=@"";
        NSString *office=@"";
        NSString *title=@"";
        NSString *partyAndDistrict=@"";
        NSString *personTitle=@"";
        NSString *districtNumber = nil;
        
        if ([self.person.type isEqualToString:STATE_HOUSE]) {
            prefix = @"Rep. ";
            office=@"Oklahoma Representative";
            title=self.person.titleLeadership;            
            partyAndDistrict = [NSString stringWithFormat:@"State House District %@",self.person.districtNumber ];            
            personTitle=partyAndDistrict;
            districtNumber = [NSString stringWithFormat:@"%03i",[self.person.districtNumber intValue]];
        } else if ([self.person.type isEqualToString:STATE_SENATE]) {
            prefix = @"Sen. ";
            office=@"Oklahoma Senator";
            title=self.person.titleLeadership;
            partyAndDistrict = [NSString stringWithFormat:@"State Senate District %@",self.person.districtNumber ];
            personTitle=partyAndDistrict;
            districtNumber = [NSString stringWithFormat:@"%03i",[self.person.districtNumber intValue]];
        } else if ([self.person.type isEqualToString:STATEWIDE]) {
            office=self.person.titleLeadership;
            partyAndDistrict = self.person.party;
            personTitle=[NSString stringWithFormat:@"%@ (%@)",office,self.person.party];
        } else if ([self.person.type isEqualToString:FEDERAL_HOUSE]) {
            prefix = @"Rep. ";
            office = @"US Representative";
            title = self.person.titleLeadership;
            partyAndDistrict = [NSString stringWithFormat:@"US House District %@",self.person.districtNumber ];
            personTitle=partyAndDistrict;
            districtNumber = [NSString stringWithFormat:@"%02i",[self.person.districtNumber intValue]];
        } else if ([self.person.type isEqualToString:FEDERAL_SENATE]) {
            prefix = @"Sen. ";
            office = @"US Senator";
            title = self.person.titleLeadership;
            partyAndDistrict = self.person.party;
            personTitle=partyAndDistrict;
        } else if ([self.person.type isEqualToString:OAEC_MEMBER]) {
            personTitle = self.person.titleLeadership;
        }
        
        if ([@"VACANT" caseInsensitiveCompare:[self.person.firstName trim]]==NSOrderedSame) {
            self.personNameLabel.text = @"Seat Vacant";
        } else {
            self.personNameLabel.text = [NSString stringWithFormat:@"%@%@ %@%@",prefix,self.person.firstName,self.person.lastName,
                                         ((self.person.party==nil || [[self.person.party trim] length]==0)?@"":[NSString stringWithFormat:@" (%@)",self.person.party ])];
        }
        
        self.personTitleLabel.text = personTitle;
        
        if ([self.person.party isEqualToString:@"R"]) {
            self.nameBackgroundView.backgroundColor=[UIColor redColor];   
        } else if ([self.person.party isEqualToString:@"D"]) {
            self.nameBackgroundView.backgroundColor=[UIColor blueColor];   
        } else {
            self.nameBackgroundView.backgroundColor=[UIColor greenColor];
        }
        
        BOOL hasPhoto=NO;
        
        if (self.person.photo!=nil && [self.person.photo length]>0) {
            self.personImageView.image=[UIImage imageNamed:self.person.photo];
            if (self.personImageView.image!=nil) hasPhoto=YES;
        }
        
              
        if (hasPhoto) {
            self.personImageView.hidden=NO;
            self.personNameLabel.frame = CGRectMake(5.0f, self.personNameLabel.frame.origin.y, self.personNameLabel.frame.size.width , self.personNameLabel.frame.size.height);
            self.personTitleLabel.frame = CGRectMake(5.0f, self.personTitleLabel.frame.origin.y, self.personTitleLabel.frame.size.width , self.personTitleLabel.frame.size.height);
        } else {
            self.personImageView.hidden=YES;
            self.personNameLabel.frame = CGRectMake(64.0f, self.personNameLabel.frame.origin.y, self.personNameLabel.frame.size.width , self.personNameLabel.frame.size.height);
            self.personTitleLabel.frame = CGRectMake(64.0f, self.personTitleLabel.frame.origin.y, self.personTitleLabel.frame.size.width , self.personTitleLabel.frame.size.height);
        }
        
        if (self.personNameLabel!=nil) self.personNameLabel.hidden=NO;
        if (self.personTitleLabel!=nil) self.personTitleLabel.hidden=NO;
        if (self.nameBackgroundView!=nil) self.nameBackgroundView.hidden=NO;
        if (self.mapTitleBackgroundView!=nil) self.mapTitleBackgroundView.hidden=NO;

    } else {
        
        if (self.personImageView!=nil) self.personImageView.hidden=YES;
        if (self.personNameLabel!=nil) self.personNameLabel.hidden=YES;
        if (self.personTitleLabel!=nil) self.personTitleLabel.hidden=YES;
        if (self.nameBackgroundView!=nil) self.nameBackgroundView.hidden=YES;
        if (self.mapTitleBackgroundView!=nil) self.mapTitleBackgroundView.hidden=YES;
        
    }
}

#pragma mark - Lifecycle Stuff

-(void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (firstLoad) {
        
        firstLoad=NO;
        isMapPage=(self.person==nil);
        
        if (isMapPage) {
            
            if (self.personImageView!=nil) self.personImageView.hidden=YES;
            if (self.personNameLabel!=nil) self.personNameLabel.hidden=YES;
            if (self.personTitleLabel!=nil) self.personTitleLabel.hidden=YES;
            if (self.nameBackgroundView!=nil) self.nameBackgroundView.hidden=YES;
            if (self.mapTitleBackgroundView!=nil) self.mapTitleBackgroundView.hidden=YES;

            UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] 
                                           initWithTarget:self action:@selector(handleGesture:)];
            tgr.numberOfTapsRequired = 1;
            tgr.numberOfTouchesRequired = 1;
            [self.mapView addGestureRecognizer:tgr];
            [tgr release];
            

            if (self.bestEffortAtLocation == nil) {
                // Create the core location manager object
                _locationManager = [[CLLocationManager alloc] init];
                self.locationManager.delegate = self;
                
                // This is the most important property to set for the manager. It ultimately determines how the manager will
                // attempt to acquire location and thus, the amount of power that will be consumed.
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
                
                // Once configured, the location manager must be "started"
                //
                // for iOS 8, specific user level permission is required,
                // "when-in-use" authorization grants access to the user's location
                //
                // important: be sure to include NSLocationWhenInUseUsageDescription along with its
                // explanation string in your Info.plist or startUpdatingLocation will not work.
                //
                if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [self.locationManager requestWhenInUseAuthorization];
                }
                [self.locationManager startUpdatingLocation];
                
                [self performSelector:@selector(stopUpdatingLocationWithMessage:)
                           withObject:@"Timed Out"
                           afterDelay:30];
                
                self.stateString = NSLocalizedString(@"Updating", @"Updating");
            }
            
            [self reframeButtonPressed];
            
        } else {
            
            [self updatePersonInfo];
            [self displayDistrictForPerson];
        }
        
    }
    
    [super viewWillAppear:animated];

}

- (void)stopUpdatingLocationWithMessage:(NSString *)state {
    self.stateString = state;
    [self.tableView reloadData];
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    
    //UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reset", @"Reset")
    //                                                              style:UIBarButtonItemStylePlain
                                                                 //target:self
                                                                 //action:@selector(reset)];
    //[self.navigationItem setLeftBarButtonItem:resetItem animated:YES];
}

// We want to get and store a location measurement that meets the desired accuracy.
// For this example, we are going to use horizontal accuracy as the deciding factor.
// In other cases, you may wish to use vertical accuracy, or both together.
//
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *newLocation = [locations lastObject];
    if (!newLocation) {
        return;
    }

    // store all of the measurements, just so we can see what kind of data we might receive
    [self.locationMeasurements addObject:newLocation];
    
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    //
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) {
        return;
    }
    
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    // test the measurement to see if it is more accurate than the previous measurement
    if (self.bestEffortAtLocation == nil || self.bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        _bestEffortAtLocation = newLocation;
        
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
            // we have a measurement that meets our requirements, so we can stop updating the location
            //
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            //
            [self stopUpdatingLocationWithMessage:NSLocalizedString(@"Acquired Location", @"Acquired Location")];
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocationWithMessage:) object:nil];
        }
    }
    
    [self stopUpdatingLocationWithMessage:NSLocalizedString(@"Acquired Location", @"Acquired Location")];
    [self reframeButtonPressed];
    // update the display with the new location data
    //[self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a
    // timeout that will stop the location manager to save power.
    //
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocationWithMessage:NSLocalizedString(@"Error", @"Error")];
    }
}


-(void) viewDidAppear:(BOOL)animated {
    
    if (isMapPage) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Map Instructions" message:@"Tap anywhere in Oklahoma to see the legislative districts, or enter an address" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Go to Map" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSString *input = alert.textFields[0].text;
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:input completionHandler:^(NSArray *placemarks, NSError *error) {
                if (error) {
                    NSLog(@"[OAEC][Map] Address geocode failed: %@", error.localizedDescription);
                } else {
                    CLPlacemark *placemark = [placemarks lastObject];
                    if ([placemark.administrativeArea isEqualToString:@"OK"]) {
                        CLLocation *touchMapLocation = [[CLLocation alloc] initWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
                        [self performSelector:@selector(getPinFor:) withObject:touchMapLocation afterDelay:0.1];
                    }
                }
            }];
        }]];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Enter Oklahoma Address:";
        }];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutTopMapChrome];
    [self layoutBottomInfoChrome];
}

- (void)layoutTopMapChrome {
    CGFloat safeTop = 0.0f;
    if (@available(iOS 11.0, *)) {
        safeTop = self.view.safeAreaInsets.top;
    }

    UIView *topBar = self.mapTitleBackgroundView;
    if (topBar == nil) return;

    CGRect bounds = self.view.bounds;
    CGFloat horizontalPadding = 8.0f;
    CGFloat topPadding = 6.0f;
    CGFloat topBarY = safeTop + topPadding;
    CGFloat topBarHeight = MAX(36.0f, CGRectGetHeight(topBar.frame));
    topBar.frame = CGRectMake(0.0f, topBarY, CGRectGetWidth(bounds), topBarHeight);

    UIButton *leftButton = self.leftArrowButton;
    UIButton *rightButton = self.rightArrowButton;
    UILabel *titleLabel = self.mapTitleLabel;
    if (leftButton == nil || rightButton == nil || titleLabel == nil) return;

    CGSize leftSize = leftButton.frame.size;
    CGSize rightSize = rightButton.frame.size;
    CGFloat centerY = floor((topBarHeight - leftSize.height) / 2.0f);
    leftButton.frame = CGRectMake(horizontalPadding, centerY, leftSize.width, leftSize.height);
    rightButton.frame = CGRectMake(CGRectGetWidth(topBar.frame) - horizontalPadding - rightSize.width,
                                   floor((topBarHeight - rightSize.height) / 2.0f),
                                   rightSize.width,
                                   rightSize.height);

    CGFloat titleX = CGRectGetMaxX(leftButton.frame) + 6.0f;
    CGFloat titleRight = CGRectGetMinX(rightButton.frame) - 6.0f;
    CGFloat titleWidth = MAX(60.0f, titleRight - titleX);
    titleLabel.frame = CGRectMake(titleX, 0.0f, titleWidth, topBarHeight);
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.7f;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (void)layoutBottomInfoChrome {
    UIView *bottomBar = self.nameBackgroundView;
    if (bottomBar == nil) return;

    CGFloat safeBottom = 0.0f;
    if (@available(iOS 11.0, *)) {
        safeBottom = self.view.safeAreaInsets.bottom;
    }

    CGFloat tabBarOverlap = 0.0f;
    if (self.tabBarController != nil && self.tabBarController.tabBar != nil && !self.tabBarController.tabBar.hidden) {
        CGRect viewInWindow = [self.view convertRect:self.view.bounds toView:nil];
        CGRect tabBarInWindow = [self.tabBarController.tabBar convertRect:self.tabBarController.tabBar.bounds toView:nil];
        CGRect overlap = CGRectIntersection(viewInWindow, tabBarInWindow);
        if (!CGRectIsNull(overlap)) {
            tabBarOverlap = CGRectGetHeight(overlap);
        }
    }

    CGFloat bottomInset = MAX(safeBottom, tabBarOverlap);
    CGRect bounds = self.view.bounds;
    CGFloat barHeight = CGRectGetHeight(bottomBar.frame);
    CGFloat bottomBarY = CGRectGetHeight(bounds) - bottomInset - barHeight;

    CGFloat titleOffset = 0.0f;
    if (self.personNameLabel != nil && self.personTitleLabel != nil) {
        titleOffset = self.personTitleLabel.frame.origin.y - self.personNameLabel.frame.origin.y;
    }
    CGFloat imageOffset = 0.0f;
    if (self.personImageView != nil) {
        imageOffset = self.personImageView.frame.origin.y - bottomBar.frame.origin.y;
    }

    bottomBar.frame = CGRectMake(0.0f, bottomBarY, CGRectGetWidth(bounds), barHeight);

    if (self.personNameLabel != nil) {
        self.personNameLabel.frame = CGRectMake(self.personNameLabel.frame.origin.x,
                                                bottomBarY,
                                                self.personNameLabel.frame.size.width,
                                                self.personNameLabel.frame.size.height);
    }
    if (self.personTitleLabel != nil) {
        self.personTitleLabel.frame = CGRectMake(self.personTitleLabel.frame.origin.x,
                                                 bottomBarY + titleOffset,
                                                 self.personTitleLabel.frame.size.width,
                                                 self.personTitleLabel.frame.size.height);
    }
    if (self.personImageView != nil) {
        self.personImageView.frame = CGRectMake(self.personImageView.frame.origin.x,
                                                bottomBarY + imageOffset,
                                                self.personImageView.frame.size.width,
                                                self.personImageView.frame.size.height);
    }

    for (UIView *subview in self.view.subviews) {
        if (![subview isKindOfClass:[UIButton class]]) continue;
        if (subview == self.leftArrowButton || subview == self.rightArrowButton) continue;
        if (fabs(CGRectGetWidth(subview.frame) - CGRectGetWidth(bounds)) > 1.0f) continue;
        if (fabs(CGRectGetHeight(subview.frame) - barHeight) > 1.0f) continue;

        subview.frame = CGRectMake(0.0f, bottomBarY, CGRectGetWidth(bounds), barHeight);
        break;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    firstLoad=YES;
	// Do any additional setup after loading the view.
    UIButton *backBtn = self.leftArrowButton;
    if ([backBtn isKindOfClass:[UIButton class]]) {
        UIImage *leftArrowImage = [UIImage imageNamed:@"Arrow_Left.png"];
        [backBtn setAttributedTitle:nil forState:UIControlStateNormal];
        [backBtn setAttributedTitle:nil forState:UIControlStateHighlighted];
        [backBtn setTitle:nil forState:UIControlStateNormal];
        [backBtn setTitle:nil forState:UIControlStateHighlighted];
        [backBtn setBackgroundImage:nil forState:UIControlStateNormal];
        if (leftArrowImage != nil) {
            [backBtn setImage:leftArrowImage forState:UIControlStateNormal];
            [backBtn setImage:leftArrowImage forState:UIControlStateHighlighted];
        }
    }
    [self layoutTopMapChrome];
}

- (void)dealloc {
    [_mapView release];
    [_personNameLabel release];
    [_personTitleLabel release];
    [_personImageView release];
    [_nameBackgroundView release];
    [_leftArrowButton release];
    [_rightArrowButton release];
    [_mapTitleLabel release];
    [_mapTitleBackgroundView release];
    [_districtBoundary release];
    [_districtBoundaries release];
    [_countyBoundaries release];
    [_instructionView release];
    [super dealloc];
}

@end
