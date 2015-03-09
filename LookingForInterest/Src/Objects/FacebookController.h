//
//  FacebookController.h
//  LookingForInterest
//
//  Created by Wayne on 3/4/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol FacebookControllerDelegate;

@interface FacebookController : NSObject
@property (strong, nonatomic) UIViewController <FacebookControllerDelegate> *delegate;

- (void)shareWithLink:(NSString *)link name:(NSString *)name caption:(NSString *)caption description:(NSString *)description picture:(NSString *)picture message:(NSString *)message;
@end

@protocol FacebookControllerDelegate
- (void)showErrorMessage:(NSString *)errorMessage withTitle:(NSString *)errorTitle;
- (void)publishSuccess:(NSString *)postID;
@end
