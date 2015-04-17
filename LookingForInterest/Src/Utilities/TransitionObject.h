//
//  TransitionObject.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/16/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransitionObject : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, readwrite) id <UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic) BOOL isInteraction;
@property (nonatomic) Direction direction;

- (void)cancelInteractiveTransitionWithDuration:(CGFloat)duration;
- (void)finishInteractiveTransitionWithDuration:(CGFloat)duration;

@end
