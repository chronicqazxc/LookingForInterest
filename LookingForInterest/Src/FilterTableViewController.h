//
//  FilterTableViewController.h
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LookingForInterest.h"

@protocol FilterTableViewControllerDelegate;

@class FilterTableView, Store;

@interface FilterTableViewController : UITableViewController
@property (strong, nonatomic) NSString *majorDetail;
@property (strong, nonatomic) NSString *minorDetail;
@property (strong, nonatomic) NSString *nameDetail;
@property (strong, nonatomic) NSString *rangeDetail;
@property (nonatomic) FilterType filterType;
@property (assign, nonatomic) id <FilterTableViewControllerDelegate>delegate;
@property (strong, nonatomic) FilterTableView *filterTableView;
@property (strong, nonatomic) UIViewController *notifyReceiver;
@property (strong, nonatomic) NSIndexPath *selectedStoreIndexPath;
@property (strong, nonatomic) NSString *accessToken;
- (NSString *)getStoryboardID;
- (void)sendAccessTokenRequest;
- (void)sendInitRequest;
- (void)search;
- (void)back;
- (void)resetPage;
@end

@protocol FilterTableViewControllerDelegate <NSObject>
- (void)setAccessTokenValue:(NSString *)accessToken;
- (void)tableBeTapIn:(NSIndexPath *)indexPath withMenuSearchType:(MenuSearchType)menuSearchType;
- (void)storeBeTapIn:(NSIndexPath *)indexPath withDetail:(Detail *)detail;
- (CLLocationCoordinate2D)sendLocationBack;
- (void)reloadMapByStores:(NSArray *)stores withZoomLevel:(NSUInteger)zoom pageController:(PageController *)pageController andMenu:(Menu *)menu;
- (UIView *)getContentView;
- (CGSize)getContentSize;
- (void)changeTitle:(NSString *)title;
- (void)showOptionsWithStore:(Store *)store;
- (void)showNavigationWithStore:(Store *)store;
- (void)loadPreviousPage:(PageController *)pageController;
- (void)loadNextPage:(PageController *)pageController;
@end

@interface FilterTableView : UITableView

@end