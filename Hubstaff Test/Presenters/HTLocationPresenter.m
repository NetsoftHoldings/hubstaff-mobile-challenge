//
//  HTLocationPresenter.m
//  Hubstaff Test
//
//  Created by André Campana on 21.11.20.
//

#import "HTLocationPresenter.h"
#import <CoreLocation/CoreLocation.h>
#import "HTConstants.h"
#import "HTSite.h"


NS_ASSUME_NONNULL_BEGIN

@interface HTLocationPresenter() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

// Flags
- (CLAuthorizationStatus)authorizationStatus;
- (BOOL)areLocationServicesUnavailable;
- (BOOL)areLocationServicesDenied;
- (BOOL)hasLocationPermission;

// Helper
+ (CLCircularRegion *)circularRegionWithSite:(HTSite *)site
                          andMaximumDistance:(CLLocationDistance)maximumDistance;
- (void)didChangeAuthorization;

@end


@implementation HTLocationPresenter

#pragma mark - Setup
- (instancetype)initWithLocationView:(id<HTLocationView>)locationView
                  andLocationManager:(CLLocationManager * __nullable)locationManager
{
    if (self = [super initWithBaseView:locationView andQueue:nil]) {
        if (locationManager) {
            _locationManager = locationManager;
        }
    }
    return self;
}

- (id<HTLocationView> __nullable)locationView
{
    if ([self.baseView conformsToProtocol:@protocol(HTLocationView)]) {
        return (id<HTLocationView> __nullable)self.baseView;
    }
    return nil;
}

#pragma mark - Flags

- (CLAuthorizationStatus)authorizationStatus
{
    if (@available(iOS 14.0, *)) {
        return self.locationManager.authorizationStatus;
    } else {
        return [CLLocationManager authorizationStatus];
    }
}

- (BOOL)areLocationServicesUnavailable
{
    if ([CLLocationManager significantLocationChangeMonitoringAvailable] == NO) {
        return YES;
    }
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]] == NO) {
        return YES;
    }
    return NO;
}

- (BOOL)areLocationServicesDenied
{
    if (@available(iOS 14.0, *)) {
        if (self.locationManager.accuracyAuthorization == CLAccuracyAuthorizationReducedAccuracy) {
            return YES;
        }
    }
    switch (self.authorizationStatus) {
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            return YES;
        default:
            break;
    }
    return NO;
}

- (BOOL)hasLocationPermission
{
    if (@available(iOS 14.0, *)) {
        switch (self.authorizationStatus) {
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                return YES;
            default:
                return NO;
        }
    }
    switch (self.authorizationStatus) {
        case kCLAuthorizationStatusAuthorizedAlways:
            return YES;
        default:
            return NO;
    }
}

#pragma mark - Helpers

+ (CLCircularRegion *)circularRegionWithSite:(HTSite *)site
                          andMaximumDistance:(CLLocationDistance)maximumDistance
{
    CLLocationDistance radius = site.radiusInMeters.doubleValue;
    if (radius > maximumDistance) {
        radius = maximumDistance;
    }
    return [[CLCircularRegion alloc] initWithCenter:site.location.coordinate
                                             radius:radius
                                         identifier:site.siteId];
}

- (void)didChangeAuthorization
{
    if (self.hasLocationPermission) {
        [self.locationManager startMonitoringSignificantLocationChanges];
        [self.queue setSuspended:NO];

        CLLocation *location = self.locationManager.location;
        if (location) {
            [self locationManager:self.locationManager
               didUpdateLocations:@[location]];
        }
    } else {
        [self.queue setSuspended:YES];
#warning TODO: AC - pass an error to `presentError:` asking the user to enable location services, as well as enabling high accuracy locations
    }
    [self setLoadingState:HTPresenterLoadingStateIdle];
}

#pragma mark - Location Manager Methods
- (CLLocationManager *)locationManager
{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;

        _locationManager.activityType = CLActivityTypeOtherNavigation;
        _locationManager.allowsBackgroundLocationUpdates = YES;
        _locationManager.distanceFilter = kHTMinimumDistanceFilter;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.headingFilter = kHTMinimumHeadingFilter;
    }
    return _locationManager;
}

- (void)startTrackingRegionsWithSites:(NSArray<HTSite *> *)sites
{
    CLLocationManager *locationManager = self.locationManager;
    [self.queue setSuspended:YES];

    if (self.areLocationServicesUnavailable) {
#warning TODO: AC - emit an error here to the view
        NSAssert(false, @"Location services not available on this device");
        return;
    }

    if (self.areLocationServicesDenied) {
#warning TODO: AC - emit an error here to the view
        NSAssert(false, @"Location services not allowed on this device");
        return;
    }

    [self setLoadingState:HTPresenterLoadingStateLoading];

    __weak typeof(self) weakSelf = self;
    [self.queue addOperationWithBlock:^{
        CLLocationDistance maximumDistance = locationManager.maximumRegionMonitoringDistance;
        NSUInteger totalSites = (sites.count >= kHTMaximumNumberOfRegions) ? kHTMaximumNumberOfRegions : sites.count;
        NSMutableArray<CLCircularRegion *> *newRegions = [[NSMutableArray alloc] initWithCapacity:totalSites];
        [sites enumerateObjectsUsingBlock:^(HTSite * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
#warning TODO: AC - review the policy we want to apply to drop sites
            if (idx >= kHTMaximumNumberOfRegions) {
                *stop = YES;
                return;
            }

            CLCircularRegion *region = [HTLocationPresenter circularRegionWithSite:obj
                                                                andMaximumDistance:maximumDistance];
            region.notifyOnEntry = YES;
            region.notifyOnExit = YES;

            [newRegions addObject:region];
        }];

        CLLocation *currentLocaction = locationManager.location;
        if (currentLocaction != nil &&
            currentLocaction.horizontalAccuracy > kHTMinimumDistanceFilter)
        {
            currentLocaction = nil;
        }

#warning TODO: AC - diff the existing regions instead of resetting everything
        for (CLRegion *region in locationManager.monitoredRegions) {
            [locationManager stopMonitoringForRegion:region];
        }
        for (CLCircularRegion *region in newRegions) {
            [locationManager startMonitoringForRegion:region];
            /**
             Here we check if the user is already in a region
             */
            if (currentLocaction != nil && [region containsCoordinate:currentLocaction.coordinate]) {
                [weakSelf locationManager:locationManager
                           didEnterRegion:region];
            }
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf setLoadingState:HTPresenterLoadingStateIdle];
        });
    }];

    if (self.hasLocationPermission) {
        [self.locationManager startMonitoringSignificantLocationChanges];
        [self.queue setSuspended:NO];
    } else {
        [self setLoadingState:HTPresenterLoadingStateLoading];
        [locationManager requestAlwaysAuthorization];
    }
}

- (void)stopUpdatingLocations {
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Location Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self didChangeAuthorization];
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager
{
    [self didChangeAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = locations.lastObject;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.locationView bindCurrentLocation:location];
    });
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
#if DEBUG
    NSLog(@"DID START MONITORING REGION: %@", region);
#endif
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion * __nullable)region
              withError:(NSError *)error
{
#if DEBUG
    NSLog(@"FAILED TO MONITOR REGION; ERROR: %@", error);
#endif
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLCircularRegion class]] == NO) return;

    __weak id<HTLocationView> view = self.locationView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [view userDidEnterRegion:(CLCircularRegion *)region];
    });
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLCircularRegion class]] == NO) return;

    __weak id<HTLocationView> view = self.locationView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [view userDidExitRegion:(CLCircularRegion *)region];
    });
}

@end

NS_ASSUME_NONNULL_END
