//
//  MapAnnotation.h
//  ParkStash
//
//  Created by Saketha  on 1/23/18.
//  Copyright © 2018 ParkStash. All rights reserved.
//


#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString * annotationTitle;
@property (nonatomic, strong) NSString * annotationSubtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord;

@end
