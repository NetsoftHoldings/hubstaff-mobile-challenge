//
//  HTNotificationsPresenter.m
//  Hubstaff Test
//
//  Created by André Campana on 21.11.20.
//

#import "HTNotificationsPresenter.h"
#import "HTSite.h"
#import <UserNotifications/UserNotifications.h>
#import "HTConstants.h"


NS_ASSUME_NONNULL_BEGIN


@interface HTNotificationsPresenter()

// Setup
- (void)setUpNotificationsPermissions;
// Helpers
@property (nonatomic, readonly) UNUserNotificationCenter *notificationCenter;
+ (NSSet<UNNotificationCategory *> *)notificationCategories;

@end

@interface HTNotificationsPresenter(NotificationDelegate) <UNUserNotificationCenterDelegate>
@end


@implementation HTNotificationsPresenter

#pragma mark - Setup
- (instancetype)initWithNotificationView:(id<HTNotificationsView>)notificationView
{
    self = [super initWithBaseView:notificationView andQueue:nil];
    return self;
}

- (id<HTNotificationsView> __nullable)notificationView
{
    if ([self.baseView conformsToProtocol:@protocol(HTNotificationsView)]) {
        return (id<HTNotificationsView> __nullable)self.baseView;
    }
    return nil;
}

#pragma mark - Notification Actions

- (void)setUpNotificationsPermissions
{
    __weak typeof(self) weakSelf = self;
    [self setLoadingState:HTPresenterLoadingStateLoading];
    [self.queue setSuspended:YES];

    UNUserNotificationCenter *notificationCenter = self.notificationCenter;
    notificationCenter.delegate = self;

    UNAuthorizationOptions options = UNAuthorizationOptionSound |
                                     UNAuthorizationOptionAlert |
                                     UNAuthorizationOptionCarPlay |
                                     UNAuthorizationOptionProvisional;
    [notificationCenter requestAuthorizationWithOptions:options
                                           completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == NO) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.notificationView presentError:error];
                });
            }
            [weakSelf.queue cancelAllOperations];
            return;
        }

        [notificationCenter setNotificationCategories:[HTNotificationsPresenter notificationCategories]];
        [notificationCenter removeAllDeliveredNotifications];
        [notificationCenter removeAllPendingNotificationRequests];

        [weakSelf.queue setSuspended:NO];
        [weakSelf setLoadingState:HTPresenterLoadingStateIdle];
    }];
}

- (void)showNotificationForSite:(HTSite *)site
           withNotificationType:(HTRegionNotificationType)crossingType
                    andBodyText:(NSString * __nullable)bodyText
{
    [self setUpNotificationsPermissions];

    __weak typeof(self) weakSelf = self;
    [self.queue addOperationWithBlock:^{
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.categoryIdentifier = kHTEnterExitRegionCategoryId;
        content.summaryArgumentCount = 1;

        switch (crossingType) {
            case HTRegionNotificationEnter:
                content.title = NSLocalizedString(@"Entering site:", nil);
                break;
            case HTRegionNotificationExit:
                content.title = NSLocalizedString(@"Exiting site:", nil);
                break;
            default:
                break;
        }

        content.subtitle = site.name;
        content.body = bodyText;

        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:site.siteId
                                                                              content:content
                                                                              trigger:nil];
        [weakSelf.notificationCenter addNotificationRequest:request
                                      withCompletionHandler:^(NSError * _Nullable error)
        {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.notificationView presentError:error];
                });
            }
        }];
    }];
}

#pragma mark - Helpers

- (UNUserNotificationCenter *)notificationCenter {
    return [UNUserNotificationCenter currentNotificationCenter];
}

+ (NSSet<UNNotificationCategory *> *)notificationCategories
{
    return [NSSet setWithArray:@[
        [UNNotificationCategory categoryWithIdentifier:kHTEnterExitRegionCategoryId
                                               actions:@[]
                                     intentIdentifiers:@[]
                         hiddenPreviewsBodyPlaceholder:[NSString localizedUserNotificationStringForKey:@"%u Sites Crossed" arguments:nil]
                                 categorySummaryFormat:NSLocalizedString(@"Recent Sites Crossed", nil)
                                               options:UNNotificationCategoryOptionAllowInCarPlay | UNNotificationCategoryOptionHiddenPreviewsShowTitle]
    ]];
}

@end

#pragma mark - Notification Center Delegate
@implementation HTNotificationsPresenter(NotificationDelegate)

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    if (@available(iOS 14.0, *)) {
        completionHandler(UNNotificationPresentationOptionBanner);
        return;
    }
    completionHandler(UNNotificationPresentationOptionAlert);
}

@end

NS_ASSUME_NONNULL_END
