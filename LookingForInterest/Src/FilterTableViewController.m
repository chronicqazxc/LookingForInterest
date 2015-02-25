//
//  FilterTableViewController.m
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "FilterTableViewController.h"
#import "LookingForInterest.h"
#import "RequestSender.h"
#import "ExpandContractController.h"
#import "MapViewCell.h"
#import <MGSwipeTableCell/MGSwipeButton.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import "MenuCell.h"
#import "StoreCell.h"
#import "OpenMapCell.h"
#import "OpenMapHeaderController.h"
#import "StoreTableHeaderViewController.h"

#define kUpArrowImg @"arrow-up@2x.png"
#define kDownArrowImg @"arrow-down@2x.png"
#define kCellIdentifier @"FilterTableViewCell"
#define kOpenMapCellIdentifier @"OpenMapCell"
#define kMapViewCellIdentifier @"MapViewCell"
#define kMenuCellIdentifier @"MenuCell"
#define kStoreCellIdentifier @"StoreCell"
#define kStoryboardIdentifier @"FilterTableViewController"
#define kMajorTypeSelected @"MajorTypeSelected"
#define kMinorTypeSelected @"MinorTypeSelected"
#define kStoreSelected @"StoreSelected"
#define kRangeSelected @"RangeSelected"
#define kCitySelected @"CitySelected"
#define kMenuTypeSelected @"MenuTypeSelected"
#define kMapViewHeight @"200"
#define kMapViewSize(mapSize) CGSizeMake(mapSize.width, mapSize.height)
#define kMajorTypeNavTitle @"選擇大類"
#define kMinorTypeNavTitle @"選擇小類"
#define kRangeNavTitle @"選擇範圍"
#define kCityNavTitle @"選擇縣市"
#define kMenuTypesTitle @"選擇搜尋依據"
#define kOpenMapMessage @"打開地圖"
#define kCloseMapMessage @"收起地圖"
#define kCellNavigationTitle @"導航"
#define kCellMoreTitle @"更多"

@interface FilterTableViewController () <RequestSenderDelegate, MGSwipeTableCellDelegate, UITextFieldDelegate>
@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic) NSMutableArray *controlArr;
@property (nonatomic) NSUInteger numberOfRow;
@property (strong, nonatomic) Menu *menu;
@property (strong, nonatomic) NSArray *majorTypes;
@property (strong, nonatomic) NSArray *minorTypes;
@property (strong, nonatomic) NSArray *stores;
@property (strong, nonatomic) NSArray *ranges;
@property (strong, nonatomic) NSArray *menuTypes;
@property (strong, nonatomic) NSArray *cities;
@property (strong, nonatomic) Detail *detail;
@property (strong, nonatomic) PageController *pageController;
@property (strong, nonatomic) IBOutlet UITableView *filterTableViewStoryboard;
@property (nonatomic) CGSize mapSize;
@property (strong, nonatomic) OpenMapHeaderController *openMapHeader;
@property (strong, nonatomic) StoreTableHeaderViewController *storeHeader;
@property (strong, nonatomic) UIImage *upArrowImage;
@property (strong, nonatomic) UIImage *downArrowImage;
@property (nonatomic) BOOL isStartLoadingPage;
@end

@implementation FilterTableViewController

