//
//  AppDelegate.m
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end


@implementation AppDelegate

+ (instancetype)sharedDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

@end
