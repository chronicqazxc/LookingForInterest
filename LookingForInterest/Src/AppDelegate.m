//
//  AppDelegate.m
//  LookingForInterest
//
//  Created by Wayne on 2/9/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ViewController.h"
#import "LoadingView.h"
#import "MenuViewController.h"

#define kGoogleAPIKey @"AIzaSyB0XF79VtFRkTn8N2CQqXMxeVSP82MiIh8"
#define kLoadingViewTag 12345
#define kNavigationBarHeight 64

@interface AppDelegate ()
@property (nonatomic) BOOL isConnecting;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.viewController = nil;
    [GMSServices provideAPIKey:kGoogleAPIKey];
    [FBLoginView class];
    self.isConnecting = NO;
    [self getAccessToken];
    return YES;
}

- (void)resendAccessTokenRequest {
    if (!self.isConnecting) {
       [self getAccessToken];
    }
}

- (void)getAccessToken {
    self.isConnecting = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURL *url = [NSURL URLWithString:kLookingForInterestHerokuURL(kGetAccessToken)];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil) {
            NSError *error = nil;
            NSArray *datas = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error == nil) {
                NSString *accessToken = [datas firstObject];
                self.accessToken = accessToken;
                [self getIOSSystemVersion];
            } else {
                NSLog(@"解析token錯誤");
                
                [self performSelectorOnMainThread:@selector(parseErrorObject:)
                                       withObject:@{@"title":@"解析token錯誤",
                                                    @"message":[error localizedDescription],
                                                    @"selector":NSStringFromSelector(@selector(getAccessToken))}
                                    waitUntilDone:NO];
                
                [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                self.isConnecting = NO;
            }
        } else {
            NSLog(@"取得token錯誤");
            [self performSelectorOnMainThread:@selector(parseErrorObject:)
                                   withObject:@{@"title":@"取得token錯誤",
                                                @"message":[connectionError localizedDescription],
                                                @"selector":NSStringFromSelector(@selector(getAccessToken))}
                                waitUntilDone:NO];
            
            [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            self.isConnecting = NO;
        }
    }];
}

- (void)getIOSSystemVersion {
    self.isConnecting = YES;
    
    NSURL *url = [NSURL URLWithString:kLookingForInterestHerokuURL(kThingAboutAnimalsVersionURL)];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Token token=%@",self.accessToken] forHTTPHeaderField:@"Authorization"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil) {
            NSError *error = nil;
            NSArray *parsedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSDictionary *dataDic = [parsedData firstObject];
            if (error == nil) {
                self.systemVersion = [dataDic objectForKey:@"system_version"];
                self.versionNote = [dataDic objectForKey:@"version_note"];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                if ([self.viewController isKindOfClass:[MenuViewController class]]) {
                    [((MenuViewController *)self.viewController) checkSystemVersion];
                }
            } else {
                NSLog(@"解析版本號錯誤");
                [self performSelectorOnMainThread:@selector(parseErrorObject:)
                                       withObject:@{@"title":@"解析版本號錯誤",
                                                    @"message":[error localizedDescription],
                                                    @"selector":NSStringFromSelector(@selector(getIOSSystemVersion))}
                                    waitUntilDone:NO];
            }
        } else {
            NSLog(@"取得版本號錯誤");
            [self performSelectorOnMainThread:@selector(parseErrorObject:)
                                   withObject:@{@"title":@"取得版本號錯誤",
                                                @"message":[connectionError localizedDescription],
                                                @"selector":NSStringFromSelector(@selector(getIOSSystemVersion))}
                                waitUntilDone:NO];
        }
        [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.isConnecting = NO;
    }];
}

- (void)parseErrorObject:(NSDictionary *)dic {
    NSString *title = [dic objectForKey:@"title"]?[dic objectForKey:@"title"]:@"";
    NSString *message = [dic objectForKey:@"message"]?[dic objectForKey:@"message"]:@"";
    SEL selector = [dic objectForKey:@"selector"]?NSSelectorFromString([dic objectForKey:@"selector"]):@selector(getAccessToken);
    [self errorHandelWithTitle:title message:message selector:selector];
}

- (void)errorHandelWithTitle:(NSString *)title message:(NSString *)message selector:(SEL)selector {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重試" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSelectorOnMainThread:selector withObject:nil waitUntilDone:NO];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:retryAction];
    [alertController addAction:cancelAction];
    [self.viewController presentViewController:alertController animated:YES completion:nil];
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
    // Logs 'install' and 'app activate' App Events.
    [FBAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation NS_AVAILABLE_IOS(4_2) {
    // attempt to extract a token from the url
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
        NSLog(@"Unhandled deep link: %@", url);
        // Here goes the code to handle the links
        // Use the links to show a relevant view of your app to the user
    }];
    
    return urlWasHandled;
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

- (void)startLoadingWithContent:(NSString *)content {
    [self stopLoading];
    if (self.viewController) {
        LoadingView *loadingView = (LoadingView *)[Utilities getNibWithName:@"LoadingView"];
        loadingView.frame = CGRectMake(0,0,CGRectGetWidth(self.viewController.view.frame), CGRectGetHeight(self.viewController.view.frame));
        loadingView.tag = kLoadingViewTag;
        loadingView.loadingLabel.text = content;
        [self.viewController.view addSubview:loadingView];
        [loadingView presentWithDuration:1.0 speed:1.0 startOpacity:0.0 finishOpacity:0.8 completion:nil];
    }
}

- (void)stopLoading {
    if (self.viewController) {
        for (UIView *view in [self.viewController.view subviews]) {
            if (view.tag == kLoadingViewTag || [view isKindOfClass:[LoadingView class]]) {
                [(LoadingView *)view removeWithDuration:1.0 speed:0.1 startOpacity:0.8 finishOpacity:0.0 completion:nil];
                break;
            }
        }
    }
}
@end
