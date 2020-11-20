//
//  HTAllSitesPresenter.m
//  Hubstaff Test
//
//  Created by André Campana on 20.11.20.
//

#import "HTAllSitesPresenter.h"
#import "HTSite.h"
#import "HTAPIClient.h"
#import <CoreLocation/CoreLocation.h>


@interface HTAllSitesPresenter ()

@property (nonatomic, strong) NSArray<HTSite *> *allSites;

@end


@implementation HTAllSitesPresenter

#pragma mark - Setup

- (instancetype)initWithAllSitesView:(id<HTAllSitesView>)allSitesView
{
    if (self = [self initWithBaseView:allSitesView]) {
        //Noop
    }
    return self;
}

#pragma mark - Loading

- (void)loadAllSites
{
    [self setLoadingState:HTPresenterLoadingStateLoading];
    __weak typeof(self) weakSelf = self;
    [[HTAPIClient sharedClient] loadAllSitesWithBlock:^(NSArray<HTSite *> *sites) {
        weakSelf.allSites = sites;

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.allSitesView bindAllSites:sites];
        });

        BOOL isEmpty = sites.count == 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isEmpty) {
                [weakSelf setLoadingState:HTPresenterLoadingStateEmpty];
            } else {
                [weakSelf setLoadingState:HTPresenterLoadingStateIdle];
            }
        });
    }];
}

@end
