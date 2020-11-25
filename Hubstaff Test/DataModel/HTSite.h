//
//  HTSite.h
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>


@class UIColor, CLLocation;


NS_ASSUME_NONNULL_BEGIN

/// Properties are assumed to be non-nil, so if the back-end response changes, we fail quickly.
@interface HTSite : NSObject <MKAnnotation>

+ (NSArray<HTSite *> *)sitesWithDictionaries:(NSArray<NSDictionary *> *)dictionaries;

@property (nonatomic, readonly) NSString *siteId;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) NSNumber *radiusInMeters;
/// This is marked as non-nil, but may be nil if the hex string is malformed. This is intentional.
@property (nonatomic, readonly) UIColor *uiColor;

- (instancetype)initWithDictionary:(NSDictionary<NSString *, NSString *> *)dictionary;

@end

NS_ASSUME_NONNULL_END
