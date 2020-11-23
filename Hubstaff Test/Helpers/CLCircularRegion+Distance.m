//
//  CLCircularRegion+Distance.m
//  Hubstaff Test
//
//  Created by André Campana on 23.11.20.
//

#import "CLCircularRegion+Distance.h"


@implementation CLCircularRegion (Distance)

- (CLLocationDistance)getDistanceFromLocation:(CLLocation *)location
{
    CLLocation *tempLocation = [[CLLocation alloc] initWithLatitude:self.center.latitude
                                                          longitude:self.center.longitude];
    return [tempLocation distanceFromLocation:location];
}

@end
