//
//  HTAllSitesPresenter.h
//  Hubstaff Test
//
//  Created by André Campana on 20.11.20.
//

#import "HTBasePresenter.h"


@class HTSite;


NS_ASSUME_NONNULL_BEGIN

@protocol HTAllSitesView <HTBaseView>
- (void)bindAllSites:(NSDictionary<NSString *, HTSite *> *)allSites;
@end


@interface HTAllSitesPresenter : HTBasePresenter

@property (nonatomic, readonly) id<HTAllSitesView> __nullable allSitesView;
@property (nonatomic, readonly) NSDictionary<NSString *, HTSite *> *allSites;

- (instancetype)initWithAllSitesView:(id<HTAllSitesView>)allSitesView;

- (void)loadAllSites;

@end

NS_ASSUME_NONNULL_END
