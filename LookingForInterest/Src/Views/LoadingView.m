//
//  LoadingView.m
//  LookingForInterest
//
//  Created by Wayne on 2/10/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView()
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation LoadingView
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)presentWithDuration:(CGFloat)duration speed:(CGFloat)speed startOpacity:(CGFloat)startOpacity finishOpacity:(CGFloat)finishOpacity completion:(void (^)(void))completion {
    self.indicatorView.layer.masksToBounds = YES;
    self.indicatorView.layer.cornerRadius = 8.0;
    self.indicatorView.alpha = startOpacity;
    self.backgroundView.alpha = 0.0;
    [UIView animateWithDuration:speed animations:^{
        self.indicatorView.alpha = finishOpacity;
        self.backgroundView.alpha = 0.5;
    } completion:^(BOOL finished) {
    }];
}

- (void)removeWithDuration:(CGFloat)duration speed:(CGFloat)speed startOpacity:(CGFloat)startOpacity finishOpacity:(CGFloat)finishOpacity completion:(void (^)(void))completion {
    self.indicatorView.layer.masksToBounds = YES;
    self.indicatorView.layer.cornerRadius = 8.0;
    self.indicatorView.alpha = startOpacity;
    self.backgroundView.alpha = 0.5;
    [UIView animateWithDuration:speed animations:^{
        self.indicatorView.alpha = finishOpacity;
        self.backgroundView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
