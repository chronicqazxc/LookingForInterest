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
#import <QuartzCore/QuartzCore.h>

@implementation Utilities
+ (AppDelegate *)getAppDelegate {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate;
}

+ (void)startLoading {
    [[Utilities getAppDelegate] startLoading];
}

+ (void)startLoadingWithContent:(NSString *)content {
    [[Utilities getAppDelegate] startLoadingWithContent:content];
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

+ (void)launchNavigateWithStore:(Store *)store startLocation:(CLLocationCoordinate2D)startLocation andDirectionsMode:(NSString *)directionsMode controller:(UIViewController *)controller {
    [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kGoogleMapType]];
    
    NSString *message = @"";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *confirmAction = nil;
    
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kGoogleMapType]]) {
        
        message = @"本功能將使用GoogleMaps導航，是否開啟GoogleMaps?";
        confirmAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString:kNavigateURLString(startLocation.latitude, startLocation.longitude, [store.latitude doubleValue], [store.longitude doubleValue], startLocation.latitude, startLocation.longitude, directionsMode,6)]];
        }];
    } else {
        message = @"您未安裝GoogleMaps，是否連結至AppStore下載?";
        cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        confirmAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *googleMapsiTunesLink = kGoogleMapsAppURL;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsiTunesLink]];
        }];
    }
    alertController.message = message;
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [controller presentViewController:alertController animated:YES completion:nil];
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

+ (NSArray *)getMyFavoriteAnimalsDecoded {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *animals = [defaults objectForKey:kFavoriteAnimalsKey];
    if (!animals) {
        animals = [NSArray array];
    } else {
        NSMutableArray *decodedAnimals = [NSMutableArray array];
        for (NSData *encodedAnimal in animals) {
            Pet *pet = [NSKeyedUnarchiver unarchiveObjectWithData:encodedAnimal];
            [decodedAnimals addObject:pet];
        }
        animals = [NSArray arrayWithArray:decodedAnimals];
    }
    return animals;
}

+ (NSArray *)getMyFavoriteAnimalsEncoded {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *animals = [defaults objectForKey:kFavoriteAnimalsKey];
    if (!animals) {
        animals = [NSArray array];
    }
    return animals;
}

+ (BOOL)isMyFavoriteAnimalByPet:(Pet *)selectedPet {
    NSArray *animals = [Utilities getMyFavoriteAnimalsDecoded];
    BOOL isMyFavorite = NO;
    for (Pet *pet in animals) {
        if ([pet.petID isEqualToNumber:selectedPet.petID]) {
            isMyFavorite = YES;
            break;
        }
    }
    return isMyFavorite;
}

+ (void)addToMyFavoriteAnimal:(Pet *)pet {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *animals = [Utilities getMyFavoriteAnimalsEncoded];
    if (!animals) {
        animals = [NSArray array];
    }
    
    NSData *encodedAnimal = [NSKeyedArchiver archivedDataWithRootObject:pet];
    
    NSMutableArray *favoriteAnimals = [NSMutableArray arrayWithArray:animals];
    [favoriteAnimals addObject:encodedAnimal];
    [defaults setObject:favoriteAnimals forKey:kFavoriteAnimalsKey];
    [defaults synchronize];
}

+ (void)removeFromMyFavoriteAnimal:(Pet *)pet {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *animals = [Utilities getMyFavoriteAnimalsDecoded];
    NSMutableArray *favoriteAnimals = [NSMutableArray arrayWithArray:animals];
    for (Pet *animal in favoriteAnimals) {
        if ([animal.petID isEqualToNumber:pet.petID]) {
            [favoriteAnimals removeObject:animal];
            break;
        }
    }
    NSMutableArray *decodeAnimals = [NSMutableArray array];
    for (Pet *animal in favoriteAnimals) {
        NSData *encodedAnimal = [NSKeyedArchiver archivedDataWithRootObject:animal];
        [decodeAnimals addObject:encodedAnimal];
    }
    [defaults setObject:decodeAnimals forKey:kFavoriteAnimalsKey];
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

+ (void)callPhoneNumber:(NSString *)phoneNumber {
    phoneNumber = [NSString stringWithFormat:@"tel://%@",phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

+ (UIView *)glossyView:(UIView *)view {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [view.layer insertSublayer:gradient atIndex:0];
    return view;
}

+ (void)shareToLineWithImage:(UIImage *)image{
    NSString *urlString = @"line://msg/";
    
    UIPasteboard *pasteboard;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        pasteboard = [UIPasteboard generalPasteboard];
    } else {
        pasteboard = [UIPasteboard pasteboardWithUniqueName];
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    [pasteboard setData:imageData forPasteboardType:@"public.png"];
    urlString = [NSString stringWithFormat:@"%@image/%@",urlString, pasteboard.name];
    
    NSURL *appURL = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL: appURL]) {
        [[UIApplication sharedApplication] openURL: appURL];
    } else {
        NSURL *itunesURL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id443904275"];
        [[UIApplication sharedApplication] openURL:itunesURL];
    }
}

+ (void)shareToLineWithContent:(NSString *)content url:(NSString *)url {
    NSString *urlString = @"line://msg/";
        NSString *key = [NSString stringWithFormat:@"%@%@",content,url];
        key = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        urlString = [NSString stringWithFormat:@"%@text/%@",urlString,key];
    NSURL *appURL = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL: appURL]) {
        [[UIApplication sharedApplication] openURL: appURL];
    } else {
        NSURL *itunesURL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id443904275"];
        [[UIApplication sharedApplication] openURL:itunesURL];
    }
}

+ (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
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
