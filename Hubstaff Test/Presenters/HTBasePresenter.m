//
//  HTBasePresenter.m
//  Hubstaff Test
//
//  Created by André Campana on 20.11.20.
//

#import "HTBasePresenter.h"


NS_ASSUME_NONNULL_BEGIN

@interface HTBasePresenter ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (atomic, assign) HTPresenterLoadingState currentLoadingState;
@property (atomic, assign) NSUInteger loadingCount;

@end


@implementation HTBasePresenter

#pragma mark - Setup
- (instancetype)init
{
    if (self = [super init]) {
        self.loadingCount = 0;
        self.currentLoadingState = HTPresenterLoadingStateEmpty;
    }
    return self;
}

- (instancetype)initWithBaseView:(id<HTBaseView>)baseView
                        andQueue:(NSOperationQueue * _Nullable)queue
{
    if (self = [self init]) {
        _baseView = baseView;
        _queue = queue;
    }
    return self;
}

- (NSOperationQueue *)queue
{
    if (_queue == nil) {
        _queue = [NSOperationQueue new];
        _queue.name = @"HTBasePresenterQueue";
        _queue.maxConcurrentOperationCount = 1;
        _queue.qualityOfService = NSQualityOfServiceUserInitiated;
    }
    return _queue;
}

#pragma mark - Computed Properties

- (BOOL)isLoading {
    return self.currentLoadingState == HTPresenterLoadingStateLoading;
}

#pragma mark - Loading

- (void)setLoadingState:(HTPresenterLoadingState)loadingState
{
    @synchronized (self) {
        switch (loadingState) {
            case HTPresenterLoadingStateLoading:
            {
                NSUInteger previousCount = self.loadingCount;
                self.loadingCount++;
                if (previousCount == 0) {
                    self.currentLoadingState = HTPresenterLoadingStateLoading;
                    __weak typeof(self) weakSelf = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.baseView didChangeLoadingState:loadingState];
                    });
                }
            }
                break;
            case HTPresenterLoadingStateIdle:
            case HTPresenterLoadingStateEmpty:
            {
                NSUInteger previousCount = self.loadingCount;
                if (previousCount >= 1) {
                    self.loadingCount--;
                }
                if (previousCount == 1) {
                    HTPresenterLoadingState previousState = self.currentLoadingState;
                    self.currentLoadingState = loadingState;
                    if (previousState != loadingState) {
                        __weak typeof(self) weakSelf = self;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.baseView didChangeLoadingState:loadingState];
                        });
                    }
                }
            }
                break;
            default: break;
        }
    }
}

@end

NS_ASSUME_NONNULL_END
