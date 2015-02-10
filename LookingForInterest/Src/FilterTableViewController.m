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
#define kMapViewHeight @"200"
#define kMapViewSize(mapSize) CGSizeMake(mapSize.width, mapSize.height)
#define kMajorTypeNavTitle @"選擇大類"
#define kMinorTypeNavTitle @"選擇小類"
#define kRangeNavTitle @"選擇範圍"

@interface FilterTableViewController () <RequestSenderDelegate, MGSwipeTableCellDelegate>
@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic) NSMutableArray *controlArr;
@property (nonatomic) NSUInteger numberOfRow;
@property (strong, nonatomic) Menu *menu;
@property (strong, nonatomic) NSArray *majorTypes;
@property (strong, nonatomic) NSArray *minorTypes;
@property (strong, nonatomic) NSArray *stores;
@property (strong, nonatomic) NSArray *ranges;
@property (strong, nonatomic) IBOutlet UITableView *filterTableViewStoryboard;
@property (nonatomic) CGSize mapSize;
@end

@implementation FilterTableViewController

- (id)init {
    self = [super init];
    if (self) {
        if (self.filterTableView) {
            self.filterTableView.dataSource = self;
            self.filterTableView.delegate = self;
            self.numberOfRow = 0;
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (self.filterTableViewStoryboard) {
            self.filterTableViewStoryboard.dataSource = self;
            self.filterTableViewStoryboard.delegate = self;
            self.numberOfRow = 0;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    RequestSender *requestSender = [[RequestSender alloc] init];
    switch (self.filterType) {
        case FilterTypeMajorType:
            requestSender.delegate = self;
            [requestSender sendMajorRequest];
            [Utilities startLoading];
            break;
        case FilterTypeMinorType:
            requestSender.delegate = self;
            [requestSender sendMinorRequestByMajorType:((FilterTableViewController *)self.notifyReceiver).menu.majorType];
            [Utilities startLoading];
            break;
        case FilterTypeStore:
            requestSender.delegate = self;
            [requestSender sendStoreRequestByMajorType:((FilterTableViewController *)self.notifyReceiver).menu.majorType minorType:((FilterTableViewController *)self.notifyReceiver).menu.minorType];
            [Utilities startLoading];
            break;
        case FilterTypeRange:
            requestSender.delegate = self;
            [requestSender sendRangeRequest];
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

- (void)sendInitRequest {
    RequestSender *requestSender = [[RequestSender alloc] init];
    requestSender.delegate = self;
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
        }
    }
    [requestSender sendStoreRequestByMenuObj:self.menu andLocationCoordinate:currentLocation];
    [Utilities startLoading];
}

- (void)back {
    self.filterType = FilterTypeMenu;
    [self.filterTableView reloadData];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRow = 50;
    if (self.filterType == FilterTypeMenu || self.filterType == SearchStores) {
        if (indexPath.section == 0 && indexPath.row == 1) {
            heightForRow = kMapViewSize(self.mapSize).height;
        } else if (indexPath.section == 0 && indexPath.row == 0){
            heightForRow = 44;
        } else {
            heightForRow = 60;
        }
    } else {
        heightForRow = 60;
    }
    return heightForRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat heightForHeader = 0.0;
    if (self.filterType == FilterTypeMenu || self.filterType == SearchStores) {
        if (section == 1) {
            heightForHeader = 50.0;
        } else {
            heightForHeader = 0.0;
        }
    } else {
        heightForHeader = 0.0;
    }
    return heightForHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = nil;
    if (self.filterType == FilterTypeMenu  && section == 1) {
        headerView = [Utilities getNibWithName:@"OptionTableHeader"];
    } else if (self.filterType == SearchStores && section == 1) {
        headerView = [Utilities getNibWithName:@"StoreTableHeader"];
    }
    return headerView;
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
        }
        menuCell.titleLabel.text = [NSString stringWithFormat:@"%@：",[self getTitleByIndexPath:indexPath andType:self.filterType]];
        menuCell.detailLabel.text = [self getDetailByIndexPath:indexPath andType:self.filterType];
//        menuCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell = menuCell;
    } else if (self.filterType == SearchStores && indexPath.section == 1) {
        StoreCell *storeCell = nil;
        storeCell = [tableView dequeueReusableCellWithIdentifier:kStoreCellIdentifier];
        if (!storeCell) {
            storeCell = (StoreCell *)[Utilities getNibWithName:kStoreCellIdentifier];
        }
        
        storeCell.textLabel.font = [UIFont systemFontOfSize:16];
        storeCell.textLabel.text = [self getTitleByIndexPath:indexPath andType:self.filterType];
        storeCell.detailTextLabel.text = [self getDetailByIndexPath:indexPath andType:self.filterType];
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
        OpenMapCell *openMapCell = nil;
        openMapCell = [tableView dequeueReusableCellWithIdentifier:kOpenMapCellIdentifier];
        if (!openMapCell) {
            openMapCell = (OpenMapCell *)[Utilities getNibWithName:kOpenMapCellIdentifier];
        }
        openMapCell.titleLabel.text = [self getTitleByIndexPath:indexPath andType:self.filterType];
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
//        detail = [self getDetailByIndexPath:indexPath andType:self.filterType];
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
    NSString *titles[2] = {@"Navigate", @"More"};
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
                    title = @"收起地圖";
                } else {
                    title = @"打開地圖";
                }
            } else if (indexPath.section == 1) {
                for (int i=0; i<[self.menu.titles count]; i++) {
                    if (i == indexPath.row) {
                        title = [self.menu.titles objectAtIndex:indexPath.row];
                        break;
                    }
                }
            }
            break;
        case FilterTypeMajorType:
            for (int i=0; i<[self.majorTypes count]; i++) {
                if (i == indexPath.row) {
                    title = ((MajorType *)[self.majorTypes objectAtIndex:indexPath.row]).typeDescription;
                    break;
                }
            }
            break;
        case FilterTypeMinorType:
            for (int i=0; i<[self.minorTypes count]; i++) {
                if (i == indexPath.row) {
                    title = ((MinorType *)[self.minorTypes objectAtIndex:indexPath.row]).typeDescription;
                    break;
                }
            }
            break;
        case FilterTypeStore:
            for (int i=0; i<[self.stores count]; i++) {
                if (i == indexPath.row) {
                    title = ((Store *)[self.stores objectAtIndex:indexPath.row]).name;
                    break;
                }
            }
            break;
        case FilterTypeRange:
            for (int i=0; i<[self.ranges count]; i++) {
                if (i == indexPath.row) {
                    title = [NSString stringWithFormat:@"%@公里",[self.ranges objectAtIndex:indexPath.row]];
                    break;
                }
            }
            break;
        case SearchStores:
            if (indexPath.section == 0 && indexPath.row == 0) {
                BOOL isExpand = [[self.controlArr[indexPath.section][indexPath.row] objectForKey:@"IsExpand"] intValue]?YES:NO;
                if (isExpand) {
                    title = @"收起地圖";
                } else {
                    title = @"打開地圖";
                }
            } else {
                if ([self.stores count]) {
                    for (int i=0; i<[self.stores count]; i++) {
                        if (i == indexPath.row) {
                            title = ((Store *)[self.stores objectAtIndex:indexPath.row]).name;
                            break;
                        }
                    }
                } else {
                    title = @"找不到...";
                }
            }
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
            if (indexPath.section == 1) {
                switch (indexPath.row) {
                    case 0:
                        detail = self.menu.majorType.typeDescription;
                        break;
                    case 1:
                        detail = self.menu.minorType.typeDescription;
                        break;
                    case 2:
                        detail = self.menu.range;
                        break;
                    default:
                        break;
                }
            }
            break;
        case FilterTypeMajorType:
            for (int i=0; i<[self.majorTypes count]; i++) {
                if (i == indexPath.row) {
                    detail = ((MajorType *)[self.majorTypes objectAtIndex:indexPath.row]).typeDescription;
                    break;
                }
            }
            break;
        case FilterTypeMinorType:
            for (int i=0; i<[self.minorTypes count]; i++) {
                if (i == indexPath.row) {
                    detail = ((MinorType *)[self.minorTypes objectAtIndex:indexPath.row]).typeDescription;
                    break;
                }
            }
            break;
        case FilterTypeStore:
            for (int i=0; i<[self.stores count]; i++) {
                if (i == indexPath.row) {
                    detail = [NSString stringWithFormat:@"距離%.2f公里",[((Store *)[self.stores objectAtIndex:indexPath.row]).distance doubleValue]];
                    break;
                }
            }
            break;
        case FilterTypeRange:
            for (int i=0; i<[self.ranges count]; i++) {
                if (i == indexPath.row) {
                    detail = [self.ranges objectAtIndex:indexPath.row];
                    break;
                }
            }
            break;
        case SearchStores:
            if (indexPath.section == 1) {
                for (int i=0; i<[self.stores count]; i++) {
                    if (i == indexPath.row) {
                        detail = [NSString stringWithFormat:@"距離%.2f公里",[((Store *)[self.stores objectAtIndex:indexPath.row]).distance doubleValue]];
                        break;
                    }
                }
            }
            break;
        default:
            break;
    }
    return detail;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableBeTapIn:)] && [self.delegate respondsToSelector:@selector(storeBeTapIn:)]) {
        if (self.filterType == FilterTypeMenu || self.filterType == SearchStores) {
            if (indexPath.section == 0) {
                ExpandContractController *expandController = [[ExpandContractController alloc] init];
                [expandController expandOrContractCellByIndexPaht:indexPath dataArray:self.dataArr controlArray:self.controlArr tableView:tableView];
                
                BOOL isExpand = [[self.controlArr[indexPath.section][indexPath.row] objectForKey:@"IsExpand"] intValue]?YES:NO;
                OpenMapCell *cell = (OpenMapCell *)[self.filterTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                if (isExpand) {
                    cell.titleLabel.text = @"收起地圖";
                } else {
                    cell.titleLabel.text = @"打開地圖";
                }
                
            } else if (indexPath.section == 1 && self.filterType == FilterTypeMenu) {
                [self.delegate tableBeTapIn:indexPath];
            } else if (indexPath.section == 1 && self.filterType == SearchStores){
                if ([self.stores count]) {
                    [self.delegate storeBeTapIn:indexPath];
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
            default:
                break;
        }
    }
}

#pragma mark - RequestSenderDelegate
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
    
    [expandController setNumberOfParent:[menu.numberOfRows integerValue] andHeigh:@"44" section:1 dataArray:self.dataArr controlArray:self.controlArr];
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

- (void)storesBack:(NSArray *)stores {
    self.stores = stores;
    [self.filterTableView reloadData];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(reloadMapByStores:withZoomLevel:)]) {
//            CGSize screenSize = [Utilities getScreenPixel];
//            NSUInteger zoom = [self calculateZoomLevelwithScreenWidth:screenSize.width];
            // km:2 zoom:13
            [self.delegate reloadMapByStores:stores withZoomLevel:13.9999999];
        }
    }
    [Utilities stopLoading];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeTitle:)]) {
        [self.delegate changeTitle:self.menu.minorType.typeDescription];
    }
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
    NSLog(@"index:%d",index);
    NSLog(@"direction:%d",direction);
    NSLog(@"fromExpansion:%d",fromExpansion);
    if (index == 1) {
        [self showOptionsByCell:cell];
    }
    return NO;
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
@end
