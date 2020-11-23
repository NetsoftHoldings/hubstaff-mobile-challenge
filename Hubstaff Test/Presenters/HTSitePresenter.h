//
//  HTSitePresenter.h
//  Hubstaff Test
//
//  Created by André Campana on 20.11.20.
//

#import "HTBasePresenter.h"


@class HTSite;


NS_ASSUME_NONNULL_BEGIN

@protocol HTSiteView <HTBaseView>
- (void)bindSite:(HTSite *)site;
@end


@interface HTSitePresenter : HTBasePresenter

@property (nonatomic, readonly) id<HTSiteView> __nullable siteView;
@property (nonatomic, strong) HTSite *site;

- (instancetype)initWithSiteView:(id<HTSiteView>)siteView
                         andSite:(HTSite *)site;

@end

NS_ASSUME_NONNULL_END