- (id)init {
    self = [super init];
    if (self) {
        if (self.filterTableView) {
            [self initValue];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (self.filterTableViewStoryboard) {
            [self initValue];
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initValue];
    }
    return self;
}

- (void)initValue {
    self.filterTableViewStoryboard.dataSource = self;
    self.filterTableViewStoryboard.delegate = self;
    self.numberOfRow = 0;
    self.openMapHeader = nil;
    self.isStartLoadingPage = NO;
    [self resetPage];
}

- (void)resetPage {
    self.pageController = [[PageController alloc] init];
    self.pageController.currentPage = 1;
    self.pageController.totalPage = 1;
}

- (BOOL)canDropMyMark {
    if (self.menu.menuSearchType == MenuMarker ||
        self.menu.menuSearchType == MenuAddress) {
        return YES;
    } else {
        return NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    RequestSender *requestSender = [[RequestSender alloc] init];
    switch (self.filterType) {
        case FilterTypeMajorType:
            requestSender.delegate = self;
            requestSender.accessToken = self.accessToken;
            [requestSender sendMajorRequest];
            [Utilities startLoading];
            break;
        case FilterTypeMinorType:
            requestSender.delegate = self;
            requestSender.accessToken = self.accessToken;
            [requestSender sendMinorRequestByMajorType:((FilterTableViewController *)self.notifyReceiver).menu.majorType];
            [Utilities startLoading];
            break;
        case FilterTypeStore:
            requestSender.delegate = self;
            requestSender.accessToken = self.accessToken;
            [requestSender sendStoreRequestByMajorType:((FilterTableViewController *)self.notifyReceiver).menu.majorType minorType:((FilterTableViewController *)self.notifyReceiver).menu.minorType];
            [Utilities startLoading];
            break;
        case FilterTypeRange:
            requestSender.delegate = self;
            requestSender.accessToken = self.accessToken;
            [requestSender sendRangeRequest];
            [Utilities startLoading];
            break;
        case FilterTypeCity:
            requestSender.delegate = self;
            requestSender.accessToken = self.accessToken;
            [requestSender sendCityRequest];
            [Utilities startLoading];            
            break;
        case FilterTypeMenuTypes:
            requestSender.delegate = self;
            requestSender.accessToken = self.accessToken;
            [requestSender sendMenutypesRequest];
            [Utilities startLoading];            
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    switch (self.filterType) {
        case FilterTypeMajorType:
            [self setNavigationTitle:kMajorTypeNavTitle];
            break;
        case FilterTypeMinorType:
            [self setNavigationTitle:kMinorTypeNavTitle];
            break;
        case FilterTypeRange:
            [self setNavigationTitle:kRangeNavTitle];
            break;
        case FilterTypeCity:
            [self setNavigationTitle:kCityNavTitle];
            break;
        case FilterTypeMenuTypes:
            [self setNavigationTitle:kMenuTypesTitle];
            break;
        default:
            break;
    }
}

- (void)setNavigationTitle:(NSString *)title {
    self.navigationItem.title = title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendAccessTokenRequest {
    RequestSender *requestSender = [[RequestSender alloc] init];
    requestSender.delegate = self;
    [requestSender getAccessToken];
    [Utilities startLoading];
}

- (void)sendInitRequest {
    RequestSender *requestSender = [[RequestSender alloc] init];
    requestSender.delegate = self;
    requestSender.accessToken = self.accessToken;
    [requestSender sendMenuRequest];
    [Utilities startLoading];
}

- (NSString *)getStoryboardID {
    return kStoryboardIdentifier;
}

- (void)search {
    self.filterType = SearchStores;

//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSData *menuData=[NSKeyedArchiver archivedDataWithRootObject:self.menu];
//    [defaults setObject:menuData forKey:kLookingForInterestUserDefaultKey];
//    [defaults synchronize];
    
    RequestSender *requestSender = [[RequestSender alloc] init];
    requestSender.delegate = self;
    CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake(0, 0);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(sendLocationBack)]) {
            CLLocationCoordinate2D backLocation = [self.delegate sendLocationBack];
            currentLocation = CLLocationCoordinate2DMake(backLocation.latitude, backLocation.longitude);
//            currentLocation = CLLocationCoordinate2DMake(25.0525463, 121.5560048);
        }
    }
    requestSender.accessToken = self.accessToken;
    [requestSender sendStoreRequestByMenuObj:self.menu andLocationCoordinate:currentLocation andPageController:self.pageController];
    [Utilities startLoading];
    
    self.selectedStoreIndexPath = nil;
}

- (void)back {
    self.filterType = FilterTypeMenu;
    [self.filterTableView reloadData];
    
    self.selectedStoreIndexPath = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 0;
    switch (self.filterType) {
        case FilterTypeMenu:
            numberOfSections = 2;
            break;
        case SearchStores:
            numberOfSections = 2;
            break;
        default:
            numberOfSections = 1;
            break;
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numberOfRows = 0;
    switch (self.filterType) {
        case FilterTypeMenu:
            numberOfRows = [self.controlArr[section] count];
            break;
        case FilterTypeMajorType:
            numberOfRows = [self.majorTypes count];
            break;
        case FilterTypeMinorType:
            numberOfRows = [self.minorTypes count];
            break;
        case FilterTypeStore:
            numberOfRows = [self.stores count];
            break;
        case FilterTypeRange:
            numberOfRows = [self.ranges count];
            break;
        case FilterTypeCity:
            numberOfRows = [self.cities count];
            break;
        case FilterTypeMenuTypes:
            if ([self.menuTypes count]) {
                numberOfRows = [self.menuTypes count];
            } else {
                numberOfRows = 1;
            }
            break;
        case SearchStores:
            if (section == 1) {
                if ([self.stores count]) {
                    numberOfRows = [self.stores count];
                } else {
                    numberOfRows = 1;
                }
            } else {
                numberOfRows = [self.controlArr[section] count];
            }
            break;
        default:
            break;
    }
    return numberOfRows;
}

#pragma mark heightForRow>>>>>>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForRowByType:self.filterType andIndexPath:indexPath];
}

- (CGFloat)heightForRowByType:(FilterType)type andIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRow = 0.0;
    switch (type) {
        case FilterTypeMenu:
            if (indexPath.section == 0) {
                heightForRow = [self heightForRowInMapSectionWithIndexPath:indexPath];
            } else {
                heightForRow = [self heightForRowInMenuWithIndexPath:indexPath];
            }
            break;
        case SearchStores:
            if (indexPath.section == 0) {
                heightForRow = [self heightForRowInMapSectionWithIndexPath:indexPath];
            } else {
                heightForRow = [self heightForRowInSearchStore];
            }
            break;
        default:
            heightForRow = 60.0;
            break;
    }
    return heightForRow;
}

- (CGFloat)heightForRowInMapSectionWithIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRow = 0.0;
    if (indexPath.row == 0) {
        heightForRow = 0.0;
    } else if (indexPath.row == 1) {
        heightForRow = kMapViewSize(self.mapSize).height;
    }
    return heightForRow;
}

- (CGFloat)heightForRowInMenuWithIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (CGFloat)heightForRowInSearchStore {
    return 110.0;
}
#pragma mark heightForRow<<<<<<<

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat heightForHeader = 0.0;
    if (self.filterType == FilterTypeMenu || self.filterType == SearchStores) {
//        if (section == 1) {
//            heightForHeader = 50.0;
//        } else {
//            heightForHeader = 0.0;
//        }
        heightForHeader = 50.0;
    } else {
        heightForHeader = 0.0;
    }
    return heightForHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = nil;
    if (self.filterType == FilterTypeMenu  && section == 1) {
        headerView = [Utilities getNibWithName:@"OptionTableHeader"];
        headerView.frame = CGRectMake(0,0,CGRectGetWidth(headerView.frame),50.0);
        [Utilities addShadowToView:headerView offset:CGSizeMake(0.0f, -5.0f)];
    } else if (self.filterType == SearchStores && section == 1) {
        if (!self.storeHeader) {
            self.storeHeader = [[StoreTableHeaderViewController alloc] initWithNibName:@"StoreTableHeaderViewController" bundle:nil];
            self.storeHeader.caller = self;
            self.storeHeader.callBackMethod = @selector(clickStoreTitle);
        }
        self.storeHeader.goTopButtonTitle = [NSString stringWithFormat:@"%d/%d頁",self.pageController.currentPage,self.pageController.totalPage];
        self.storeHeader.view.frame = CGRectMake(0,0,CGRectGetWidth(self.storeHeader.view.frame),50.0);
        [Utilities addShadowToView:self.storeHeader.view offset:CGSizeMake(0.0f, -5.0f)];
        headerView = self.storeHeader.view;
        
    } else if ((self.filterType == FilterTypeMenu || self.filterType == SearchStores) && section == 0) {
        if (!self.openMapHeader) {
            self.openMapHeader = [[OpenMapHeaderController alloc] initWithNibName:@"OpenMapHeaderController" bundle:nil];
            self.openMapHeader.caller = self;
            self.openMapHeader.callbackMethod = @selector(clickOpenMap);
            self.upArrowImage = [UIImage imageNamed:kUpArrowImg];
            self.downArrowImage = [UIImage imageNamed:kDownArrowImg];
        }

//        if ([self.dataArr count] > 1) {
//            if ([[self.dataArr objectAtIndex:0] count] > 1) {
//
//            }
//        } else {
//            self.openMapHeader.openMapIcon.image = self.downArrowImage;
//        }
        BOOL isExpand = [[self.controlArr[0][0] objectForKey:@"IsExpand"] intValue]?YES:NO;
        if (isExpand) {
            self.openMapHeader.openMapIcon.image = self.upArrowImage;
        } else {
            self.openMapHeader.openMapIcon.image = self.downArrowImage;
        }
        
        self.openMapHeader.view.frame = CGRectMake(0,0,CGRectGetWidth(self.openMapHeader.view.frame),50);
        [Utilities addShadowToView:self.openMapHeader.view offset:CGSizeMake(0, 5.0)];
        headerView = self.openMapHeader.view;
    }
    return headerView;
}

