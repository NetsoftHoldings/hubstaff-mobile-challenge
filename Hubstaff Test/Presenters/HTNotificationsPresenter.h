//
//  HTNotificationsPresenter.h
//  Hubstaff Test
//
//  Created by André Campana on 21.11.20.
//

#import "HTBasePresenter.h"


@class HTSite;


typedef NS_ENUM(NSUInteger, HTRegionNotificationType) {
    HTRegionNotificationEnter,
    HTRegionNotificationExit
};


NS_ASSUME_NONNULL_BEGIN

/// No use for this now, but perhaps this can be a way to perfom actions when the user taps on a location notification
@protocol HTNotificationsView <HTBaseView>
@end


@interface HTNotificationsPresenter : HTBasePresenter

@property (nonatomic, weak) id<HTNotificationsView> __nullable notificationView;

- (instancetype)initWithNotificationView:(id<HTNotificationsView>)notificationView;

- (void)showNotificationForSite:(HTSite *)site
           withNotificationType:(HTRegionNotificationType)crossingType
                    andBodyText:(NSString * __nullable)bodyText;

@end

NS_ASSUME_NONNULL_END
