//
//  AppDelegate.m
//  LookingForInterest
//
//  Created by Wayne on 2/9/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import "ViewController.h"
#import "LoadingView.h"

#define kGoogleAPIKey @"AIzaSyB0XF79VtFRkTn8N2CQqXMxeVSP82MiIh8"
#define kLoadingViewTag 12345
#define kNavigationBarHeight 64

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.viewController = nil;
    [GMSServices provideAPIKey:kGoogleAPIKey];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)startLoading {
    [self stopLoading];
    if (self.viewController) {
        LoadingView *loadingView = (LoadingView *)[Utilities getNibWithName:@"LoadingView"];
        loadingView.frame = CGRectMake(0,0,CGRectGetWidth(self.viewController.view.frame), CGRectGetHeight(self.viewController.view.frame));
        loadingView.tag = kLoadingViewTag;
        [self.viewController.view addSubview:loadingView];
        [loadingView presentWithDuration:1.0 speed:1.0 startOpacity:0.0 finishOpacity:0.8 completion:nil];
    }
}

- (void)stopLoading {
    if (self.viewController) {
        for (UIView *view in [self.viewController.view subviews]) {
            if (view.tag == kLoadingViewTag) {
                [(LoadingView *)view removeWithDuration:1.0 speed:1.0 startOpacity:0.8 finishOpacity:0.0 completion:^{
                }];
                break;
            }
        }
    }
}

@end
