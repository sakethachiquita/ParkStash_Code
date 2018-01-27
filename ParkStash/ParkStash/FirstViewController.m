//
//  FirstViewController.m
//  ParkStash
//
//  Created by Saketha  on 1/23/18.
//  Copyright © 2018 ParkStash. All rights reserved.
//

#import "FirstViewController.h"
#import "MapAnnotation.h"

#define LOCATION_DICT           @"LOCATION_DICT"
#define METERS_PER_MILE         1609.344


@interface FirstViewController ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *settingsViewLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mapViewLeadingConstraint;

@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) IBOutlet UIView *settingsView;
@property (strong, nonatomic) IBOutlet UIView *mapView;

@property (assign, nonatomic) BOOL isOpen;
@property (strong, nonatomic) IBOutlet MKMapView *mkMapView;

@property (strong, nonatomic) NSMutableDictionary *locationDictionary;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_mainView bringSubviewToFront:self.settingsView];
    [self createDummyData];
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [userdefaults objectForKey:LOCATION_DICT];
    NSLog(@"Saved addresses - %@", dict);
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self hideSettingsView:NO];
}

- (void)createDummyData {
    [self getLocationFromAddressString:@"San Jose"];
    [self getLocationFromAddressString:@"Menlo park"];
    [self getLocationFromAddressString:@"Palo Alto"];
    [self getLocationFromAddressString:@"Sunnyvale"];
    [self getLocationFromAddressString:@"Cupertino"];

}

- (void)hideSettingsView:(BOOL)open {
    CGFloat settingsLeadingConstant = open ? 0.0 : -self.settingsView.frame.size.width;
    self.settingsViewLeadingConstraint.constant = settingsLeadingConstant;
    CGFloat mapViewLeadingConstant = open ? self.settingsView.frame.size.width : 0.0;
    self.mapViewLeadingConstraint.constant = mapViewLeadingConstant;
    
    self.isOpen = open;
}

- (IBAction)settingsHideOpenAction:(id)sender {
    if(self.isOpen == YES) {
        [self hideSettingsView:NO];
    } else {
        [self hideSettingsView:YES];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
   [self getLocationFromAddressString:searchBar.text];
}

- (void)getLocationFromAddressString:(NSString *)addressStr {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:addressStr completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if(!error)
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             
             CLLocationCoordinate2D clLocationCoordinate2D;
             clLocationCoordinate2D.latitude = placemark.location.coordinate.latitude;
             clLocationCoordinate2D.longitude = placemark.location.coordinate.longitude;

             [self addMapMarkersForPlacemarks:placemarks withAddress:addressStr];
             [self saveAddress:clLocationCoordinate2D addressStr:addressStr];

         }
         else
         {
             NSLog(@"There was a forward geocoding error\n%@", [error localizedDescription]);
         }
     }
     ];
    
}

- (void)saveAddress:(CLLocationCoordinate2D)clLocationCoordinate2D addressStr:(NSString *)addressStr{
    if(self.locationDictionary == nil) {
        self.locationDictionary = [[NSMutableDictionary alloc] init];
    }
    
    NSData *data = [NSData dataWithBytes:&clLocationCoordinate2D length:sizeof(MKCoordinateRegion)];
    [self.locationDictionary setObject:data forKey:addressStr];
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:self.locationDictionary forKey:LOCATION_DICT];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // Do not redecorate the user's location annotation.
    if (annotation == self.mkMapView.userLocation) {
        return nil;
    }
    
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mkMapView dequeueReusableAnnotationViewWithIdentifier: @"eventMap"];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"eventMap"];
    } else {
        pin.annotation = annotation;
    }
    pin.pinTintColor = MKPinAnnotationColorRed;
    pin.canShowCallout = YES;
    pin.animatesDrop = YES;
    pin.draggable = NO;
    
    return pin;
}

- (void)addMapMarkersForPlacemarks:(NSArray *)placemarks
                       withAddress:(NSString *)address {
    for (CLPlacemark *aPlacemark in placemarks) {
        CLLocationCoordinate2D zoomLocation = aPlacemark.location.coordinate;
        
        // If the API can't resolve coordinates from the address, just leave the map view empty.
        if (zoomLocation.latitude != -1.0 && zoomLocation.longitude != -1.0) {
            
            // Remove all previous annotations on the map.
            /*
            for (id annotation in self.mkMapView.annotations) {
                if (annotation != self.mkMapView.userLocation) {
                    [self.mkMapView removeAnnotation:annotation];
                }
            }
            */
            
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5 * METERS_PER_MILE, 0.5 * METERS_PER_MILE);
            MKCoordinateRegion adjustedRegion = [self.mkMapView regionThatFits:viewRegion];
            
            MapAnnotation *newAnnotation = [[MapAnnotation alloc] initWithCoordinate:zoomLocation];
            newAnnotation.annotationTitle = address;
            
            [self.mkMapView setRegion:adjustedRegion animated:NO];
            [self.mkMapView addAnnotation:newAnnotation];
            [self.mkMapView setShowsUserLocation:NO];
        }
    }
    
}

@end
