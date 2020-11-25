//
//  HTAPIClient.m
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#import "HTAPIClient.h"
#import "HTSite.h"


#define kHTAPIClientFirstStatusCodeToAllow 200
#define kHTAPIClientLastStatusCodeToAllow 399


NS_ASSUME_NONNULL_BEGIN

@interface HTAPIClient() <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSOperationQueue *queue;

/**
 There's a potential memory leak here, in situations where the delegate is never removed from the dictionary, since the dictionary lives in the global scope (singleton).
 For now, this is ok, but it would be good to wrap delegates in another object that only held a weak reference to the delegates.
 */
@property (atomic, strong) NSMutableDictionary<NSNumber *, id<HTAPIResponseDelegate>> *taskIdsToDelegates;

- (void)setTaskId:(NSUInteger)taskId
      andDelegate:(id<HTAPIResponseDelegate>)delegate;
- (id<HTAPIResponseDelegate> __nullable)getAndRemoveDelegateForId:(NSUInteger)taskId;
- (id<HTAPIResponseDelegate> __nullable)getDelegateForId:(NSUInteger)taskId;

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _taskIdsToDelegates = [NSMutableDictionary new];
    }
    return self;
}

- (NSURLSession *)urlSession
{
    if (_urlSession == nil) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [config setHTTPAdditionalHeaders:@{@"Content-Type": @"application/json"}];
        config.waitsForConnectivity = YES;
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

#pragma mark - Managing Task Ids

- (void)setTaskId:(NSUInteger)taskId
      andDelegate:(id<HTAPIResponseDelegate>)delegate
{
    @synchronized (_taskIdsToDelegates) {
        [_taskIdsToDelegates setObject:delegate
                                forKey:[NSNumber numberWithUnsignedInteger:taskId]];
    }
}

- (id<HTAPIResponseDelegate> __nullable)getAndRemoveDelegateForId:(NSUInteger)taskId
{
    @synchronized (_taskIdsToDelegates) {
        NSNumber *key = [NSNumber numberWithUnsignedInteger:taskId];
        id<HTAPIResponseDelegate> result = [_taskIdsToDelegates objectForKey:key];
        [_taskIdsToDelegates removeObjectForKey:key];
        return result;
    }
}

- (id<HTAPIResponseDelegate> __nullable)getDelegateForId:(NSUInteger)taskId
{
    @synchronized (_taskIdsToDelegates) {
        NSNumber *key = [NSNumber numberWithUnsignedInteger:taskId];
        return [_taskIdsToDelegates objectForKey:key];
    }
}

#pragma mark - Public Methods

- (void)loadAllSitesWithDelegate:(id<HTAllSitesResponseDelegate>)delegate
{
    __weak typeof(self) weakSelf = self;
    [self.queue addOperationWithBlock:^{
        //when making requests more generic, the construction of the URLs can be more modular
        //having the URL here is not so nice, as it is behaves as "magic number"
        //but it's good enough for now
        NSURL *url = [NSURL URLWithString:@"https://run.mocky.io/v3/60fc94d9-db13-4f00-bda4-523f1ba6b4aa"];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSURLSessionDataTask *task = [weakSelf.urlSession dataTaskWithRequest:request];
        [weakSelf setTaskId:task.taskIdentifier
                andDelegate:delegate];
        delegate.responseData = [NSMutableData new];
        [task resume];
    }];
}

#pragma mark - URL Session Delegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    id<HTAPIResponseDelegate> delegate = [self getDelegateForId:dataTask.taskIdentifier];
    if (delegate == nil) return;
    NSOperationQueue *queue = (delegate.apiResponseQueue) ? delegate.apiResponseQueue : [NSOperationQueue mainQueue];

    if ([dataTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)dataTask.response;
        if (httpResponse.statusCode < kHTAPIClientFirstStatusCodeToAllow ||
            httpResponse.statusCode > kHTAPIClientLastStatusCodeToAllow)
        {
            delegate.responseData = nil;
            [self getAndRemoveDelegateForId:dataTask.taskIdentifier];

            if ([delegate conformsToProtocol:@protocol(HTAllSitesResponseDelegate)]) {
                [queue addOperationWithBlock:^{
#warning TODO: AC - add proper error handling
                    [(id<HTAllSitesResponseDelegate>)delegate didReceiveAllSitesResponse:@[]];
                }];
            }
            return;
        }
    }

    [delegate.responseData appendData:data];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task didCompleteWithError:(NSError * __nullable)error
{
    id<HTAPIResponseDelegate> delegate = [self getAndRemoveDelegateForId:task.taskIdentifier];
    if (delegate == nil) return;
    NSOperationQueue *queue = (delegate.apiResponseQueue) ? delegate.apiResponseQueue : [NSOperationQueue mainQueue];

    if (error) {
#if DEBUG
        NSLog(@"MALFORMED REQUEST ERROR: %@", error);
#endif
        if ([delegate conformsToProtocol:@protocol(HTAllSitesResponseDelegate)]) {
            [queue addOperationWithBlock:^{
                [(id<HTAllSitesResponseDelegate>)delegate didReceiveAllSitesResponse:@[]];
            }];
        }
        return;
    }

#warning TODO: AC - make this more generic
    NSError *jsonError;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:delegate.responseData
                                                             options:0
                                                               error:&jsonError];
#if DEBUG
    if (jsonError) NSLog(@"HTAllSitesRequest error: %@",jsonError);
#warning TODO: AC - review this
    if (ABS(jsonError.code) == 3840) return;
#endif

    if ([delegate conformsToProtocol:@protocol(HTAllSitesResponseDelegate)]) {
#warning TODO: AC - build a more rebust debug logging mechanism, potentially with file and function names
        NSArray<NSDictionary *> *rawSites = response[@"sites"];
        NSArray<HTSite *> *sites = [HTSite sitesWithDictionaries:rawSites];

        [queue addOperationWithBlock:^{
            [(id<HTAllSitesResponseDelegate>)delegate didReceiveAllSitesResponse:sites];
        }];
        return;
    }
}

@end

NS_ASSUME_NONNULL_END
