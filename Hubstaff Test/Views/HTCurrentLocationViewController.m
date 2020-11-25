//
//  HTCurrentLocationViewController.m
//  Hubstaff Test
//
//  Created by André Campana on 23.11.20.
//

#import "HTCurrentLocationViewController.h"
#import <CoreLocation/CLLocation.h>
#import "HTLocationPresenter.h"


#define kHTCurrentLocationViewControllerPlaceholder @"-"


NS_ASSUME_NONNULL_BEGIN

@interface HTCurrentLocationViewController ()

@property (nonatomic, weak) IBOutlet UILabel * __nullable locationLabel;

@end


@implementation HTCurrentLocationViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    _locationLabel.text = kHTCurrentLocationViewControllerPlaceholder;
}

#pragma mark - Location View
- (void)bindCurrentLocation:(CLLocation * __nullable)location
{
    if (location == nil) {
        _locationLabel.text = kHTCurrentLocationViewControllerPlaceholder;
        return;
    }
    _locationLabel.text = [NSString localizedStringWithFormat:@"%@: \n%.3f, %.3f",
                           NSLocalizedString(@"Last known position", nil),
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
