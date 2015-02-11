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
#import "LookingForInterest.h"

@interface Utilities : NSObject
+ (AppDelegate *)getAppDelegate;
+ (void)startLoading;
+ (void)stopLoading;
+ (CGSize)getScreenPixel;
+ (UIView *)getNibWithName:(NSString *)name;
+ (void)addShadowToView:(UIView *)view offset:(CGSize)size;
+ (UIImage *)rotateImage:(UIImage *)originImage toDirection:(NSInteger)direction withScale:(CGFloat)scale;
@end
