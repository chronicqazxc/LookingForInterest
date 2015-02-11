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
@end