- (void)clickOpenMap {
    [self tableView:self.filterTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)clickStoreTitle {
    if (self.selectedStoreIndexPath && self.selectedStoreIndexPath.section == 1) {
        [self.filterTableView scrollToRowAtIndexPath:self.selectedStoreIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ((self.filterType == FilterTypeMenu || self.filterType == SearchStores) && (indexPath.section == 0 && indexPath.row == 1)) {
        MapViewCell *mapViewCell = nil;
        mapViewCell = [tableView dequeueReusableCellWithIdentifier:kMapViewCellIdentifier];
        if (!mapViewCell) {
            mapViewCell = (MapViewCell *)[Utilities getNibWithName:kMapViewCellIdentifier];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(getContentView)]) {
            [mapViewCell.contentView addSubview:[self.delegate getContentView]];
            if ([self.delegate respondsToSelector:@selector(getContentSize)]) {
                self.mapSize = CGSizeMake([self.delegate getContentSize].width, [self.delegate getContentSize].height);
            }
        }
        cell = mapViewCell;
    } else if (self.filterType == FilterTypeMenu && indexPath.section == 1) {
        MenuCell *menuCell = nil;
        menuCell = [tableView dequeueReusableCellWithIdentifier:kMenuCellIdentifier];
        if (!menuCell) {
            menuCell = (MenuCell *)[Utilities getNibWithName:kMenuCellIdentifier];
            menuCell.textField.delegate = self;
            menuCell.textField.placeholder = @"請輸入醫院名稱關鍵字";
        }
        if (self.menu.menuSearchType == MenuKeyword && indexPath.row == 1) {
            menuCell.textField.text = self.menu.keyword;
            menuCell.textField.hidden = NO;
            menuCell.detailLabel.hidden = YES;
        } else {
            menuCell.textField.hidden = YES;
            menuCell.detailLabel.hidden = NO;
            menuCell.detailLabel.text = [self getDetailByIndexPath:indexPath andType:self.filterType];
        }
        menuCell.titleLabel.text = [NSString stringWithFormat:@"%@：",[self getTitleByIndexPath:indexPath andType:self.filterType]];
        cell = menuCell;
    } else if (self.filterType == SearchStores && indexPath.section == 1) {
        StoreCell *storeCell = nil;
        storeCell = [tableView dequeueReusableCellWithIdentifier:kStoreCellIdentifier];
        if (!storeCell) {
            storeCell = (StoreCell *)[Utilities getNibWithName:kStoreCellIdentifier];
        }
        
        storeCell.textLabel.font = [UIFont systemFontOfSize:16];
        storeCell.titleLabel.text = [self getTitleByIndexPath:indexPath andType:self.filterType];
        storeCell.distanceLabel.text = [self getDetailByIndexPath:indexPath andType:self.filterType];
        storeCell.addressLabel.text = ((Store *)[self.stores objectAtIndex:indexPath.row]).address;
        
        storeCell.delegate = self;
        
        storeCell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
        storeCell.rightExpansion.buttonIndex = 0;
        storeCell.rightExpansion.fillOnTrigger = NO;
        storeCell.rightExpansion.fillOnTrigger = YES;
        storeCell.rightButtons = [self createRightButtons:2];
        
        storeCell.leftSwipeSettings.transition = MGSwipeTransitionBorder;
        storeCell.leftExpansion.buttonIndex = 0;
        storeCell.leftExpansion.fillOnTrigger = NO;
        storeCell.leftExpansion.fillOnTrigger = YES;
        storeCell.leftButtons = [self createRightButtons:2];
        
        cell = storeCell;
    } else if ((self.filterType == FilterTypeMenu || self.filterType == SearchStores) && indexPath.section == 0 && indexPath.row == 0) {
        OpenMapCell *openMapCell = [tableView dequeueReusableCellWithIdentifier:kOpenMapCellIdentifier];
        if (!openMapCell) {
            openMapCell = (OpenMapCell *)[Utilities getNibWithName:kOpenMapCellIdentifier];
        }
        openMapCell.frame = CGRectMake(0,0,CGRectGetWidth(openMapCell.frame),0);
        openMapCell.titleLabel.text = @"";
        cell = openMapCell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
        }
        cell.layer.borderWidth = 0.0;
        
        NSString *title = @"";
        NSString *detail = @"";
        title = [self getTitleByIndexPath:indexPath andType:self.filterType];
        cell.textLabel.text = title;
        cell.detailTextLabel.text = detail;
    }
    return cell;
}

-(NSArray *) createLeftButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];
    UIColor * colors[3] = {[UIColor greenColor],
        [UIColor colorWithRed:0 green:0x99/255.0 blue:0xcc/255.0 alpha:1.0],
        [UIColor colorWithRed:0.59 green:0.29 blue:0.08 alpha:1.0]};
    UIImage * icons[3] = {[UIImage imageNamed:@"check.png"], [UIImage imageNamed:@"fav.png"], [UIImage imageNamed:@"menu.png"]};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:icons[i] backgroundColor:colors[i] padding:10 callback:^BOOL(MGSwipeTableCell * sender){
            NSLog(@"Convenience callback received (left).");
            return YES;
        }];
        [result addObject:button];
    }
    return result;
}

