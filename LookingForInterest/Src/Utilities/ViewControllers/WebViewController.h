//
//  WebViewController.h
//  LookingForInterest
//
//  Created by Wayne on 2/21/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum searchType {
    SearchWeb,
    SearchImage
} SearchType;

@interface WebViewController : UIViewController
@property (strong, nonatomic) NSString *keyword;
@property (nonatomic) SearchType searchType;
@end
