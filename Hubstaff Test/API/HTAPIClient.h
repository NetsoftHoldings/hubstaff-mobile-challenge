//
//  HTAPIClient.h
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import <Foundation/Foundation.h>


@class HTSite;


NS_ASSUME_NONNULL_BEGIN

@protocol HTAPIResponseDelegate <NSObject>
@property (nonatomic, readonly) NSOperationQueue * __nullable apiResponseQueue;
@property (nonatomic, strong) NSMutableData * __nullable responseData;
@end


@protocol HTAllSitesResponseDelegate <HTAPIResponseDelegate>
- (void)didReceiveAllSitesResponse:(NSArray<HTSite *> *)allSites;
@end


@interface HTAPIClient : NSObject

+ (HTAPIClient *)sharedClient;

- (void)loadAllSitesWithDelegate:(id<HTAllSitesResponseDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