-(NSArray *) createRightButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];
    NSString *titles[2] = {kCellNavigationTitle, kCellMoreTitle};
    UIColor  *colors[2] = {[UIColor redColor], [UIColor lightGrayColor]};
    for (int i = 0; i < number; ++i)
    {
//        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
//            NSLog(@"Convenience callback received (right).");
//            return YES;
//        }];
        MGSwipeButton *button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] padding:15];
        [result addObject:button];
    }
    return result;
}

- (NSString *)getTitleByIndexPath:(NSIndexPath *)indexPath andType:(FilterType)type {
    NSString *title = @"";
    switch (type) {
        case FilterTypeMenu:
            if (indexPath.section == 0 && indexPath.row == 0) {
                BOOL isExpand = [[self.controlArr[indexPath.section][indexPath.row] objectForKey:@"IsExpand"] intValue]?YES:NO;
                if (isExpand) {
                    title = kCloseMapMessage;
                } else {
                    title = kOpenMapMessage;
                }
            } else if (indexPath.section == 1) {
                title = (indexPath.row < [self.menu.titles count])?[self.menu.titles objectAtIndex:indexPath.row]:@"";
            }
            break;
        case FilterTypeMajorType:
            title = (indexPath.row < [self.majorTypes count])?((MajorType *)[self.majorTypes objectAtIndex:indexPath.row]).typeDescription:@"";
            break;
        case FilterTypeMinorType:
            title = (indexPath.row < [self.minorTypes count])?((MinorType *)[self.minorTypes objectAtIndex:indexPath.row]).typeDescription:@"";
            break;
        case FilterTypeStore:
            title = (indexPath.row < [self.stores count])?((Store *)[self.stores objectAtIndex:indexPath.row]).name:@"";
            break;
        case FilterTypeRange:
            title = (indexPath.row < [self.ranges count])?[NSString stringWithFormat:@"%@公里",[self.ranges objectAtIndex:indexPath.row]]:@"";
            break;
        case FilterTypeCity:
            if ([self.cities count]) {
                title = (indexPath.row < [self.cities count])?[self.cities objectAtIndex:indexPath.row]:@"";
            } else {
                title = @"找不到...";
            }
            break;
        case SearchStores:
            if (indexPath.section == 0 && indexPath.row == 0) {
                BOOL isExpand = [[self.controlArr[indexPath.section][indexPath.row] objectForKey:@"IsExpand"] intValue]?YES:NO;
                if (isExpand) {
                    title = kCloseMapMessage;
                    self.openMapHeader.openMapIcon.image = [UIImage imageNamed:kUpArrowImg];
                } else {
                    title = kOpenMapMessage;
                    self.openMapHeader.openMapIcon.image = [UIImage imageNamed:kDownArrowImg];
                }
            } else {
                if ([self.stores count]) {
                    title = (indexPath.row < [self.stores count])?((Store *)[self.stores objectAtIndex:indexPath.row]).name:@"";
                } else {
                    title = @"找不到...";
                }
            }
            break;
        case FilterTypeMenuTypes:
            title = (indexPath.row < [self.menuTypes count])?[self.menuTypes objectAtIndex:indexPath.row]:@"";
            break;
        default:
            break;
    }
    return title;
}

