//
//  HTBasePresenter.h
//  Hubstaff Test
//
//  Created by André Campana on 20.11.20.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, HTPresenterLoadingState) {
    HTPresenterLoadingStateIdle,
    HTPresenterLoadingStateLoading,
    HTPresenterLoadingStateEmpty
};


NS_ASSUME_NONNULL_BEGIN

@protocol HTBaseView <NSObject>
- (void)didChangeLoadingState:(HTPresenterLoadingState)state;
#warning TODO: AC - make this required
@optional
- (void)presentError:(NSError *)error;
@end


@interface HTBasePresenter : NSObject

@property (nonatomic, weak) id<HTBaseView> __nullable baseView;
@property (nonatomic, readonly) NSOperationQueue *queue;

- (instancetype)initWithBaseView:(id<HTBaseView>)baseView
                        andQueue:(NSOperationQueue * __nullable)queue;

@property (nonatomic, readonly) BOOL isLoading;
@property (atomic, readonly) HTPresenterLoadingState currentLoadingState;

- (void)setLoadingState:(HTPresenterLoadingState)loadingState;

@end

NS_ASSUME_NONNULL_END
