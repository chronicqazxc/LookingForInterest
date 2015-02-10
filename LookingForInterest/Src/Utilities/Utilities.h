//
//  Utilities.h
//  LookingForInterest
//
//  Created by Wayne on 2/10/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "LoadingView.h"

@interface Utilities : NSObject
+ (AppDelegate *)getAppDelegate;
+ (void)startLoading;
+ (void)stopLoading;
+ (CGSize)getScreenPixel;
@end
