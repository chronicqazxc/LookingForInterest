//
//  AdoptAnimalTransition.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/16/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AdoptAnimalTransition.h"

@implementation AdoptAnimalTransition

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *contextView = [transitionContext containerView];
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0.5;
    toVC.view.transform = CGAffineTransformMakeScale(.0, .0);
    [contextView addSubview:toVC.view];
    
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromVC.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        toVC.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
//        toVC.view.frame = finalFrame;
        toVC.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}
@end
