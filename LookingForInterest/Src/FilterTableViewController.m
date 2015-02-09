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

#define kCellIdentifier @"FilterTableViewCell"
#define kStoryboardIdentifier @"FilterTableViewController"
#define kMajorTypeSelected @"MajorTypeSelected"
#define kMinorTypeSelected @"MinorTypeSelected"
#define kStoreSelected @"StoreSelected"
#define kRangeSelected @"RangeSelected"

@interface FilterTableViewController () <RequestSenderDelegate>
@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic) NSMutableArray *controlArr;
@property (nonatomic) NSUInteger numberOfRow;
@property (strong, nonatomic) Menu *menu;
@property (strong, nonatomic) NSArray *majorTypes;
@property (strong, nonatomic) NSArray *minorTypes;
@property (strong, nonatomic) NSArray *stores;
@property (strong, nonatomic) NSArray *ranges;
@property (strong, nonatomic) IBOutlet UITableView *filterTableViewStoryboard;
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
            break;
        case FilterTypeMinorType:
            requestSender.delegate = self;
            [requestSender sendMinorRequestByMajorType:((FilterTableViewController *)self.notifyReceiver).menu.majorType];
            break;
        case FilterTypeStore:
            requestSender.delegate = self;
            [requestSender sendStoreRequestByMajorType:((FilterTableViewController *)self.notifyReceiver).menu.majorType minorType:((FilterTableViewController *)self.notifyReceiver).menu.minorType];
            break;
        case FilterTypeRange:
            requestSender.delegate = self;
            [requestSender sendRangeRequest];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendInitRequest {
    RequestSender *requestSender = [[RequestSender alloc] init];
    requestSender.delegate = self;
    [requestSender sendMenuRequest];
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
            if ([self.stores count]) {
                numberOfRows = [self.stores count];
            } else {
                numberOfRows = 1;
            }
            break;
        default:
            break;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRow = 44.4;
    if (self.filterType == FilterTypeMenu) {
        if (indexPath.section == 0 && indexPath.row == 1) {
            heightForRow = 100;
        } else {
            heightForRow = 44.4;
        }
    } else {
        heightForRow = 44.4;
    }
    return heightForRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat heightForHeader = 0.0;
    if (self.filterType == FilterTypeMenu) {
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
    }
    NSString *title = @"";
    NSString *detail = @"";
    title = [self getTitleByIndexPath:indexPath andType:self.filterType];
    detail = [self getDetailByIndexPath:indexPath andType:self.filterType];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(getContentView)]) {
            [cell addSubview:[self.delegate getContentView]];
        }
        
    }
    return cell;
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
                    title = [self.ranges objectAtIndex:indexPath.row];
                    break;
                }
            }
            break;
        case SearchStores:
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
            for (int i=0; i<[self.stores count]; i++) {
                if (i == indexPath.row) {
                    detail = [NSString stringWithFormat:@"距離%.2f公里",[((Store *)[self.stores objectAtIndex:indexPath.row]).distance doubleValue]];
                    break;
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableBeTapIn:)]) {
        if (self.filterType == FilterTypeMenu) {
            
            ExpandContractController *expandController = [[ExpandContractController alloc] init];
            [expandController expandOrContractCellByIndexPaht:indexPath dataArray:self.dataArr controlArray:self.controlArr tableView:tableView];
            
            if (indexPath.section == 1) {
                [self.delegate tableBeTapIn:indexPath];
            } else if (indexPath.section == 0) {
                BOOL isExpand = [[self.controlArr[indexPath.section][indexPath.row] objectForKey:@"IsExpand"] intValue]?YES:NO;
                UITableViewCell *cell = [self.filterTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                if (isExpand) {
                    cell.textLabel.text = @"收起地圖";
                } else {
                    cell.textLabel.text = @"打開地圖";
                }
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(storeBeTapIn:)]) {
                [self.delegate storeBeTapIn:indexPath];
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
}

- (void)generateDataStructureWithMenu:(Menu *)menu {
    self.dataArr = [NSMutableArray array];
    self.controlArr = [NSMutableArray array];
    
    ExpandContractController *expandController = [[ExpandContractController alloc] initWithDelegate:self tableView:self.tableView];
    
    [expandController setNumberOfSection:2 dataArray:self.dataArr controlArray:self.controlArr];
    
    [expandController setNumberOfParent:1 andHeigh:@"44" section:0 dataArray:self.dataArr controlArray:self.controlArr];
    [expandController setNumberOfChild:@"1" andHeigh:@"100" section:0 withParentIndex:0 dataArray:self.dataArr controlArray:self.controlArr];
    
    [expandController setNumberOfParent:[menu.numberOfRows integerValue] andHeigh:@"44" section:1 dataArray:self.dataArr controlArray:self.controlArr];
}

- (void)majorsBack:(NSArray *)majorTypes {
    self.majorTypes = majorTypes;
    [self.filterTableViewStoryboard reloadData];
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
}

- (void)storesBack:(NSArray *)stores {
    self.stores = stores;
    [self.filterTableView reloadData];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(reloadMapByStores:)]) {
            [self.delegate reloadMapByStores:stores];
        }
    }
}

- (void)rangesBack:(NSArray *)ranges {
    self.ranges = [ranges firstObject];
    [self.filterTableViewStoryboard reloadData];
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
}

- (void)receiveSelectedMinorType:(NSNotification *)notification {
    self.menu.minorType = [notification.userInfo objectForKey:@"MinorType"];
    [self.filterTableView reloadData];
}

- (void)receiveSelectedStore:(NSNotification *)notification {
    self.menu.store = [notification.userInfo objectForKey:@"Store"];
    [self.filterTableView reloadData];
}

- (void)receiveSelectedRange:(NSNotification *)notification {
    self.menu.range = [notification.userInfo objectForKey:@"Range"];
    [self.filterTableView reloadData];
}
@end
