//
//  NSObject+Introspection.h
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Introspection)

/// Gets all properties of an object and returns them as an array of strings representing their names. Source: https://stackoverflow.com/a/11774276
+ (NSArray<NSString *> *)propertyNames;
- (NSArray<NSString *> *)propertyNames;

@end

NS_ASSUME_NONNULL_END
