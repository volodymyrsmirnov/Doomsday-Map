//
//  ViewController.m
//  Doomsday Area
//
//  Created by Vladimir Smirnov on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BombAnnotation.h"
#import "MKMapView+ZoomLevel.h"
#import "BombSelector.h"

@implementation ViewController

@synthesize LocationManager, Popover;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // init objects
    [Map setDelegate:self]; 
    //[Map setMapType:MKMapTypeHybrid];
    Bomb = [[BombAnnotation alloc] init];
    SelectedBomb = [NSDictionary alloc];
    NSUserDefaults *Settings = [NSUserDefaults standardUserDefaults];
    
    // get content of bombs description plist
    NSString *BombsPlist = [[NSBundle mainBundle] pathForResource:@"Bombs" ofType:@"plist"];
    Bombs = [[NSDictionary alloc] initWithContentsOfFile:BombsPlist];
    NSArray *BombsList = [[NSArray alloc] initWithArray:[Bombs objectForKey:@"Bombs"]];
    
    // if we have previously selected bomb
    if ([Settings integerForKey:@"SelectedBombIndex"]) SelectedBomb = [SelectedBomb initWithDictionary:[BombsList objectAtIndex:[Settings integerForKey:@"SelectedBombIndex"]]];
    // or get random bomb
    else SelectedBomb = [SelectedBomb initWithDictionary:[BombsList objectAtIndex:arc4random()%[BombsList count]]];
    
    Bomb.bTitle = [SelectedBomb objectForKey:@"title"];
    Bomb.bDescription = [SelectedBomb objectForKey:@"description"];
    
    // get user location on application start
    LocationManager = [[CLLocationManager alloc] init];
    [LocationManager setDelegate:self];
    [LocationManager startUpdatingLocation];
       
    // Bottom toolbar pattern fill, NB: 44px height
    UIView *PatternView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [BottomToolbar frame].size.width, [BottomToolbar frame].size.height)];
    [PatternView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [PatternView setAlpha:0.3];
    [PatternView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"iPadBottomPanelPattern.png"]]];
    [BottomToolbar insertSubview:PatternView atIndex:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popoverControllerDidDismissPopover:) name:@"popoverShouldDismiss" object:nil];
    
}

// new location received
- (void)locationManager:(CLLocationManager *)ActiveLocationManager didUpdateToLocation:(CLLocation *)NewLocation fromLocation:(CLLocation *)OldLocation
{ 
    [ActiveLocationManager stopUpdatingLocation];
    
    // update bomb annotation coordinates and add it to the map
    [Bomb setCoordinate:[NewLocation coordinate]];
    [Map addAnnotation:Bomb];
        
    [Map setRegion:MKCoordinateRegionMake([NewLocation coordinate], MKCoordinateSpanMake(0.2, 0.2)) animated:TRUE];
    [self RenderDamageZones];
}

// display popover for bombs selection
- (IBAction) SelectBomb: (id) sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (![Popover isPopoverVisible]) {
            BombSelectorController = [[BombSelector alloc] init];
            [BombSelectorController setBombsList:[Bombs objectForKey:@"Bombs"]];
            Popover = [[UIPopoverController alloc] initWithContentViewController:BombSelectorController];
            [Popover setPopoverContentSize:CGSizeMake(400, 300)];
            [Popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        BombSelectorController = [[BombSelector alloc] init];
        [BombSelectorController setBombsList:[Bombs objectForKey:@"Bombs"]];
        [self presentModalViewController:BombSelectorController animated:YES];
    }
}

// popover is closed and new bomb id selected
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    
    if ([Popover isPopoverVisible]) [Popover dismissPopoverAnimated:YES];
    else [self dismissModalViewControllerAnimated:YES];
       
    
    SelectedBomb = [[Bombs objectForKey:@"Bombs"] objectAtIndex:[BombSelectorController SelectedBombID]];
    
    NSUserDefaults *Settings = [NSUserDefaults standardUserDefaults];
    [Settings setInteger:[BombSelectorController SelectedBombID] forKey:@"SelectedBombIndex"];
    
    [self RenderDamageZones];
}

