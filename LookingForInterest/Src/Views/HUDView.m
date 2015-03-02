//
//  HUDView.m
//  LookingForInterest
//
//  Created by Wayne on 3/2/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "HUDView.h"
@interface HUDView()
@property (weak, nonatomic) IBOutlet UIView *messageContainer;
@end

@implementation HUDView
- (void)presentWithDuration:(CGFloat)duration speed:(CGFloat)speed inView:(UIView *)view completion:(void (^)(void))completion {
    self.messageContainer.layer.cornerRadius = 10.0;
    self.messageContainer.alpha = 0.0;
    [UIView animateWithDuration:speed animations:^{
        self.messageContainer.alpha = 0.8;
    } completion:^(BOOL finished) {
        if (finished) [self fadeAfter:duration speed:speed completion:completion];
    }];
}

- (void)fadeAfter:(CGFloat)duration speed:(CGFloat)speed completion:(void (^)(void))completion {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:speed animations:^{
        self.messageContainer.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                if (completion != nil) completion();
            }
        }];
    });
}
@end
