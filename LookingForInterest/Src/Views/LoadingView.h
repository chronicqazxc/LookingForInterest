//
//  LoadingView.h
//  LookingForInterest
//
//  Created by Wayne on 2/10/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView
@property (weak, nonatomic) IBOutlet UIView *indicatorView;
- (void)presentWithDuration:(CGFloat)duration speed:(CGFloat)speed startOpacity:(CGFloat)startOpacity finishOpacity:(CGFloat)finishOpacity completion:(void (^)(void))completion;
- (void)removeWithDuration:(CGFloat)duration speed:(CGFloat)speed startOpacity:(CGFloat)startOpacity finishOpacity:(CGFloat)finishOpacity completion:(void (^)(void))completion;
@end
