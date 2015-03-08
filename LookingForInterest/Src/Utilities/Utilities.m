//
//  Utilities.m
//  LookingForInterest
//
//  Created by Wayne on 2/10/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "Utilities.h"
#import "AppDelegate.h"
#import "GoogleMapNavigation.h"
#import "HUDView.h"

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

+ (CGSize)getScreenPixel {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
    return screenSize;
}

+ (UIView *)getNibWithName:(NSString *)name {
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:name owner:self options:nil];
    return [nibViews lastObject];
}

+ (void)addShadowToView:(UIView *)view offset:(CGSize)size{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(size.width, size.height);
    view.layer.shadowOpacity = 0.5f;
    view.layer.shadowPath = shadowPath.CGPath;
}

//+ (UIImage *)rotateImage:(UIImage *)image {
//    UIImage *waveUpLight = [UIImage imageNamed:WaveUpLight];
//    UIImage *waveRightLight = [UIImage imageWithCGImage:[waveUpLight CGImage]
//                                                  scale:1.0
//                                            orientation: UIImageOrientationRight];
//    UIImage *waveDownLight = [UIImage imageWithCGImage:[waveUpLight CGImage]
//                                                 scale:1.0
//                                           orientation: UIImageOrientationDown];
//    UIImage *waveLeftLight = [UIImage imageWithCGImage:[waveUpLight CGImage]
//                                                 scale:1.0
//                                           orientation: UIImageOrientationLeft];
//}

+ (UIImage *)rotateImage:(UIImage *)originImage toDirection:(NSInteger)direction withScale:(CGFloat)scale {
    UIImage *modifyImage = nil;
    switch (direction) {
        case DirectionUp:
            modifyImage = [UIImage imageWithCGImage:[originImage CGImage] scale:scale orientation: UIImageOrientationUp];
            break;
        case DirectionLeft:
            modifyImage = [UIImage imageWithCGImage:[originImage CGImage] scale:scale orientation: UIImageOrientationLeft];
            break;
        case DirectionDown:
            modifyImage = [UIImage imageWithCGImage:[originImage CGImage] scale:scale orientation: UIImageOrientationDown];
            break;
        case DirectionRight:
            modifyImage = [UIImage imageWithCGImage:[originImage CGImage] scale:scale orientation: UIImageOrientationRight];
            break;
        case DirectionMirror:
            modifyImage = [UIImage imageWithCGImage:[originImage CGImage] scale:scale orientation: UIImageOrientationUpMirrored];
            break;
        default:
            break;
    }
    if (!modifyImage) {
        modifyImage = originImage;
    }
    return modifyImage;
}

+ (NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

+ (UIAlertController *)normalAlertWithTitle:(NSString *)title message:(NSString *)message withObj:(id)obj andSEL:(SEL)selector byCaller:(UIViewController *)caller{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *webSiteAction = [UIAlertAction actionWithTitle:kWebSiteActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"web site");
        //        [self performSelectorOnMainThread:selector withObject:store waitUntilDone:NO modes:nil];
        if (selector && [caller respondsToSelector:selector]) {
            [caller performSelectorOnMainThread:selector withObject:obj waitUntilDone:NO];
        }
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"click cancel!");
    }];
    
    [alertController addAction:webSiteAction];
    [alertController addAction:okAction];
    
    return alertController;
}

+ (void)launchNavigateWithStore:(Store *)store startLocation:(CLLocationCoordinate2D)startLocation andDirectionsMode:(NSString *)directionsMode{
    [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kGoogleMapType]];
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kGoogleMapType]]) {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:kNavigateURLString(startLocation.latitude, startLocation.longitude, [store.latitude doubleValue], [store.longitude doubleValue], startLocation.latitude, startLocation.longitude, directionsMode,6)]];
    } else {
        NSLog(@"Can't use comgooglemaps://");
    }
}

+ (NSArray *)getMyFavoriteStores {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *stores = [defaults objectForKey:kFavoriteStoresKey];
    if (!stores) {
        stores = [NSArray array];
    }
    return stores;
}

+ (BOOL)isMyFavoriteStore:(Store *)store {
    return [[Utilities getMyFavoriteStores] containsObject:store.storeID];
}

+ (void)addToMyFavoriteStore:(Store *)store {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *stores = [defaults objectForKey:kFavoriteStoresKey];
    if (!stores) {
        stores = [NSArray array];
    }
    NSMutableArray *favoriteStores = [NSMutableArray arrayWithArray:stores];
    [favoriteStores addObject:store.storeID];
    [defaults setObject:favoriteStores forKey:kFavoriteStoresKey];
    [defaults synchronize];
}

+ (void)removeFromMyFavoriteStore:(Store *)store {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *stores = [defaults objectForKey:kFavoriteStoresKey];
    NSMutableArray *favoriteStores = [NSMutableArray arrayWithArray:stores];
    [favoriteStores removeObject:store.storeID];
    [defaults setObject:favoriteStores forKey:kFavoriteStoresKey];
    [defaults synchronize];
}

+ (void)addToMyFavoriteAnimal:(Pet *)pet {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *animals = [defaults objectForKey:kFavoriteAnimalsKey];
    if (!animals) {
        animals = [NSArray array];
    }
    NSMutableArray *favoriteAnimals = [NSMutableArray arrayWithArray:animals];
    [favoriteAnimals addObject:pet.acceptNum];
    [defaults setObject:favoriteAnimals forKey:kFavoriteAnimalsKey];
    [defaults synchronize];
}

+ (void)removeFromMyFavoriteAnimal:(Pet *)pet {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *animals = [defaults objectForKey:kFavoriteAnimalsKey];
    NSMutableArray *favoriteAnimals = [NSMutableArray arrayWithArray:animals];
    [favoriteAnimals removeObject:pet.acceptNum];
    [defaults setObject:favoriteAnimals forKey:kFavoriteAnimalsKey];
    [defaults synchronize];
}

+ (void)addHudViewTo:(UIViewController *)controller withMessage:(NSString *)message {
    HUDView *hudView = (HUDView *)[Utilities getNibWithName:@"HUDView"];
    hudView.frame = CGRectMake(0,0,CGRectGetWidth(controller.view.frame), CGRectGetHeight(controller.view.frame));
    hudView.messageLabel.text = message;
    [controller.view addSubview:hudView];
    [hudView presentWithDuration:0.5 speed:0.5 inView:nil completion:^{
        [hudView removeFromSuperview];
    }];
}

+ (AppDelegate *)appdelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (void)cellPhoneNumber:(NSString *)phoneNumber {
    phoneNumber = [NSString stringWithFormat:@"tel://%@",phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

//NSString* (^thousandSeparatorFormat)(NSNumber*) =
//^(NSNumber *number) {
//    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//    [numberFormatter setGroupingSeparator:@","];
//    [numberFormatter setGroupingSize:3];
//    [numberFormatter setUsesGroupingSeparator:YES];
//    [numberFormatter setDecimalSeparator:@"."];
//    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//    [numberFormatter setMaximumFractionDigits:2];
//    NSString *formatedString = [numberFormatter stringFromNumber:number];
//    [numberFormatter release];
//    return formatedString;
//};
//NSNumber *amountNumber = [NSNumber numberWithInteger:[self.barcodeData.totAmt integerValue]];
//self.payFullPriceLabel.text = [NSString stringWithFormat:@"$%@",thousandSeparatorFormat(amountNumber)];
@end
