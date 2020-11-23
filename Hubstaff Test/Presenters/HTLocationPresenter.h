//
//  HTLocationPresenter.h
//  Hubstaff Test
//
//  Created by André Campana on 21.11.20.
//

#import "HTBasePresenter.h"


@class HTSite;
@class CLLocationManager;
@class CLLocation;
@class CLCircularRegion;


NS_ASSUME_NONNULL_BEGIN

@protocol HTLocationView <HTBaseView>
- (void)bindCurrentLocation:(CLLocation * __nullable)location;
- (void)userDidEnterRegion:(CLCircularRegion *)region;
- (void)userDidExitRegion:(CLCircularRegion *)region;
@end


@interface HTLocationPresenter : HTBasePresenter

@property (nonatomic, readonly) id<HTLocationView> __nullable locationView;

- (instancetype)initWithLocationView:(id<HTLocationView>)locationView
                  andLocationManager:(CLLocationManager * __nullable)locationManager;

/// A `CLLocationManager` used by this presenter.
@property (nonatomic, readonly) CLLocationManager *locationManager;

- (void)startTrackingRegionsWithSites:(NSArray<HTSite *> *)sites;

@end

NS_ASSUME_NONNULL_END