- (NSString *)getDetailByIndexPath:(NSIndexPath *)indexPath andType:(FilterType)type {
    NSString *detail = @"";
    switch (type) {
        case FilterTypeMenu:
            if (indexPath.row == 0) {
                detail = self.menu.depend;
            } else if (indexPath.row == 1) {
                if (self.menu.menuSearchType == MenuCurrentPosition) {
                    detail = self.menu.range;
                } else if (self.menu.menuSearchType == MenuCities) {
                    detail = self.menu.city;
                } else {
                    detail = @"";
                }
            } else {
                detail = @"";
            }
            
            break;
        case FilterTypeMajorType:
            detail = (indexPath.row < [self.majorTypes count])?((MajorType *)[self.majorTypes objectAtIndex:indexPath.row]).typeDescription:@"";
            break;
        case FilterTypeMinorType:
            detail = (indexPath.row < [self.minorTypes count])?((MinorType *)[self.minorTypes objectAtIndex:indexPath.row]).typeDescription:@"";
            break;
        case FilterTypeStore:
            detail = (indexPath.row < [self.stores count])?[NSString stringWithFormat:@"距離%.2f公里",[((Store *)[self.stores objectAtIndex:indexPath.row]).distance doubleValue]]:@"";
            break;
        case FilterTypeRange:
            detail = (indexPath.row < [self.ranges count])?[self.ranges objectAtIndex:indexPath.row]:@"";
            break;
        case SearchStores:
            detail = (indexPath.row < [self.stores count])?[NSString stringWithFormat:@"距離%.2f公里",[((Store *)[self.stores objectAtIndex:indexPath.row]).distance doubleValue]]:@"";
            break;
        default:
            break;
    }
    return detail;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(tableBeTapIn:withMenuSearchType:)] &&
        [self.delegate respondsToSelector:@selector(storeBeTapIn:withDetail:)]) {
        if (self.filterType == FilterTypeMenu || self.filterType == SearchStores) {
            if (indexPath.section == 0) {
                ExpandContractController *expandController = [[ExpandContractController alloc] init];
                [expandController expandOrContractCellByIndexPaht:indexPath dataArray:self.dataArr controlArray:self.controlArr tableView:tableView];
                
                BOOL isExpand = [[self.controlArr[indexPath.section][indexPath.row] objectForKey:@"IsExpand"] intValue]?YES:NO;
                if (isExpand) {
                    self.openMapHeader.titleLabel.text = kCloseMapMessage;
                    self.openMapHeader.openMapIcon.image = self.upArrowImage;
                } else {
                    self.openMapHeader.titleLabel.text = kOpenMapMessage;
                    self.openMapHeader.openMapIcon.image = self.downArrowImage;
                }
                
            } else if (indexPath.section == 1 && self.filterType == FilterTypeMenu) {
                if (self.menu.menuSearchType != MenuKeyword || indexPath.row != 1) {
                    [self.delegate tableBeTapIn:indexPath withMenuSearchType:self.menu.menuSearchType];
                }
            } else if (indexPath.section == 1 && self.filterType == SearchStores){
                if ([self.stores count]) {
                    self.selectedStoreIndexPath = indexPath;
                    RequestSender *requestSender = [[RequestSender alloc] init];
                    requestSender.delegate = self;
                    requestSender.accessToken = self.accessToken;
                    [requestSender sendDetailRequestByStore:[self.stores objectAtIndex:indexPath.row]];
                    [Utilities startLoading];
                }
            }
        }
    } else {
        switch (self.filterType) {
            case FilterTypeMajorType:
                [[NSNotificationCenter defaultCenter] addObserver:self.notifyReceiver selector:@selector(receiveSelectedMajorType:) name:kMajorTypeSelected object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kMajorTypeSelected object:self userInfo:@{@"MajorType":[self.majorTypes objectAtIndex:indexPath.row]}];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case FilterTypeMinorType:
                [[NSNotificationCenter defaultCenter] addObserver:self.notifyReceiver selector:@selector(receiveSelectedMinorType:) name:kMinorTypeSelected object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kMinorTypeSelected object:self userInfo:@{@"MinorType":[self.minorTypes objectAtIndex:indexPath.row]}];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case FilterTypeStore:
                [[NSNotificationCenter defaultCenter] addObserver:self.notifyReceiver selector:@selector(receiveSelectedStore:) name:kStoreSelected object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kStoreSelected object:self userInfo:@{@"Store":[self.stores objectAtIndex:indexPath.row]}];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case FilterTypeRange:
                [[NSNotificationCenter defaultCenter] addObserver:self.notifyReceiver selector:@selector(receiveSelectedRange:) name:kRangeSelected object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kRangeSelected object:self userInfo:@{@"Range":[self.ranges objectAtIndex:indexPath.row]}];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case FilterTypeCity:
                [[NSNotificationCenter defaultCenter] addObserver:self.notifyReceiver selector:@selector(receiveSelectedCity:) name:kCitySelected object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kCitySelected object:self userInfo:@{@"City":[self.cities objectAtIndex:indexPath.row]}];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case FilterTypeMenuTypes:
                [[NSNotificationCenter defaultCenter] addObserver:self.notifyReceiver selector:@selector(receiveSelectedMenuType:) name:kMenuTypeSelected object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuTypeSelected object:self userInfo:@{@"MenuType":[NSNumber numberWithInt:indexPath.row]}];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            default:
                break;
        }
    }
}

#pragma mark - RequestSenderDelegate
- (void)accessTokenBack:(NSArray *)accessTokenData {
    if ([accessTokenData count] > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(setAccessTokenValue:)]) {
            [self.delegate setAccessTokenValue:[accessTokenData firstObject]];
        }
        [Utilities stopLoading];
    }
}

- (void)initMenuBack:(NSArray *)menuData {
    self.menu = [menuData firstObject];
    [self generateDataStructureWithMenu:self.menu];
    [self.filterTableView reloadData];
    [Utilities stopLoading];
}

