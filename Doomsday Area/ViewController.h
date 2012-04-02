//
//  ViewController.h
//  Doomsday Area
//
//  Created by Vladimir Smirnov on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BombAnnotation.h"
#import "BombSelector.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UIPopoverControllerDelegate>
{
    BombAnnotation *Bomb;
    MKAnnotationView *BombView;
    CLLocationManager *LocationManager;
    NSDictionary *Bombs;
    NSDictionary *SelectedBomb;
    
    IBOutlet MKMapView *Map;
    IBOutlet UIToolbar *BottomToolbar;
    
    BombSelector *BombSelectorController;
}

- (void) RenderDamageZones;

- (IBAction) GotoMyLocation: (id) sender;
- (IBAction) GotoEnteredLocation: (id) sender;
- (IBAction) SelectBomb: (id) sender;

@property (nonatomic, retain) CLLocationManager *LocationManager;
@property (retain,nonatomic) UIPopoverController *Popover;


@end
