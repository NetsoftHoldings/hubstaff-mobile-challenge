//
//  HTAPIClient.m
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import "HTAPIClient.h"
#import "HTAllSitesRequest.h"
#import "HTSite.h"


@interface HTAPIClient() <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSOperationQueue *queue;

@end


@implementation HTAPIClient

#pragma mark - Setup

+ (HTAPIClient *)sharedClient
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSURLSession *)urlSession
{
    if (_urlSession == nil) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.bellapplab.Hubstaff-Test"];
        [config setHTTPAdditionalHeaders:@{@"Content-Type": @"application/json"}];
        _urlSession = [NSURLSession sessionWithConfiguration:config
                                                    delegate:self
                                               delegateQueue:self.queue];
    }
    return _urlSession;
}

- (NSOperationQueue *)queue
{
    if (_queue == nil) {
        _queue = [NSOperationQueue new];
        _queue.name = @"HTAPIClient.queue";
    }
    return _queue;
}

#pragma mark - Public Methods

- (void)loadAllSitesWithBlock:(HTActiveSitesResultBlock)block
{
    __weak typeof(self) weakSelf = self;
    [self.queue addOperationWithBlock:^{
        [[weakSelf.urlSession dataTaskWithRequest:[[HTAllSitesRequest alloc] initWithBlock:block]] resume];
    }];
}

#pragma mark - URL Session Delegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if ([dataTask.originalRequest isMemberOfClass:[HTAllSitesRequest class]]) {
        #warning TODO: make this more generic
        NSError *jsonError;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:&jsonError];
        #warning TODO: build a more rebust debug logging mechanism, potentially with file and function names
        #warning TODO: add proper error handling
        #if DEBUG
        if (jsonError) NSLog(@"HTAllSitesRequest error: %@",jsonError);
        #endif
        NSArray<NSDictionary *> *rawSites = response[@"sites"];
        NSArray<HTSite *> *sites = [HTSite sitesWithDictionaries:rawSites];

        HTActiveSitesResultBlock block = [(HTAllSitesRequest *)dataTask.originalRequest completionBlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(sites);
        });
    }
}

@end