- (void)generateDataStructureWithMenu:(Menu *)menu {
    self.dataArr = [NSMutableArray array];
    self.controlArr = [NSMutableArray array];
    
    ExpandContractController *expandController = [[ExpandContractController alloc] initWithDelegate:self tableView:self.tableView];
    
    [expandController setNumberOfSection:2 dataArray:self.dataArr controlArray:self.controlArr];
    
    [expandController setNumberOfParent:1 andHeigh:@"44" section:0 dataArray:self.dataArr controlArray:self.controlArr];
    [expandController setNumberOfChild:@"1" andHeigh:kMapViewHeight section:0 withParentIndex:0 dataArray:self.dataArr controlArray:self.controlArr];
    
    [expandController setNumberOfParent:[menu.numberOfRows intValue] andHeigh:@"44" section:1 dataArray:self.dataArr controlArray:self.controlArr];
}

- (void)menuTypesBack:(NSArray *)menuData {
    self.menuTypes = [menuData firstObject];
    [self.filterTableViewStoryboard reloadData];
    [Utilities stopLoading];
}

- (void)citiesBack:(NSArray *)citiesData {
    self.cities = [NSArray arrayWithArray:citiesData];
    [self.filterTableViewStoryboard reloadData];
    [Utilities stopLoading];
}

- (void)majorsBack:(NSArray *)majorTypes {
    self.majorTypes = majorTypes;
    [self.filterTableViewStoryboard reloadData];
    [Utilities stopLoading];
}

- (void)minorsBack:(NSArray *)minorTypes {
    self.minorTypes = minorTypes;
    if (self.menu) {
        self.menu.minorType = [minorTypes firstObject];
    }
    if (self.filterTableView) {
        [self.filterTableView reloadData];
    } else if (self.filterTableViewStoryboard) {
        [self.filterTableViewStoryboard reloadData];
    }
    [Utilities stopLoading];
}

- (void)storesBack:(NSMutableDictionary *)resultDic {
    NSArray *stores = [resultDic objectForKey:@"stores"];
    self.stores = stores;
    self.pageController = [resultDic objectForKey:@"pageController"];
    [self.filterTableView reloadData];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(reloadMapByStores:withZoomLevel: pageController: andMenu:)]) {
//            CGSize screenSize = [Utilities getScreenPixel];
//            NSUInteger zoom = [self calculateZoomLevelwithScreenWidth:screenSize.width];
            // km:2 zoom:13
            [self.delegate reloadMapByStores:stores withZoomLevel:13.9999999 pageController:self.pageController andMenu:self.menu];
        }
    }
    self.isStartLoadingPage = NO;
    [Utilities stopLoading];
    
    BOOL isExpand = [[self.controlArr[0][0] objectForKey:@"IsExpand"] intValue]?YES:NO;
    if (!isExpand) {
        [self clickOpenMap];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeTitle:)]) {
        [self.delegate changeTitle:self.menu.minorType.typeDescription];
    }
}

- (void)detailBack:(NSArray *)detailData {
    self.detail = [detailData firstObject];
    if (self.delegate && [self.delegate respondsToSelector:@selector(storeBeTapIn: withDetail:)]) {
        [self.delegate storeBeTapIn:self.selectedStoreIndexPath withDetail:self.detail];
    }
    [Utilities stopLoading];
}

- (NSUInteger)calculateZoomLevelwithScreenWidth:(NSUInteger)screenWidth {
    CGFloat equatorLength = [self.menu.range doubleValue];
    CGFloat widthInPixels = screenWidth;
    CGFloat metersPerPixel = equatorLength / 256;
    NSUInteger zoomLevel = 1;
    while ((metersPerPixel * widthInPixels) > 2000) {
        metersPerPixel /= 2;
        ++zoomLevel;
    }
    return zoomLevel;
}

- (void)rangesBack:(NSArray *)ranges {
    self.ranges = [ranges firstObject];
    [self.filterTableViewStoryboard reloadData];
    [Utilities stopLoading];
}

#pragma mark - Notify
- (void)receiveSelectedMajorType:(NSNotification *)notification {
    MajorType *backMajorType = [notification.userInfo objectForKey:@"MajorType"];
    if (![self.menu.majorType.typeID isEqualToString:backMajorType.typeID]) {
        self.menu.majorType = backMajorType;
        RequestSender *requestSender = [[RequestSender alloc] init];
        requestSender.delegate = self;
        [requestSender sendMinorRequestByMajorType:backMajorType];
    }
    [self.filterTableView reloadData];
    [Utilities stopLoading];
}

- (void)receiveSelectedMinorType:(NSNotification *)notification {
    self.menu.minorType = [notification.userInfo objectForKey:@"MinorType"];
    [self.filterTableView reloadData];
    [Utilities stopLoading];
}

