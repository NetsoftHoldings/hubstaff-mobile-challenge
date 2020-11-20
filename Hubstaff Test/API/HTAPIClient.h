//
//  HTAPIClient.h
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import <Foundation/Foundation.h>
#import "HTAllSitesResponseBlock.h"

@class HTSite;

NS_ASSUME_NONNULL_BEGIN

@interface HTAPIClient : NSObject

+ (HTAPIClient *)sharedClient;

- (void)loadAllSitesWithBlock:(HTActiveSitesResultBlock)block;

@end

NS_ASSUME_NONNULL_END
