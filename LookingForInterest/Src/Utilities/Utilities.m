//
//  Utilities.m
//  LookingForInterest
//
//  Created by Wayne on 2/10/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "Utilities.h"
#import <UIKit/UIKit.h>

@implementation Utilities
+ (AppDelegate *)getAppDelegate {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate;
}

+ (void)startLoading {
    [[Utilities getAppDelegate] startLoading];
}

+ (void)stopLoading {
    [[Utilities getAppDelegate] stopLoading];
}
@end
