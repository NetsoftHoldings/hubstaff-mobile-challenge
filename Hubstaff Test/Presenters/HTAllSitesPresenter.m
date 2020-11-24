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

@interface HTAllSitesPresenter () <HTAllSitesResponseDelegate>

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
    [[HTAPIClient sharedClient] loadAllSitesWithDelegate:self];
}

#pragma mark - All Sites Response Delegate

- (NSOperationQueue * __nullable)apiResponseQueue {
    return self.queue;
}

- (void)didReceiveAllSitesResponse:(NSArray<HTSite *> *)allSites
{
    NSMutableDictionary<NSString *, HTSite *> *newSites = [[NSMutableDictionary alloc] initWithCapacity:allSites.count + 1];
    for (HTSite *site in allSites) {
        [newSites setValue:site forKey:site.siteId];
    }
    self.allSites = [newSites copy];

    __weak typeof(self) weakSelf = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
        [weakSelf.allSitesView bindAllSites:weakSelf.allSites];
    });

    BOOL isEmpty = allSites.count == 0;
    if (isEmpty) {
        [self setLoadingState:HTPresenterLoadingStateEmpty];
    } else {
        [self setLoadingState:HTPresenterLoadingStateIdle];
    }
}

@end

NS_ASSUME_NONNULL_END
