//
//  AppDelegate.m
//  LookingForInterest
//
//  Created by Wayne on 2/9/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Utilities.h"
#import "ViewController.h"

#define kGoogleAPIKey @"AIzaSyB0XF79VtFRkTn8N2CQqXMxeVSP82MiIh8"
#define kLoadingViewTag 12345
#define kNavigationBarHeight 64

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
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
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:self options:nil];
    LoadingView *loadingView = [nibViews firstObject];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    loadingView.frame = CGRectMake(0,0,CGRectGetWidth(screenRect), CGRectGetHeight(screenRect));
    loadingView.indicatorView.layer.masksToBounds = YES;
    loadingView.indicatorView.layer.cornerRadius = 5.0;
    loadingView.tag = kLoadingViewTag;
    [self.window addSubview:loadingView];
}

- (void)stopLoading {
    for (UIView *view in [self.window subviews]) {
        if (view.tag == kLoadingViewTag) {
            [view removeFromSuperview];
            break;
        }
    }
}

@end