// go to my location button click
- (IBAction)GotoMyLocation:(id)sender
{
    [LocationManager startUpdatingLocation];
}

// prompt for location and blow it up
- (IBAction) GotoEnteredLocation: (id) sender
{
    UIAlertView *PromptAlert = [[UIAlertView alloc] initWithTitle:@"Enter city name" message:@"and watch it blowing up" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Launch",nil];
    [PromptAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [PromptAlert show];
}

// button clicked on location prompt
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{ 
    if (buttonIndex == 1)
    {
        
        CLGeocoder *Geocoder = [[CLGeocoder alloc] init];
        
        // convert location to coordinates
        [Geocoder geocodeAddressString:[[alertView textFieldAtIndex:0] text] completionHandler: 
         ^(NSArray *placemarks, NSError *error) {
             if ([placemarks count] > 0) {
                 CLLocation *Destination = [[placemarks objectAtIndex:0] location];
                                  
                 [Bomb setCoordinate:[Destination coordinate]];
                 [Map addAnnotation:Bomb];
                 [self RenderDamageZones];
                 
             } else {
                 [[[UIAlertView alloc] initWithTitle:@"Error" message:@"uknown location" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
             }
         }];
    }
}

// assign view for annotation
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) BombAnnotation
{
    if (BombAnnotation == Bomb)
    {
        BombView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Bomb"];
    
        if (!BombView)
        {
            BombView = [[MKAnnotationView alloc] initWithAnnotation:BombAnnotation reuseIdentifier:@"Bomb"];
            [BombView setDraggable:YES];
            [BombView setEnabled:YES];
            [BombView setCanShowCallout:NO];
            [BombView setMultipleTouchEnabled:NO];
            [BombView setImage:[UIImage imageNamed:@"BombIcon.png"]];

        }    
        else [BombView setAnnotation:BombAnnotation];
    }
    return BombView;
}

// add damage zones on the map
- (void) RenderDamageZones
{    
    [Map removeOverlays:[Map overlays]];
    
    double ZoneRadius = [[SelectedBomb objectForKey:@"power"] doubleValue];
    
    [Map addOverlay:[MKCircle circleWithCenterCoordinate:[Bomb coordinate] radius:ZoneRadius*1.5]];
    [Map addOverlay:[MKCircle circleWithCenterCoordinate:[Bomb coordinate] radius:ZoneRadius*0.10]];
    [Map addOverlay:[MKCircle circleWithCenterCoordinate:[Bomb coordinate] radius:ZoneRadius*0.30]];
    [Map addOverlay:[MKCircle circleWithCenterCoordinate:[Bomb coordinate] radius:ZoneRadius*0.85]];
    [Map addOverlay:[MKCircle circleWithCenterCoordinate:[Bomb coordinate] radius:ZoneRadius]];
    
    [Map setCenterCoordinate:[Bomb coordinate] zoomLevel:[[SelectedBomb objectForKey:@"zoom"] integerValue] animated:YES];
    
}

// add damage zone view on the map
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)DamageZoneOverlay
{
    MKCircleView *DamageZoneView = [[MKCircleView alloc] initWithCircle:DamageZoneOverlay];
    MKCircle *DamageZoneRadius = DamageZoneOverlay;
    
    // green color for radiation fallout area
    if ([DamageZoneRadius radius] > [[SelectedBomb objectForKey:@"power"] doubleValue])
        [DamageZoneView setFillColor:[UIColor greenColor]];
    else
        [DamageZoneView setFillColor:[UIColor redColor]];
            
    [DamageZoneView setAlpha:0.4];
    
    return DamageZoneView;
}

// drag annotation view
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState 
{    
    if ([annotationView annotation] == Bomb) {
        if (newState == MKAnnotationViewDragStateEnding) 
        {
            [annotationView setDragState:MKAnnotationViewDragStateNone];
        
            [self RenderDamageZones];
        
            // TODO: add animation here
        }
        else if (newState == MKAnnotationViewDragStateStarting) 
        {
            [Map removeOverlays:[Map overlays]];
       
            // TODO: add animation here 
        }
    }
}

// we support all device orientations
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
