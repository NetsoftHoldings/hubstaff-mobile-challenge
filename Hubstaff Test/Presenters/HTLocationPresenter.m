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
    switch (self.authorizationStatus) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
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
    [self setLoadingState:HTPresenterLoadingStateLoading];

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

#warning TODO: AC - diff the existing regions instead of resetting everything
        for (CLRegion *region in locationManager.monitoredRegions) {
            [locationManager stopMonitoringForRegion:region];
        }
        for (CLRegion *region in newRegions) {
            [locationManager startMonitoringForRegion:region];
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf setLoadingState:HTPresenterLoadingStateIdle];
        });
    }];

    if (self.hasLocationPermission) {
        [self.locationManager startUpdatingLocation];
        [self.queue setSuspended:NO];
    } else {
        [locationManager requestWhenInUseAuthorization];
    }
}

- (void)stopUpdatingLocations {
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Location Manager Delegate
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager
{
    if (self.hasLocationPermission) {
        [self.locationManager startUpdatingLocation];
        [self.queue setSuspended:NO];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.locationView bindCurrentLocation:manager.location];
        });
    } else {
        [self.queue setSuspended:YES];
        [self.queue cancelAllOperations];
#warning TODO: AC - pass an error to `presentError:` asking the user to enable location services, as well as enabling high accuracy locations
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.locationView bindCurrentLocation:locations.lastObject];
    });
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLCircularRegion *)region
{
    __weak id<HTLocationView> view = self.locationView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [view userDidEnterRegion:region];
    });
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLCircularRegion *)region
{
    __weak id<HTLocationView> view = self.locationView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [view userDidExitRegion:region];
    });
}

@end

NS_ASSUME_NONNULL_END
