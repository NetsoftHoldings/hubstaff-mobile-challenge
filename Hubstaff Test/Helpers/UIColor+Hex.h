//
//  UIColor+Hex.h
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Hex)

/// Assumes input like "#00FF00" (#RRGGBB). Source: https://stackoverflow.com/a/12397366
+ (UIColor * __nullable)colorFromHexString:(NSString * __nullable)hexString;

@end

NS_ASSUME_NONNULL_END
