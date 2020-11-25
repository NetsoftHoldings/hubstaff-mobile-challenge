//
//  CLCircularRegion+Distance.h
//  Hubstaff Test
//
//  Created by André Campana on 23.11.20.
//

#import <CoreLocation/CoreLocation.h>


NS_ASSUME_NONNULL_BEGIN

@interface CLCircularRegion (Distance)

- (CLLocationDistance)getDistanceFromLocation:(CLLocation *)location;

@end

NS_ASSUME_NONNULL_END
