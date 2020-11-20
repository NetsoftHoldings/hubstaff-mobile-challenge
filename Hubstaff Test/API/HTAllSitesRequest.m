//
//  HTAllSitesRequest.m
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import "HTAllSitesRequest.h"


@interface HTAllSitesRequest()

@property (nonatomic, copy) HTActiveSitesResultBlock completionBlock;

@end

@implementation HTAllSitesRequest

- (instancetype)initWithBlock:(HTActiveSitesResultBlock)block
{
    //when making requests more generic, the construction of the URLs can be more modular
    //having the URL here is not so nice, as it is behaves as "magic number"
    //but it's good enough for now
    NSURL *url = [NSURL URLWithString:@"https://run.mocky.io/v3/60fc94d9-db13-4f00-bda4-523f1ba6b4aa"];
    if (self = [self initWithURL:url]) {
        self.completionBlock = block;
    }

    return self;
}

@end
