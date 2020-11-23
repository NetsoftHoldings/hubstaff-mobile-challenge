//
//  HTAllSitesRequest.m
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import "HTAllSitesRequest.h"


NS_ASSUME_NONNULL_BEGIN

@interface HTAllSitesRequest()

@property (nonatomic, copy) HTActiveSitesResultBlock completionBlock;
@property (nonatomic, strong) NSOperationQueue *responseQueue;

@end

@implementation HTAllSitesRequest

- (instancetype)initWithBlock:(HTActiveSitesResultBlock)block
             andResponseQueue:(NSOperationQueue *)queue
{
    //when making requests more generic, the construction of the URLs can be more modular
    //having the URL here is not so nice, as it is behaves as "magic number"
    //but it's good enough for now
    NSURL *url = [NSURL URLWithString:@"https://run.mocky.io/v3/60fc94d9-db13-4f00-bda4-523f1ba6b4aa"];
    if (self = [self initWithURL:url]) {
        self.completionBlock = block;
        self.responseQueue = queue;
    }

    return self;
}

@end

NS_ASSUME_NONNULL_END
