//
//  HTMapViewController.m
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import "HTMapViewController.h"
#import <MapKit/MapKit.h>

@interface HTMapViewController ()

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation HTMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


#pragma mark - MapView Delegate
@interface HTMapViewController (MapView) <MKMapViewDelegate>
@end

@implementation HTMapViewController (MapView)

@end
