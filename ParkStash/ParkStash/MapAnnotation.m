//
//  MapAnnotation.m
//  ParkStash
//
//  Created by Saketha  on 1/23/18.
//  Copyright © 2018 ParkStash. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord {
    self = [super init];
    self.coordinate = coord;
    
    return self;
}

-(NSString *)title {
    return self.annotationTitle;
}

-(NSString *)subtitle {
    return self.annotationSubtitle;
}
@end
