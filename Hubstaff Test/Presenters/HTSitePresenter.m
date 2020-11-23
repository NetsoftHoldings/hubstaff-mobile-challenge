//
//  HTSitePresenter.m
//  Hubstaff Test
//
//  Created by André Campana on 20.11.20.
//

#import "HTSitePresenter.h"
#import "HTSite.h"


NS_ASSUME_NONNULL_BEGIN

@implementation HTSitePresenter

#pragma mark - Setup

@synthesize site = _site;

- (instancetype)initWithSiteView:(id<HTSiteView>)siteView
                         andSite:(HTSite *)site
{
    if (self = [self initWithBaseView:siteView andQueue:nil]) {
        _site = site;
    }
    return self;
}

#pragma mark - Binding

- (void)setSite:(HTSite *)site
{
    @synchronized (self) {
        _site = site;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.siteView bindSite:site];
        });
    }
}

@end

NS_ASSUME_NONNULL_END
