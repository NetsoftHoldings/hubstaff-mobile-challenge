//
//  HTMapViewController.m
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import "HTMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "HTSite.h"
#import "HTAllSitesPresenter.h"
#import "HTLocationPresenter.h"
#import "HTNotificationsPresenter.h"
#import "HTCurrentLocationViewController.h"
#import "HTActivityIndicatorView.h"
#import "CLCircularRegion+Distance.h"


#define kHTMapViewControllerCircleStrokeColor [[UIColor systemBlueColor] colorWithAlphaComponent:0.8]
#define kHTMapViewControllerCircleFillColor [[UIColor systemBlueColor] colorWithAlphaComponent:0.4]


NS_ASSUME_NONNULL_BEGIN

@interface HTMapViewController () <HTAllSitesView, HTLocationView, HTNotificationsView>

// Presenters
@property (nonatomic, strong) HTAllSitesPresenter *allSitesPresenter;
@property (nonatomic, strong) HTLocationPresenter *locationPresenter;
@property (nonatomic, strong) HTNotificationsPresenter *notificationPresenter;

// Views
@property (nonatomic, weak) IBOutlet HTActivityIndicatorView * __nullable activityIndicatorView;
@property (nonatomic, weak) IBOutlet MKMapView * __nullable mapView;
@property (nonatomic, weak) HTCurrentLocationViewController * __nullable currentLocationViewController;

// View Controller Life Cycle
@property (nonatomic, getter=isVisible) BOOL visible;
- (void)viewWillAppearOrAppIsInForeground;
- (void)viewDidDisappearOrAppIsInBackground;

// App Life Cycle
@property (nonatomic, strong) id<NSObject> __nullable appStateBackgroundToken;
@property (nonatomic, strong) id<NSObject> __nullable appStateForegroundToken;

// Formatters
@property (nonatomic, strong) NSMeasurementFormatter *distanceFormatter;

// Helpers
- (NSString * __nullable)formattedNotificationBodyTextWithRegion:(CLCircularRegion *)region
                                              andCurrentLocation:(CLLocation * __nullable)location;
+ (MKCircle *)circleOverlayForSite:(HTSite *)site;

@end

@interface HTMapViewController (MapView) <MKMapViewDelegate>

- (void)addSitesToMap:(NSArray<HTSite *> *)sites;

@end


@implementation HTMapViewController

#pragma mark - Presenters
- (HTAllSitesPresenter *)allSitesPresenter
{
    if (_allSitesPresenter == nil) {
        _allSitesPresenter = [[HTAllSitesPresenter alloc] initWithAllSitesView:self];
    }
    return _allSitesPresenter;
}

- (HTLocationPresenter *)locationPresenter
{
    if (_locationPresenter == nil) {
        _locationPresenter = [[HTLocationPresenter alloc] initWithLocationView:self
                                                            andLocationManager:nil];
    }
    return _locationPresenter;
}

- (HTNotificationsPresenter *)notificationPresenter
{
    if (_notificationPresenter == nil) {
        _notificationPresenter = [[HTNotificationsPresenter alloc] initWithNotificationView:self];
    }
    return _notificationPresenter;
}

#pragma mark - Formatters
- (NSMeasurementFormatter *)distanceFormatter
{
    if (_distanceFormatter == nil) {
        _distanceFormatter = [[NSMeasurementFormatter alloc] init];
        _distanceFormatter.unitOptions = NSMeasurementFormatterUnitOptionsNaturalScale | NSMeasurementFormatterUnitOptionsProvidedUnit;
        _distanceFormatter.unitStyle = NSFormattingUnitStyleMedium;
    }
    return _distanceFormatter;
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    self.appStateBackgroundToken = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                                                     object:nil
                                                                                      queue:[NSOperationQueue mainQueue]
                                                                                 usingBlock:^(NSNotification * _Nonnull note)
    {
        [weakSelf viewDidDisappearOrAppIsInBackground];
    }];

    self.appStateForegroundToken = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                                                     object:nil
                                                                                      queue:[NSOperationQueue mainQueue]
                                                                                 usingBlock:^(NSNotification * _Nonnull note)
    {
        [weakSelf viewWillAppearOrAppIsInForeground];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.visible = YES;

    [self viewWillAppearOrAppIsInForeground];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    self.visible = NO;

    [self viewDidDisappearOrAppIsInBackground];
}

