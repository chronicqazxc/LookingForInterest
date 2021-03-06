//
//  AnimalHospitalTransition.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/16/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AnimalHospitalTransition.h"
#import "AnimalHospitalNavigationController.h"

@implementation AnimalHospitalTransition
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if ([fromVC isKindOfClass:[AnimalHospitalNavigationController class]]) {
        [self leaveFromAdoptAnimalViewControllerWithContext:transitionContext];
        
    } else {
        
        [self goToAdoptAnimalViewControllerWithContext:transitionContext];
    }
    
}

- (void)leaveFromAdoptAnimalViewControllerWithContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *contextView = [transitionContext containerView];
    
    [contextView addSubview:toVC.view];
    [contextView sendSubviewToBack:toVC.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromVC.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)goToAdoptAnimalViewControllerWithContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *contextView = [transitionContext containerView];
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    
    toVC.view.frame = CGRectMake(0, fromVC.view.bounds.size.height, finalFrame.size.width, finalFrame.size.height);
    [contextView addSubview:toVC.view];
    
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //        fromVC.view.transform = CGAffineTransformMakeScale(.7, .7);
        toVC.view.frame = finalFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}
@end
