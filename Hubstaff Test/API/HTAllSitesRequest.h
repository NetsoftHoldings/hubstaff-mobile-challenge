//
//  HTAllSitesRequest.h
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import <Foundation/Foundation.h>
#import "HTAllSitesResponseBlock.h"

NS_ASSUME_NONNULL_BEGIN

#warning TODO: AC - make this more generic instead of having one class per request
@interface HTAllSitesRequest : NSURLRequest

- (instancetype)initWithBlock:(HTActiveSitesResultBlock)block;

@property (nonatomic, readonly) HTActiveSitesResultBlock completionBlock;

@end

NS_ASSUME_NONNULL_END
