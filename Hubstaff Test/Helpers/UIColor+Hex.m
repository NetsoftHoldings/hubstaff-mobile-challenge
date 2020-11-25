//
//  UIColor+Hex.m
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import "UIColor+Hex.h"


@implementation UIColor (Hex)

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    if (hexString.length == 0) return nil;
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0
                           green:((rgbValue & 0xFF00) >> 8) / 255.0
                            blue:(rgbValue & 0xFF) / 255.0
                           alpha:1.0];
}

@end
