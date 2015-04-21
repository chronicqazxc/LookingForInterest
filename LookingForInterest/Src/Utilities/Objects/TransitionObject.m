//
//  TransitionObject.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/16/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "TransitionObject.h"

@interface TransitionObject()

@end

@implementation TransitionObject 
#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator{
    return  nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
    return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 1;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *contextView = [transitionContext containerView];
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    
    toVC.view.frame = CGRectMake(0, fromVC.view.bounds.size.height, finalFrame.size.width, finalFrame.size.height);
    [contextView addSubview:toVC.view];
    
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromVC.view.transform = CGAffineTransformMakeScale(.7, .7);
        toVC.view.frame = finalFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
    
}

- (void)animationEnded:(BOOL) transitionCompleted{
    
}

#pragma mark - UIViewControllerInteractiveTransitioning
- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    self.transitionContext=transitionContext;
    
    UIView* inView = [transitionContext containerView];
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    toViewController.view.transform=CGAffineTransformMakeScale(1, 1);
    fromViewController.view.transform=CGAffineTransformMakeScale(1, 1);
    toViewController.view.alpha=0;
    [inView addSubview:toViewController.view];
    CGRect frame=toViewController.view.frame;
    frame.origin.y=inView.bounds.size.height;
    toViewController.view.frame=frame;
    toViewController.view.alpha=1;
}

#pragma mark - UIPercentDrivenInteractiveTransition

- (void)updateInteractiveTransition:(CGFloat)percentComplete{
    
    if (percentComplete<0) {
        percentComplete=0;
    }else if (percentComplete>1){
        percentComplete=1;
    }
    
    UIViewController* toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGFloat scale=1-(1-0.7)*percentComplete;
    
    CGRect frame=toViewController.view.frame;
    frame.origin.y=toViewController.view.bounds.size.height*percentComplete-toViewController.view.bounds.size.height;
    toViewController.view.frame=frame;
    fromViewController.view.transform=CGAffineTransformMakeScale(scale,scale);
    
}

- (void)cancelInteractiveTransitionWithDuration:(CGFloat)duration{
    
    UIViewController* toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         fromViewController.view.transform=CGAffineTransformMakeScale(1, 1);
                         CGRect frame=toViewController.view.frame;
                         frame.origin.y=-toViewController.view.bounds.size.height;
                         toViewController.view.frame=frame;
                     } completion:^(BOOL finished) {
                         [toViewController.view removeFromSuperview];
                         [self.transitionContext cancelInteractiveTransition];
                         [self.transitionContext completeTransition:NO];
                         self.transitionContext=nil;
                     }];
    
    
    [self cancelInteractiveTransition];
}

- (void)finishInteractiveTransitionWithDuration:(CGFloat)duration{
    
    UIViewController* toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         fromViewController.view.transform=CGAffineTransformMakeScale(.7, .7);
                         CGRect frame=toViewController.view.frame;
                         frame.origin.y=0;
                         toViewController.view.frame=frame;
                     } completion:^(BOOL finished) {
                         [fromViewController.view removeFromSuperview];
                         [self.transitionContext completeTransition:YES];
                         self.transitionContext=nil;
                     }];
    
    [self finishInteractiveTransition];
}
@end
