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
- (NSString *)getStoryboardID;
- (void)sendInitRequest;
- (void)search;
- (void)back;
@end

@protocol FilterTableViewControllerDelegate <NSObject>

- (void)tableBeTapIn:(NSIndexPath *)indexPath;
- (void)storeBeTapIn:(NSIndexPath *)indexPath;
- (CLLocationCoordinate2D)sendLocationBack;
- (void)reloadMapByStores:(NSArray *)stores withZoomLevel:(NSUInteger)zoom;
- (UIView *)getContentView;
- (CGSize)getContentSize;
- (void)changeTitle:(NSString *)title;
- (void)showOptionsWithStore:(Store *)store;
@end

@interface FilterTableView : UITableView

@end