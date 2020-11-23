//
//  AppDelegate.h
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import <UIKit/UIKit.h>


@protocol HTLocationView;


NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (instancetype)sharedDelegate;

@property (nonatomic, weak) id<HTLocationView> __nullable currentLocationView;

@end

NS_ASSUME_NONNULL_END
