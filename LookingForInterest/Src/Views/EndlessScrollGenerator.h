//
//  EndlessScrollGenerator.h
//  ScrollAndZoomingView
//
//  Created by Wayne on 1/21/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol EndlessScrollGeneratorDelegate;

@interface EndlessScrollGenerator : UIScrollView
- (id)initWithScrollViewContainer:(UIViewController <UIScrollViewDelegate, EndlessScrollGeneratorDelegate> *)viewController;
- (NSMutableArray *)setUpData:(NSMutableArray *)data;
- (void)startPaging;
- (void)setUpScrollView:(UIScrollView *)scrollView;
@end

@protocol EndlessScrollGeneratorDelegate <NSObject>
- (void)nextPageNotify;
- (void)previousPageNotify;
@end