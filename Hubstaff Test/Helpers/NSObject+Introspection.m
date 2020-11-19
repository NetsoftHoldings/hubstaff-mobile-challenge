//
//  NSObject+Introspection.m
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import "NSObject+Introspection.h"
#import <objc/runtime.h>


@implementation NSObject (Introspection)

+ (NSArray<NSString *> *)propertyNames
{
    unsigned count;
    objc_property_t *properties = class_copyPropertyList(self, &count);

    NSMutableArray *result = [NSMutableArray array];

    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [result addObject:name];
    }

    free(properties);

    return result;
}

- (NSArray<NSString *> *)propertyNames {
    return [[self class] propertyNames];
}

@end
