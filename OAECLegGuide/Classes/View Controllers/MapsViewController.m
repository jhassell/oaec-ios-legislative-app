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

#define METERS_PER_MILE 1609.344

@interface MapsViewController () {
    BOOL firstLoad;
    BOOL isMapPage;
    BOOL didDismissInstruction;
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

@property (retain, nonatomic) UIAlertView *instructionView;

- (IBAction)rightArrowButtonPressed:(id)sender;
- (IBAction)leftArrowButtonPressed:(id)sender;
- (void) displayCurrentMapOverlays;
- (void) getPinFor:(CLLocation *)location;
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
    //NSLog(@"Gesture Recognized!");
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
        customPinView.pinColor = MKPinAnnotationColorGreen;            
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = NO;        
        return customPinView;
    } else {
        pinView.annotation = annotation;
    }
    
    return pinView;
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    BoundaryPolygon *boundaryPolygon = (BoundaryPolygon *) overlay;
    
    MKPolygonView *view = [[MKPolygonView alloc] initWithPolygon:boundaryPolygon.polygon];
    view.lineWidth=1;
    view.fillColor=[boundaryPolygon.boundary.color colorWithAlphaComponent:0.3];
    view.strokeColor=[boundaryPolygon.boundary.color colorWithAlphaComponent:1.0];
    return [view autorelease];
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
    zoomLocation.latitude = 35.404143;
    zoomLocation.longitude = -98.727400;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMake(zoomLocation, MKCoordinateSpanMake(8.498936, 9.247016));
    [self.mapView setRegion:viewRegion animated:YES]; 
}



- (IBAction)personInfoButtonPressed:(id)sender {
    //NSLog(@"Button pressed");
    
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
    //NSLog(@"Overlays removed");
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    //NSLog(@"Annotation removed");
    
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
    
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];

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
        
        AppDelegate *ad = [[UIApplication sharedApplication] delegate];
        
        NSString *districtNumber = nil;
        NSArray *peopleList=nil;
        NSString *title=nil;
        
        //NSLog(@"boundary type: *%@*  name: %@",boundaryToFrame.type,boundaryToFrame.name);
        //NSLog(@"*%@* *%@* *%@*",STATE_SENATE,STATE_HOUSE,FEDERAL_HOUSE);
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
            NSLog(@"?????");
        }
        
        //NSLog(@"districtNumber %@\ntitle %@",districtNumber,title);
        
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
        
        
        //NSLog(@"peopleArray has %i objects",[peopleArray count]);
        
        if ([peopleArray count]>0) {
            self.person=[peopleArray objectAtIndex:0];
            //NSLog(@"self.person set to %@ %@",self.person.firstName,self.person.lastName);
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
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    
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
                    // NSLog(@"County NOT found: %@",[[county uppercaseString] trim]);
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
        
        //NSLog(@"---------->hasPhoto %@",(hasPhoto?@"YES":@"NO"));
              
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
            
            [self reframeButtonPressed];
            
        } else {
            
            [self updatePersonInfo];
            [self displayDistrictForPerson];
        }
        
    }
    
    [super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated {
    
    if (!didDismissInstruction && isMapPage) {
        
        [ModalAlert okWithTitle:@"Map Instructions" message:@"Tap anywhere in Oklahoma to see the legislative districts."];
        
        didDismissInstruction=YES;
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
    didDismissInstruction=NO;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
