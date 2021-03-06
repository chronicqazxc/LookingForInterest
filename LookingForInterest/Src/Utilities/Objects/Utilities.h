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

#define degreesToRadians(x) (M_PI * x / 180.0)

@interface Utilities : NSObject
+ (AppDelegate *)getAppDelegate;
+ (void)startLoading;
+ (void)startLoadingWithContent:(NSString *)content;
+ (void)stopLoading;
+ (CGSize)getScreenPixel;
+ (CGSize)getScreenSize;
+ (UIView *)getNibWithName:(NSString *)name;
+ (void)addShadowToView:(UIView *)view offset:(CGSize)size;
+ (UIImage *)rotateImage:(UIImage *)originImage toDirection:(NSInteger)direction withScale:(CGFloat)scale;
+ (NSMutableArray *)decodePolyLine:(NSMutableString *)encoded;
+ (UIAlertController *)normalAlertWithTitle:(NSString *)title message:(NSString *)message withObj:(id)obj andSEL:(SEL)selector byCaller:(UIViewController *)caller;
+ (void)launchNavigateWithStore:(Store *)store startLocation:(CLLocationCoordinate2D)startLocation andDirectionsMode:(NSString *)directionsMode controller:(UIViewController *)controller;
+ (NSArray *)getMyFavoriteStores;
+ (BOOL)isMyFavoriteStore:(Store *)store;
+ (void)addToMyFavoriteStore:(Store *)store;
+ (void)removeFromMyFavoriteStore:(Store *)store;
+ (NSArray *)getMyFavoriteAnimalsEncoded;
+ (NSArray *)getMyFavoriteAnimalsDecoded;
+ (BOOL)isMyFavoriteAnimalByPet:(Pet *)selectedPet;
+ (void)addToMyFavoriteAnimal:(Pet *)pet;
+ (void)removeFromMyFavoriteAnimal:(Pet *)pet;
+ (void)addHudViewTo:(UIViewController *)controller withMessage:(NSString *)message;
+ (AppDelegate *)appdelegate;
+ (void)callPhoneNumber:(NSString *)phoneNumber;
+ (UIView *)glossyView:(UIView *)view;
+ (void)shareToLineWithContent:(NSString *)content url:(NSString *)url;
+ (void)shareToLineWithImage:(UIImage *)image;
+ (UIImage *)imageWithView:(UIView *)view;
+ (BOOL)getNeverShowManulMenuWithKey:(NSString *)key;
+ (void)setNeverShowManulMenuWithKey:(NSString *)key;
@end
