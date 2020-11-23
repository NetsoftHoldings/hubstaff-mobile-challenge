//
//  HTActivityIndicatorView.m
//  Hubstaff Test
//
//  Created by André Campana on 23.11.20.
//

#import "HTActivityIndicatorView.h"


@interface HTActivityIndicatorView ()

@property (nonatomic, weak) NSTimer * __nullable timer;

@end


@implementation HTActivityIndicatorView

- (void)setTimer:(NSTimer *)timer
{
    @synchronized (_timer) {
        [_timer invalidate];
        _timer = timer;
    }
}

- (void)setAnimating:(BOOL)animating
           withDelay:(NSTimeInterval)delay
{
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                 repeats:NO
                                                   block:^(NSTimer * _Nonnull timer)
    {
        if (animating) {
            [weakSelf startAnimating];
        } else {
            [weakSelf stopAnimating];
        }
    }];
}

@end
