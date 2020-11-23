//
//  HTSite.m
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import "HTSite.h"
#import "NSObject+Introspection.h"
#import <CoreLocation/CoreLocation.h>
#import "UIColor+Hex.h"
#import "HTConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTSite()

@property (nonatomic, strong) NSString *siteId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *radius;
@property (nonatomic, strong) NSString *color;

- (instancetype)initWithDictionary:(NSDictionary<NSString *,NSString *> *)dictionary
                  andPropertyNames:(NSArray<NSString *> *)propertyNames;

@end


@implementation HTSite

#pragma mark - Setup
+ (NSArray<HTSite *> *)sitesWithDictionaries:(NSArray<NSDictionary *> *)dictionaries
{
    NSMutableArray<HTSite *> *result = [[NSMutableArray alloc] initWithCapacity:dictionaries.count];
    NSArray *properties = [self propertyNames];
    for (NSDictionary *dictionary in dictionaries) {
        [result addObject:[[HTSite alloc] initWithDictionary:dictionary
                                            andPropertyNames:properties]];
    }
    return [result copy];
}

- (instancetype)initWithDictionary:(NSDictionary<NSString *,NSString *> *)dictionary {
    self = [self initWithDictionary:dictionary
                   andPropertyNames:[self propertyNames]];
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary<NSString *,NSString *> *)dictionary
                  andPropertyNames:(NSArray<NSString *> *)propertyNames
{
    if (self = [super init]) {
        //special case for id since it's a reserved word
        self.siteId = [dictionary objectForKey:@"id"];
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

#pragma mark - Properties

- (CLLocation *)location {
    #warning TODO: AC - memoize lat and long as numbers
    return [[CLLocation alloc] initWithLatitude:self.latitude.doubleValue
                                      longitude:self.longitude.doubleValue];
}

- (NSNumber *)radiusInMeters {
    #warning TODO: AC - check with the back-end if this is always an integer
    return [NSNumber numberWithInt:self.radius.intValue];
}

- (UIColor *)uiColor {
    return [UIColor colorFromHexString:self.color];
}

@end

NS_ASSUME_NONNULL_END
