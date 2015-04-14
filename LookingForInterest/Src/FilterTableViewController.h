//
//  FilterTableViewController.h
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>

@protocol FilterTableViewControllerDelegate;

@class FilterTableView, Store;

@interface FilterTableViewController : UITableViewController
@property (strong, nonatomic) NSString *majorDetail;
@property (strong, nonatomic) NSString *minorDetail;
@property (strong, nonatomic) NSString *nameDetail;
@property (strong, nonatomic) NSString *rangeDetail;
@property (nonatomic) FilterType filterType;
@property (assign, nonatomic) UIViewController <FilterTableViewControllerDelegate> *delegate;
@property (strong, nonatomic) FilterTableView *filterTableView;
@property (strong, nonatomic) UIViewController *notifyReceiver;
@property (strong, nonatomic) NSIndexPath *selectedStoreIndexPath;
@property (strong, nonatomic) NSString *accessToken;
- (NSString *)getStoryboardID;
- (void)sendAnimalHospitalInformationRequest;
- (void)sendInitRequest;
- (void)searchWithContent:(NSString *)content;
- (void)back;
- (void)resetPage;
- (BOOL)canDropMyMark;
- (MenuSearchType)getMenuSearchType;
- (NSArray *)getRequestArr;
- (void)resetRequestArr;
@end

@protocol FilterTableViewControllerDelegate <NSObject>
- (void)setAnimalHospitalInformation:(NSMutableDictionary *)dic;
- (void)tableBeTapIn:(NSIndexPath *)indexPath withMenuSearchType:(MenuSearchType)menuSearchType;
- (void)storeBeTapIn:(NSIndexPath *)indexPath withDetail:(Detail *)detail;
- (CLLocationCoordinate2D)sendLocationBackwithMenuSearchType:(MenuSearchType)menuSearchType;
- (void)reloadMapByStores:(NSArray *)stores withZoomLevel:(NSUInteger)zoom pageController:(PageController *)pageController andMenu:(Menu *)menu otherInfo:(NSMutableDictionary *)otherInfo;
- (UIView *)getContentView;
- (CGSize)getContentSize;
- (void)changeTitleByMenu:(Menu *)menu;
- (void)showOptionsWithStore:(Store *)store;
- (void)showNavigationWithStore:(Store *)store;
- (void)loadPreviousPage:(PageController *)pageController;
- (void)loadNextPage:(PageController *)pageController;
@end

@interface FilterTableView : UITableView

@end