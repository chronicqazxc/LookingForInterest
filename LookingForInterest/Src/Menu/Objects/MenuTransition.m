//
//  MenuTransition.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/16/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "MenuTransition.h"

@interface MenuTransition()
@end

@implementation MenuTransition
#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator{
    if (self.isInteraction) {
        return  self;
    } else {
        return nil;
    }
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
    if (self.isInteraction) {
        return self;
    } else {
        return nil;
    }
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
    
    self.transitionContext = transitionContext;
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *inView = [transitionContext containerView];
    
    toViewController.view.transform = CGAffineTransformMakeScale(1, 1);
    fromViewController.view.transform = CGAffineTransformMakeScale(1, 1);
    [inView addSubview:toViewController.view];
    
    CGRect frame = inView.frame;
    if (self.direction == DirectionDown) {
        frame.origin.y = inView.bounds.size.height;
    } else if (self.direction == DirectionUp) {
        frame.origin.y = -inView.bounds.size.height;
    } else if (self.direction == DirectionRight) {
        frame.origin.x = -inView.bounds.size.width;
    } else if (self.direction == DirectionLeft) {
        frame.origin.x = inView.bounds.size.width;
    }
    toViewController.view.frame = frame;
}

#pragma mark - UIPercentDrivenInteractiveTransition
- (void)updateInteractiveTransition:(CGFloat)percentComplete{
    
    if (percentComplete < 0) {
        percentComplete = 0;
    } else if (percentComplete > 1){
        percentComplete = 1;
    }
    
    UIViewController *toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGRect toFrame = toViewController.view.frame;
    CGRect fromFrame = fromViewController.view.frame;
    if (self.direction == DirectionDown) {
        
        toFrame.origin.y = toViewController.view.bounds.size.height * percentComplete - toViewController.view.bounds.size.height;
        fromFrame.origin.y = toViewController.view.bounds.size.height * percentComplete;
        
    } else if (self.direction == DirectionUp) {
        
        toFrame.origin.y = toViewController.view.bounds.size.height - toViewController.view.bounds.size.height * percentComplete;
        fromFrame.origin.y = -(toViewController.view.bounds.size.height * percentComplete);
        
    } else if (self.direction == DirectionRight) {
        
        toFrame.origin.x = toViewController.view.bounds.size.width * percentComplete - toViewController.view.bounds.size.width;
        fromFrame.origin.x = toViewController.view.bounds.size.width * percentComplete;
        
    } else if (self.direction == DirectionLeft) {
        
        toFrame.origin.x = toViewController.view.bounds.size.width - toViewController.view.bounds.size.width * percentComplete;
        fromFrame.origin.x = -toViewController.view.bounds.size.width * percentComplete;
        
    }
    
    toViewController.view.frame = toFrame;
    fromViewController.view.frame = fromFrame;
}

- (void)cancelInteractiveTransitionWithDuration:(CGFloat)duration{
    UIViewController* toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = toViewController.view.frame;
                         if (self.direction == DirectionDown) {
                             frame.origin.y = -toViewController.view.bounds.size.height;
                         } else if (self.direction == DirectionUp) {
                             frame.origin.y = toViewController.view.bounds.size.height;
                         } else if (self.direction == DirectionRight) {
                             frame.origin.x = -toViewController.view.bounds.size.width;
                         } else if (self.direction == DirectionLeft) {
                             frame.origin.x = toViewController.view.bounds.size.width;
                         }
                         toViewController.view.frame = frame;
                         fromViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(fromViewController.view.frame), CGRectGetHeight(fromViewController.view.frame));
                     } completion:^(BOOL finished) {
                         [toViewController.view removeFromSuperview];
                         [self.transitionContext cancelInteractiveTransition];
                         [self.transitionContext completeTransition:NO];
                         self.transitionContext = nil;
                     }];
    
    
    [self cancelInteractiveTransition];
}

- (void)finishInteractiveTransitionWithDuration:(CGFloat)duration{
    UIViewController *toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect toFrame = toViewController.view.frame;
                         CGRect fromFrame = fromViewController.view.frame;
                         if (self.direction == DirectionDown) {
                             toFrame.origin.y = 0;
                             fromFrame.origin.y = toFrame.size.height;
                         } else if (self.direction == DirectionUp) {
                             toFrame.origin.y = 0;
                             fromFrame.origin.y = -toFrame.size.height;
                         } else if (self.direction == DirectionLeft) {
                             toFrame.origin.x = 0;
                             fromFrame.origin.x = -toFrame.size.width;
                         } else if (self.direction == DirectionRight) {
                             toFrame.origin.x = 0;
                             fromFrame.origin.x = toFrame.size.width;
                         }
                         toViewController.view.frame = toFrame;
                         fromViewController.view.frame = fromFrame;
                     } completion:^(BOOL finished) {
                         [fromViewController.view removeFromSuperview];
                         [self.transitionContext completeTransition:YES];
                         self.transitionContext = nil;
                     }];
    
    [self finishInteractiveTransition];
}
@end
