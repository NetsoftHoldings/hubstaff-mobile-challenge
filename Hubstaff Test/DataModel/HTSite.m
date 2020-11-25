//
//  HTSite.m
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import "HTSite.h"
#import "NSObject+Introspection.h"
#import <CoreLocation/CLLocation.h>
#import "UIColor+Hex.h"
#import "HTConstants.h"
#import <MapKit/MKAnnotation.h>


NS_ASSUME_NONNULL_BEGIN

NSString * const kHTSiteIdKey = @"id";


@interface HTSite()

@property (nonatomic, strong) NSString *siteId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *radius;
@property (nonatomic, strong) NSString *color;

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSNumber *radiusInMeters;

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
        self.siteId = [dictionary objectForKey:kHTSiteIdKey];
        NSMutableDictionary<NSString *,NSString *> *params = [[NSMutableDictionary alloc] initWithCapacity:dictionary.count];
        for (NSString *key in dictionary.allKeys) {
            if ([key isEqualToString:kHTSiteIdKey]) continue;
            params[key] = dictionary[key];
        }
        [self setValuesForKeysWithDictionary:params];
    }
    return self;
}

#pragma mark - Properties

- (CLLocation *)location {
    if (_location == nil) {
        _location = [[CLLocation alloc] initWithLatitude:self.latitude.doubleValue
                                               longitude:self.longitude.doubleValue];
    }
    return _location;
}

- (NSNumber *)radiusInMeters {
    if (_radiusInMeters == nil) {
        _radiusInMeters = [NSNumber numberWithInt:self.radius.intValue];
    }
    return _radiusInMeters;
}

- (UIColor *)uiColor {
    return [UIColor colorFromHexString:self.color];
}

#pragma mark - Annotation

- (CLLocationCoordinate2D)coordinate {
    return self.location.coordinate;
}

- (NSString * __nullable)title {
    return self.name;
}

- (NSString * __nullable)subtitle {
    return @"";
}

@end

NS_ASSUME_NONNULL_END