- (void)receiveSelectedStore:(NSNotification *)notification {
    self.menu.store = [notification.userInfo objectForKey:@"Store"];
    [self.filterTableView reloadData];
    [Utilities stopLoading];
}

- (void)receiveSelectedRange:(NSNotification *)notification {
    self.menu.range = [notification.userInfo objectForKey:@"Range"];
    [self.filterTableView reloadData];
    [Utilities stopLoading];
}

- (void)receiveSelectedCity:(NSNotification *)notification {
    self.menu.city = [notification.userInfo objectForKey:@"City"];
    [self.filterTableView reloadData];
    [Utilities stopLoading];
}

- (void)receiveSelectedMenuType:(NSNotification *)notification {
    MenuSearchType menuType = [[notification.userInfo objectForKey:@"MenuType"] intValue];
    RequestSender *requestSender = [[RequestSender alloc] init];
    requestSender.delegate = self;
    requestSender.accessToken = self.accessToken;
    [requestSender sendMenuRequestWithType:menuType];
    [Utilities startLoading];
}

#pragma mark - MGSwipeTableCellDelegate
- (BOOL) swipeTableCell:(MGSwipeTableCell *) cell canSwipe:(MGSwipeDirection) direction {
    if (direction == MGSwipeDirectionLeftToRight) {
        return YES;
    } else {
        return YES;
    }
}

- (void) swipeTableCell:(MGSwipeTableCell *) cell didChangeSwipeState:(MGSwipeState) state gestureIsActive:(BOOL) gestureIsActive {
    
}

- (BOOL) swipeTableCell:(MGSwipeTableCell *) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    switch (index) {
        case 0:
            [self navigateWithCell:cell];
            break;
        case 1:
            [self showOptionsByCell:cell];
            break;
        default:
            break;
    }
    return NO;
}

- (void)navigateWithCell:(MGSwipeTableCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showNavigationWithStore:)]) {
        NSIndexPath *indexPath = [self.filterTableView indexPathForCell:cell];
        [self.delegate showNavigationWithStore:[self.stores objectAtIndex:indexPath.row]];
    }
}

- (void)showOptionsByCell:(MGSwipeTableCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showOptionsWithStore:)]) {
        NSIndexPath *indexPath = [self.filterTableView indexPathForCell:cell];
        [self.delegate showOptionsWithStore:[self.stores objectAtIndex:indexPath.row]];   
    }
}

//- (NSArray *) swipeTableCell:(MGSwipeTableCell *) cell swipeButtonsForDirection:(MGSwipeDirection)direction
//              swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {
//    
//    swipeSettings.transition = MGSwipeTransitionBorder;
//    if (direction == MGSwipeDirectionRightToLeft) {
//        expansionSettings.buttonIndex = 0;
//        expansionSettings.fillOnTrigger = YES;
//        return [self createRightButtons:2];
//    } else {
//        expansionSettings.buttonIndex = 0;
//        expansionSettings.fillOnTrigger = NO;
//        return [self createLeftButtons:0];
//    }
//}

#pragma mark - change page
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if (self.filterType == SearchStores) {
        CGPoint offset = aScrollView.contentOffset;
        CGRect bounds = aScrollView.bounds;
        CGSize size = aScrollView.contentSize;
        UIEdgeInsets inset = aScrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        float reloadDistance = 90;
        
        if(y > h + reloadDistance) {
            if (self.pageController.currentPage < self.pageController.totalPage) {
                [self getNextPage];
            }
        } else if (offset.y <= -90) {
            if (self.pageController.currentPage > 1) {
                [self previousPage];
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    ((UIButton *)(self.storeHeader.goTopButton)).hidden = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hiddenPageIndicator:) userInfo:nil repeats:NO];
}

- (void)hiddenPageIndicator:(NSTimer *)timer {
    ((UIButton *)(self.storeHeader.goTopButton)).hidden = YES;
    [timer invalidate];
}

- (void)previousPage {
    if (!self.isStartLoadingPage) {
        NSLog(@"previous page");
        if (self.delegate && [self.delegate respondsToSelector:@selector(loadPreviousPage:)]) {
            self.isStartLoadingPage = YES;
            [self.delegate loadPreviousPage:self.pageController];
            self.pageController.currentPage--;
            [self search];
        }
    }
}

- (void)getNextPage {
    if (!self.isStartLoadingPage) {
        NSLog(@"next page");
        if (self.delegate && [self.delegate respondsToSelector:@selector(loadNextPage:)]) {
            self.isStartLoadingPage = YES;
            [self.delegate loadNextPage:self.pageController];
            self.pageController.currentPage++;
            [self search];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.menu.keyword = textField.text;
    [textField resignFirstResponder];
    return YES;
}

@end
