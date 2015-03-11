//
//  AppDelegate.h
//  LookingForInterest
//
//  Created by Wayne on 2/9/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) UIViewController *viewController;
- (void)startLoading;
- (void)startLoadingWithContent:(NSString *)content;
- (void)stopLoading;
@end

