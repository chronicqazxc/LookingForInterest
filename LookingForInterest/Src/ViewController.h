//
//  ViewController.h
//  LookingForInterest
//
//  Created by Wayne on 2/9/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TableLoadPreviousPage, TableLoadNextPage;

@interface ViewController : UIViewController
@property (strong, nonatomic) TableLoadPreviousPage *loadPreviousPageView;
@property (strong, nonatomic) TableLoadNextPage *loadNextPageView;
@end

