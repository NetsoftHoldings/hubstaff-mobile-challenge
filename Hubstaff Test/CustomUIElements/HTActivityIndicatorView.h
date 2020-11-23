//
//  HTActivityIndicatorView.h
//  Hubstaff Test
//
//  Created by André Campana on 23.11.20.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface HTActivityIndicatorView : UIActivityIndicatorView

- (void)setAnimating:(BOOL)animating
           withDelay:(NSTimeInterval)delay;

@end

NS_ASSUME_NONNULL_END
