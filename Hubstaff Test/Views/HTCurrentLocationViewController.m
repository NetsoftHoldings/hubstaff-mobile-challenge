//
//  HTCurrentLocationViewController.m
//  Hubstaff Test
//
//  Created by André Campana on 23.11.20.
//

#import "HTCurrentLocationViewController.h"
#import <CoreLocation/CLLocation.h>
#import "HTLocationPresenter.h"
#import "AppDelegate.h"


#define kHTCurrentLocationViewControllerPlaceholder @"-"


NS_ASSUME_NONNULL_BEGIN

@interface HTCurrentLocationViewController () <HTLocationView>

@property (nonatomic, weak) IBOutlet UILabel * __nullable locationLabel;

@end


@implementation HTCurrentLocationViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    /**
     When using storyboards, the instantiation of view controllers is done by the system. Navigation logic is also hidden somewhat.
     Because of this, it's hard to inject dependencies into view controllers.
     So we're breaking the dependency injection pattern here and making this VC attach itself to the global AppDelegate,
     which is not cool, but sometimes has to be done.
     */
    [AppDelegate sharedDelegate].currentLocationView = self;
}

#pragma mark - Location View
- (void)bindCurrentLocation:(CLLocation * __nullable)location
{
    if (location == nil) {
        _locationLabel.text = kHTCurrentLocationViewControllerPlaceholder;
        return;
    }
    _locationLabel.text = [NSString localizedStringWithFormat:@"%@: %f.3, %f.3",
                           NSLocalizedString(@"Last known position:", nil),
                           location.coordinate.latitude,
                           location.coordinate.longitude];
}

- (void)userDidEnterRegion:(CLRegion *)region {}
- (void)userDidExitRegion:(CLRegion *)region {}

- (void)didChangeLoadingState:(HTPresenterLoadingState)state { 
    switch (state) {
        case HTPresenterLoadingStateLoading:
        case HTPresenterLoadingStateEmpty:
            _locationLabel.hidden = YES;
            break;
        case HTPresenterLoadingStateIdle:
            _locationLabel.hidden = NO;
        default:
            break;
    }
}

@end

NS_ASSUME_NONNULL_END
