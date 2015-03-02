//
//  Utilities.h
//  LookingForInterest
//
//  Created by Wayne on 2/10/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@class AppDelegate;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ClearColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.0]

#define TranColorFromRGBAndAlpha(rgbValue,alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

@interface Utilities : NSObject
+ (AppDelegate *)getAppDelegate;
+ (void)startLoading;
+ (void)stopLoading;
+ (CGSize)getScreenPixel;
+ (UIView *)getNibWithName:(NSString *)name;
+ (void)addShadowToView:(UIView *)view offset:(CGSize)size;
+ (UIImage *)rotateImage:(UIImage *)originImage toDirection:(NSInteger)direction withScale:(CGFloat)scale;
+ (NSMutableArray *)decodePolyLine:(NSMutableString *)encoded;
+ (UIAlertController *)normalAlertWithTitle:(NSString *)title message:(NSString *)message store:(Store *)store withSEL:(SEL)selector byCaller:(UIViewController *)caller;
+ (void)launchNavigateWithStore:(Store *)store startLocation:(CLLocationCoordinate2D)startLocation andDirectionsMode:(NSString *)directionsMode;
+ (NSArray *)getMyFavoriteStores;
+ (void)addToMyFavoriteStore:(Store *)store;
+ (void)removeFromMyFavoriteStore:(Store *)store;
+ (void)addHudViewTo:(UIViewController *)controller withMessage:(NSString *)message;
@end
