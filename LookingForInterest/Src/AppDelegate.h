//
//  AppDelegate.h
//  LookingForInterest
//
//  Created by Wayne on 2/9/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@protocol AppDelegateDelegate
- (void)stopLoadingDone;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) NSString *systemVersion;
@property (strong, nonatomic) NSString *versionNote;
@property (strong, nonatomic) NSString *accessToken;
- (void)startLoading;
- (void)startLoadingWithContent:(NSString *)content;
- (void)stopLoading;
- (void)resendAccessTokenRequest;
@end