- (void)viewWillAppearOrAppIsInForeground
{
    if (self.isVisible == NO) return;
    [self.allSitesPresenter loadAllSites];
}

- (void)viewDidDisappearOrAppIsInBackground
{
    [self.locationPresenter stopUpdatingLocations];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id __nullable)sender
{
    if ([segue.destinationViewController isKindOfClass:[HTCurrentLocationViewController class]]) {
        self.currentLocationViewController = (HTCurrentLocationViewController *)segue.destinationViewController;
    }
}

#pragma mark - Base View
- (void)didChangeLoadingState:(HTPresenterLoadingState)state
{
    switch (state) {
        case HTPresenterLoadingStateLoading:
            [self.activityIndicatorView setAnimating:YES
                                           withDelay:0];
            break;
        case HTPresenterLoadingStateIdle:
        case HTPresenterLoadingStateEmpty:
        default:
            [self.activityIndicatorView setAnimating:NO
                                           withDelay:1];
            break;
    }

    [self.currentLocationViewController didChangeLoadingState:state];
}

#pragma mark - All Sites View
- (void)bindAllSites:(NSDictionary<NSString *,HTSite *> *)allSites
{
    NSArray *sitesArray = [allSites allValues];
    [self.locationPresenter startTrackingRegionsWithSites:sitesArray];
    [self addSitesToMap:sitesArray];
}

#pragma mark - Location View
- (void)bindCurrentLocation:(CLLocation * __nullable)location
{
    [self.currentLocationViewController bindCurrentLocation:location];
    if (location) {
        if (self.mapView.showsUserLocation == NO) {
            self.mapView.showsUserLocation = YES;
        }
    }
}

- (void)userDidEnterRegion:(CLCircularRegion *)region
{
    HTSite *site = [self.allSitesPresenter.allSites objectForKey:region.identifier];
    if (site == nil) return;
    NSString *bodyText = [self formattedNotificationBodyTextWithRegion:region
                                                    andCurrentLocation:self.locationPresenter.locationManager.location];
    [self.notificationPresenter showNotificationForSite:site
                                   withNotificationType:HTRegionNotificationEnter
                                            andBodyText:bodyText];
}

- (void)userDidExitRegion:(CLCircularRegion *)region
{
    HTSite *site = [self.allSitesPresenter.allSites objectForKey:region.identifier];
    if (site == nil) return;
    [self.notificationPresenter showNotificationForSite:site
                                   withNotificationType:HTRegionNotificationExit
                                            andBodyText:nil];
}

#pragma mark - Helpers
- (NSString * __nullable)formattedNotificationBodyTextWithRegion:(CLCircularRegion *)region
                                              andCurrentLocation:(CLLocation * __nullable)location
{
    if (location == nil) return nil;
    CLLocationDistance distance = [region getDistanceFromLocation:location];
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:distance
                                                                       unit:[NSUnitLength meters]];
    return [self.distanceFormatter stringFromMeasurement:measurement];
}

+ (MKCircle *)circleOverlayForSite:(HTSite *)site {
    return [MKCircle circleWithCenterCoordinate:site.location.coordinate
                                         radius:site.radiusInMeters.doubleValue];
}

@end


#pragma mark - MapView Delegate
@implementation HTMapViewController (MapView)

- (void)addSitesToMap:(NSArray<HTSite *> *)sites
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];

    for (HTSite *site in sites) {
        [self.mapView addOverlay:[HTMapViewController circleOverlayForSite:site]
                           level:MKOverlayLevelAboveRoads];
        [self.mapView addAnnotation:site];
    }

    [self.mapView showAnnotations:sites
                         animated:YES];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay
{
    MKCircleRenderer *result = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    result.lineWidth = 1;
    result.strokeColor = kHTMapViewControllerCircleStrokeColor;
    result.fillColor = kHTMapViewControllerCircleFillColor;
    return result;
}

- (MKAnnotationView * __nullable)mapView:(MKMapView *)mapView
                       viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[HTSite class]]) {
        HTSite *site = (HTSite *)annotation;
        MKMarkerAnnotationView *result = [[MKMarkerAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:site.siteId];
        result.animatesWhenAdded = YES;
        result.subtitleVisibility = MKFeatureVisibilityHidden;
        result.markerTintColor = site.uiColor;
        return result;
    }
    return nil;
}

@end

NS_ASSUME_NONNULL_END
