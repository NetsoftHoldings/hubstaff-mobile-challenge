//
//  HTAllSitesPresenter.m
//  Hubstaff Test
//
//  Created by André Campana on 20.11.20.
//

#import "HTAllSitesPresenter.h"
#import "HTSite.h"
#import "HTAPIClient.h"


NS_ASSUME_NONNULL_BEGIN

@interface HTAllSitesPresenter ()

@property (nonatomic, strong) NSDictionary<NSString *, HTSite *> *allSites;

@end


@implementation HTAllSitesPresenter

#pragma mark - Setup

- (instancetype)initWithAllSitesView:(id<HTAllSitesView>)allSitesView
{
    if (self = [self initWithBaseView:allSitesView andQueue:nil]) {
        //Noop
    }
    return self;
}

- (id<HTAllSitesView> __nullable)allSitesView
{
    if ([self.baseView conformsToProtocol:@protocol(HTAllSitesView)]) {
        return (id<HTAllSitesView> __nullable)self.baseView;
    }
    return nil;
}

- (NSDictionary<NSString *, HTSite *> *)allSites
{
    if (_allSites == nil) _allSites = @{};
    return _allSites;
}

#pragma mark - Loading

- (void)loadAllSites
{
    [self setLoadingState:HTPresenterLoadingStateLoading];

    __weak typeof(self) weakSelf = self;
    [[HTAPIClient sharedClient] loadAllSitesWithBlock:^(NSArray<HTSite *> *sites) {
        NSMutableDictionary<NSString *, HTSite *> *newSites = [[NSMutableDictionary alloc] initWithCapacity:sites.count + 1];
        for (HTSite *site in sites) {
            [newSites setValue:site forKey:site.siteId];
        }
        weakSelf.allSites = [newSites copy];

        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.allSitesView bindAllSites:weakSelf.allSites];
        });

        BOOL isEmpty = sites.count == 0;
        if (isEmpty) {
            [weakSelf setLoadingState:HTPresenterLoadingStateEmpty];
        } else {
            [weakSelf setLoadingState:HTPresenterLoadingStateIdle];
        }
    } usingQueue:self.queue];
}

@end

NS_ASSUME_NONNULL_END
