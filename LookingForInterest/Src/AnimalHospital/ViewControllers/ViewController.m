//
//  ViewController.m
//  LookingForInterest
//
//  Created by Wayne on 2/9/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "ViewController.h"
#import "FilterTableViewController.h"
#import "WebViewController.h"
#import "AnimalHospitalViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapNavigation.h"
#import <CoreLocation/CoreLocation.h>
#import "AnimalHospitalRequest.h"
#import "ManulHospitalMenuViewController.h"
#import <iAd/iAd.h>
#import "TableLoadNextPage.h"
#import "TableLoadPreviousPage.h"
#import "MenuTransition.h"
#import "MenuViewController.h"

#define kMagnifierImg @"iconmonstr-magnifier-3-icon-256.png"
#define kLeftArrowImg @"arrow-left@2x.png"

#define kTitle @"與寵物相關"

#define kSearch @"開始找"
#define kBack @"返回"
#define kTitleCurrentPosition @"目前位置附近"
#define kTitleCities @"縣市"
#define kTitleKeyword @"關鍵字"
#define kTitleMarker @"大頭針"
#define kTitleAddress @"地址"
#define kTitleFavorite @"我的最愛"
#define kFormattedTitle(title) [NSString stringWithFormat:@"找%@",title]

#define kOptionsTitle(title) title?title:@""
#define kOptionMessage(message) message?message:@""
#define kCallActionTitle @"撥打電話"
#define kRateActionTitle @"我要評分"
#define kRateActionStreetView @"瀏覽街景"
#define kPicturesActionTitle @"網路搜尋店家圖片"
#define kNavigateActionTitle @"導航"
#define kCloseActionTitle @"關閉"

#define kThreshold 0.30

@interface ViewController () <CLLocationManagerDelegate, ADBannerViewDelegate, GMSMapViewDelegate, FilterTableViewControllerDelegate, ManulViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (nonatomic) CGSize mapViewSize;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL isFirstEntry;
@property (nonatomic) BOOL isSendForMenu;
@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (nonatomic) CLLocationCoordinate2D myMarkerLocation;
@property (strong, nonatomic) GMSMapView *googleMap;
@property (strong, nonatomic) GMSMarker *myMarker;
@property (strong, nonatomic) NSMutableArray *storeMarkers;
@property (strong, nonatomic) GMSPanoramaView *panoView;
@property (strong, nonatomic) GMSGeocoder *gmsGeoCoder;
@property (strong, nonatomic) FilterTableViewController *filterTableViewController;
@property (weak, nonatomic) IBOutlet FilterTableView *filterTableView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) NSArray *storesOnMap;
- (IBAction)buttonClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *searchViewTitle;
@property (weak, nonatomic) IBOutlet UIImageView *searchViewIcon;
@property (strong, nonatomic) UIImage *mirrorMagnifierImage;
@property (weak, nonatomic) IBOutlet UIButton *navigationButton;
- (IBAction)clickNavigationTitle:(UIButton *)sender;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *hospitalDataSource;
@property (strong, nonatomic) NSString *hospitalDataTitle;
@property (strong, nonatomic) NSString *hospitalDataUpdateDate;
@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) ManulHospitalMenuViewController *manulHospitalMenuViewController;
@property (nonatomic) BOOL hadShowManul;

@property (nonatomic) BOOL hasShowVersion;
@property (weak, nonatomic) IBOutlet ADBannerView *adBannerView;
- (IBAction)panInView:(UIPanGestureRecognizer *)recognizer;
@property (strong, nonatomic) MenuTransition *menuTransition;
@end

@implementation ViewController

- (id)init {
    self = [super init];
    if (self) {
        [self iniValue];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self iniValue];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self iniValue];
    }
    return self;
}

- (void)iniValue {
    self.mapViewSize = CGSizeZero;
    self.currentLocation = CLLocationCoordinate2DMake(0.0, 0.0);
    self.isFirstEntry = YES;
    self.isSendForMenu = NO;
    self.searchViewTitle.text = kSearch;
    self.storesOnMap = [NSArray array];
    self.appDelegate = [Utilities appdelegate];
    self.accessToken = self.appDelegate.accessToken;
    self.hasShowVersion = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.adBannerView.delegate = self;
    
    [self settingTitleTextAttribute];
    
    [self settingBackButton];

    [self settingLocationManager];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ) {
        NSLog(@"%@",@"請開啟定位服務");
    }

    [self settingSearchButtonImage];
    
    [self settingLoadingPageView];
    
    self.menuTransition = [[MenuTransition alloc] init];
}

- (void)settingTitleTextAttribute {
    NSDictionary *attributeDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIColor darkTextColor], NSForegroundColorAttributeName,
                                  [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributeDic];
    
}

- (void)settingBackButton {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"首頁" style:UIBarButtonItemStylePlain target:self action:@selector(goHome)];
    NSDictionary *attributeDic2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIColor darkTextColor], NSForegroundColorAttributeName,
                                   [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:15.0], NSFontAttributeName, nil];
    [backButton setTitleTextAttributes:attributeDic2 forState:UIControlStateNormal];
    
    self.navigationController.navigationBar.tintColor = [UIColor darkTextColor];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)goHome {
    UIStoryboard *firstStoryboard = [UIStoryboard storyboardWithName:kFirstStoryboard bundle:nil];
    MenuViewController *controller = (MenuViewController *)[firstStoryboard instantiateViewControllerWithIdentifier:kMenuStoryboardID];
    controller.transitioningDelegate = self.menuTransition;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)settingLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void)setNaviTitleButtonWithString:(NSString *)string {
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attributeDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIColor darkTextColor], NSForegroundColorAttributeName,
                                  [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:string attributes:attributeDic]];
    [self.navigationButton setAttributedTitle:attString forState:UIControlStateNormal];
}

- (void)settingSearchButtonImage {
    self.mirrorMagnifierImage = [Utilities rotateImage:[UIImage imageNamed:kMagnifierImg] toDirection:DirectionMirror withScale:1.0];
    self.searchViewIcon.image = self.mirrorMagnifierImage;
}

- (void)settingLoadingPageView {
    self.loadPreviousPageView = (TableLoadPreviousPage *)[Utilities getNibWithName:@"TableLoadPreviousPage"];
    self.loadPreviousPageView.frame = CGRectZero;
    self.loadPreviousPageView.canLoading = NO;
    self.loadPreviousPageView.indicatorLabel.text = @"";
    [self.filterTableView addSubview:self.loadPreviousPageView];
    [self.filterTableView sendSubviewToBack:self.loadPreviousPageView];
    
    self.loadNextPageView = (TableLoadNextPage *)[Utilities getNibWithName:@"TableLoadNextPage"];
    self.loadNextPageView.frame = CGRectZero;
    self.loadNextPageView.canLoading = NO;
    self.loadNextPageView.indicatorLabel.text = @"";
    [self.filterTableView addSubview:self.loadNextPageView];
    [self.filterTableView sendSubviewToBack:self.loadNextPageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setOriginalTitle];
    [self.filterTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearFilterTableRequestDelegate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self clearFilterTableRequestDelegate];
}

- (void)clearFilterTableRequestDelegate {
    NSArray *requestSenders = [self.filterTableViewController getRequestArr];
    for (AnimalHospitalRequest *requestSender in requestSenders) {
        requestSender.animalHospitalRequestDelegate = nil;
    }
    [self.filterTableViewController resetRequestArr];
}

- (void)setOriginalTitle {
    [self setNaviTitleButtonWithString:kFormattedTitle(kTitleCurrentPosition)];
}

- (void)setFormattedTitle:(NSString *)title {
    [self setNaviTitleButtonWithString:kFormattedTitle(title)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![Utilities getNeverShowManulMenuWithKey:kManulHospitalMenuKey]) {
        if (!self.hadShowManul) {
            self.manulHospitalMenuViewController = [[ManulHospitalMenuViewController alloc] initWithNibName:@"ManulViewController" bundle:nil];
            self.manulHospitalMenuViewController.delegate = self;
            [self presentViewController:self.manulHospitalMenuViewController animated:YES completion:nil];
        } else if (!self.isSendForMenu) {
            self.filterTableViewController = [[FilterTableViewController alloc] init];
            self.filterTableViewController.delegate = self;
            self.filterTableViewController.filterType = RequestTypeMenu;
            self.filterTableViewController.filterTableView = self.filterTableView;
            self.filterTableView.dataSource = self.filterTableViewController;
            self.filterTableView.delegate = self.filterTableViewController;
            self.filterTableViewController.accessToken = self.accessToken;
            [self.filterTableViewController sendAnimalHospitalInformationRequest];
            self.isSendForMenu = YES;
        }
    } else if (!self.isSendForMenu) {
        self.filterTableViewController = [[FilterTableViewController alloc] init];
        self.filterTableViewController.delegate = self;
        self.filterTableViewController.filterType = RequestTypeMenu;
        self.filterTableViewController.filterTableView = self.filterTableView;
        self.filterTableView.dataSource = self.filterTableViewController;
        self.filterTableView.delegate = self.filterTableViewController;
        self.filterTableViewController.accessToken = self.accessToken;
        [self.filterTableViewController sendAnimalHospitalInformationRequest];
        self.isSendForMenu = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews NS_AVAILABLE_IOS(5_0) {
    [super viewDidLayoutSubviews];
    
    if (!self.appDelegate.viewController) {
        self.appDelegate.viewController = self;
    }
    
    if (self.mapViewSize.width == CGSizeZero.width && self.mapViewSize.height == CGSizeZero.height) {
        self.mapViewSize = CGSizeMake(self.mapView.frame.size.width, self.mapView.frame.size.height);
    }
}

- (void)showMap {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude zoom:16];
    self.googleMap = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.mapViewSize.width, self.mapViewSize.height) camera:camera];
    self.googleMap.delegate = self;
    self.googleMap.settings.myLocationButton = YES;
    self.googleMap.myLocationEnabled = YES;
    self.googleMap.settings.compassButton = YES;
    self.googleMap.accessibilityElementsHidden = NO;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"錯誤"
                                                                             message:@"無法取得定位，請重新開啟定位或者網路或開啟Wi-Fi"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"確定"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                                       [self goHome];
    }];
    
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        self.currentLocation = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        if (self.isFirstEntry) {
            [self showMap];
            self.isFirstEntry = NO;
        }
    }
}

#pragma mark - GMSMapViewDelegate
- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    //    [mapView clear];
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)cameraPosition {
    id handler = ^(GMSReverseGeocodeResponse *response, NSError *error) {
        if (error == nil) {
            GMSReverseGeocodeResult *result = response.firstResult;
            GMSMarker *marker = [GMSMarker markerWithPosition:cameraPosition.target];
            marker.title = result.lines[0];
            marker.snippet = result.lines[1];
            marker.map = mapView;
        }
    };
    [self.gmsGeoCoder reverseGeocodeCoordinate:cameraPosition.target completionHandler:handler];
}

- (BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView {
    NSLog(@"%.2f, %.2f",mapView.myLocation.coordinate.latitude, mapView.myLocation.coordinate.longitude);
    GMSCameraPosition *fancy = [GMSCameraPosition cameraWithLatitude:mapView.myLocation.coordinate.latitude longitude:mapView.myLocation.coordinate.longitude zoom:16 bearing:0 viewingAngle:0];
    [mapView setCamera:fancy];
    return YES;
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    Store *store = nil;
    
    UIView *markerInfoView = [[UIView alloc] initWithFrame:CGRectMake(0,0,290,100)];
    markerInfoView.layer.masksToBounds = NO;
    markerInfoView.layer.cornerRadius = 5.0f;
    markerInfoView.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 237, 21)];
    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 41, 280, 21)];
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 63, 280, 21)];
    titleLabel.font = [UIFont systemFontOfSize:24];
    distanceLabel.textColor = [UIColor lightGrayColor];
    addressLabel.numberOfLines = 2;
    
    BOOL found = NO;
    for (int i=0; i<[self.storesOnMap count]; i++) {
        store = [self.storesOnMap objectAtIndex:i];
        NSString *markerTitle = [NSString stringWithFormat:@"%@",marker.title];
        NSString *storeTitle = [NSString stringWithFormat:@"%@",store.storeID];
        if ([storeTitle isEqualToString:markerTitle]) {
            self.filterTableViewController.selectedStoreIndexPath = [NSIndexPath indexPathForRow:i inSection:1];
            titleLabel.text = store.name;
            distanceLabel.text = [NSString stringWithFormat:@"距離%.2f公里",[store.distance doubleValue]];
            addressLabel.text = store.address;
            found = YES;
            break;
        } else {
            continue;
        }
    }
    
    if (!found) {
        titleLabel.text = self.myMarker.snippet;
        distanceLabel.text = @"";
        if (self.myMarker.userData) {
            addressLabel.text = self.myMarker.userData;
        }
    }
    
    [markerInfoView addSubview:titleLabel];
    [markerInfoView addSubview:distanceLabel];
    [markerInfoView addSubview:addressLabel];
    
    return markerInfoView;
}

//- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
//    return YES;
//}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if ([self.filterTableViewController canDropMyMark]) {
        [self.googleMap clear];        
        [self setMyMarkerByLocation:coordinate];
    }
}

- (void)setMyMarkerByLocation:(CLLocationCoordinate2D)coordinate {
    self.myMarker = [[GMSMarker alloc] init];
    self.myMarker.position = CLLocationCoordinate2DMake(coordinate.latitude,coordinate.longitude);
    self.myMarker.appearAnimation = kGMSMarkerAnimationPop;
    self.myMarker.snippet = @"自己選的位置";
    self.myMarker.draggable = YES;
    self.myMarker.flat = YES;
    self.myMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    self.myMarker.map = self.googleMap;
    self.myMarkerLocation = coordinate;
    
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:self.myMarker.position completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
        if (!error) {
            self.myMarker.userData = [NSString stringWithFormat:@"%@,%@,%@,%@",response.firstResult.locality
                                      ,response.firstResult.subLocality
                                      ,response.firstResult.administrativeArea
                                      ,response.firstResult.lines];
        } else {
            self.myMarker.userData = nil;
        }
    }];
}

/**
 * Called when dragging has been initiated on a marker.
 */
- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    marker.icon = [GMSMarker markerImageWithColor:[UIColor cyanColor]];
}

/**
 * Called after dragging of a marker ended.
 */
- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    [self setMyMarkerByLocation:marker.position];
}

/**
 * Called while a marker is dragged.
 */
- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker {
//    marker.icon = [GMSMarker markerImageWithColor:[UIColor yellowColor]];
}

#pragma mark - FilterTableViewControllerDelegate
- (void)setAnimalHospitalInformation:(NSMutableDictionary *)dic {
    self.hospitalDataSource = [dic objectForKey:kHospitalSourceKey];
    self.hospitalDataTitle = [dic objectForKey:kHospitalTitleKey];
    self.hospitalDataUpdateDate = [dic objectForKey:kHospitalUpdateDateKey];
    if ([[dic objectForKey:kHospitalFunctionOpenKey] isEqualToString:@"Y"]) {
        [self.filterTableViewController sendInitRequest];
    } else {
        [Utilities stopLoading];
        NSString *reason = [dic objectForKey:kHospitalFunctionCloseReasonKey];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"功能暫禁" message:reason preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)tableBeTapIn:(NSIndexPath *)indexPath withMenuSearchType:(MenuSearchType)menuSearchType{
    switch (menuSearchType) {
        case MenuCurrentPosition:
            [self processMenuCurrentPositionWithIndexPath:indexPath];
            break;
        case MenuCities:
            [self processMenuCitiesWithIndexPath:indexPath];
            break;
        case MenuKeyword:
            [self processMenuKeywordWithIndexPath:indexPath];
            break;
        case MenuMarker:
            [self processMenuMarkerWithIndexPath:indexPath];
            break;
        case MenuAddress:
            [self processMenuAddressWithIndexPath:indexPath];
            break;
        case MenuFavorite:
            [self processMenuFavoriteWithIndexPath:indexPath];
            break;
        default:
            break;
    }

}

- (void)processMenuCurrentPositionWithIndexPath:(NSIndexPath *)indexPath {
    NSString *storyboardID = [self.filterTableViewController getStoryboardID];
    FilterTableViewController *filterTableViewController = nil;
    switch (indexPath.row) {
        case 0:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = RequestTypeMenuTypes;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        case 1:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = RequestTypeRange;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        default:
            break;
    }
}

- (void)processMenuCitiesWithIndexPath:(NSIndexPath *)indexPath {
    NSString *storyboardID = [self.filterTableViewController getStoryboardID];
    FilterTableViewController *filterTableViewController = nil;
    switch (indexPath.row) {
        case 0:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = RequestTypeMenuTypes;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        case 1:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = RequestTypeCity;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        default:
            break;
    }
}

- (void)processMenuKeywordWithIndexPath:(NSIndexPath *)indexPath {
    NSString *storyboardID = [self.filterTableViewController getStoryboardID];
    FilterTableViewController *filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
    filterTableViewController.filterType = RequestTypeMenuTypes;
    filterTableViewController.notifyReceiver = self.filterTableViewController;
    filterTableViewController.accessToken = self.accessToken;
    [self.navigationController pushViewController:filterTableViewController animated:YES];
}

- (void)processMenuMarkerWithIndexPath:(NSIndexPath *)indexPath {
    NSString *storyboardID = [self.filterTableViewController getStoryboardID];
    FilterTableViewController *filterTableViewController = nil;
    switch (indexPath.row) {
        case 0:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = RequestTypeMenuTypes;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        case 1:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = RequestTypeRange;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        default:
            break;
    }
}

- (void)processMenuAddressWithIndexPath:(NSIndexPath *)indexPath {
    NSString *storyboardID = [self.filterTableViewController getStoryboardID];
    FilterTableViewController *filterTableViewController = nil;
    switch (indexPath.row) {
        case 0:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = RequestTypeMenuTypes;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        case 1:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = RequestTypeRange;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        default:
            break;
    }
}

- (void)processMenuFavoriteWithIndexPath:(NSIndexPath *)indexPath {
    NSString *storyboardID = [self.filterTableViewController getStoryboardID];
    FilterTableViewController *filterTableViewController = nil;
    switch (indexPath.row) {
        case 0:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = RequestTypeMenuTypes;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        default:
            break;
    }
}

- (void)storeBeTapIn:(NSIndexPath *)indexPath withDetail:(Detail *)detail{
    Store *store = [self.storesOnMap objectAtIndex:indexPath.row];
    GMSCameraPosition *fancy = [GMSCameraPosition cameraWithLatitude:[store.latitude doubleValue] longitude:[store.longitude doubleValue] zoom:16 bearing:0 viewingAngle:0];
    [self.googleMap setCamera:fancy];

    AnimalHospitalViewController *animalHospital = [[AnimalHospitalViewController alloc] initWithNibName:@"AnimalHospitalViewController" bundle:nil];
    animalHospital.store = store;
    animalHospital.detail = detail;
    animalHospital.accessToken = self.accessToken;
    CLLocationCoordinate2D location;
    if ([self.filterTableViewController getMenuSearchType] == MenuMarker ||
        [self.filterTableViewController getMenuSearchType] == MenuAddress) {
        location = self.myMarkerLocation;
    } else {
        location = self.currentLocation;
    }
    animalHospital.start = location;
    animalHospital.destination = CLLocationCoordinate2DMake([store.latitude doubleValue], [store.longitude doubleValue]);
    [self.navigationController pushViewController:animalHospital animated:YES];
}

- (CLLocationCoordinate2D)sendLocationBackwithMenuSearchType:(MenuSearchType)menuSearchType {
    CLLocationCoordinate2D location;
    if (menuSearchType == MenuMarker) {
        location = self.myMarkerLocation;
    } else {
        location = self.currentLocation;
    }
    return location;
}

- (void)reloadMapByStores:(NSArray *)stores withZoomLevel:(NSUInteger)zoom pageController:(PageController *)pageController andMenu:(Menu *)menu otherInfo:(NSMutableDictionary *)otherInfo{
    
    self.storesOnMap = stores;
    self.storeMarkers = [NSMutableArray array];
    for (Store *store in stores) {
        GMSMarker *storeMark = [[GMSMarker alloc] init];
        storeMark.position = CLLocationCoordinate2DMake([store.latitude doubleValue],[store.longitude doubleValue]);
        storeMark.appearAnimation = kGMSMarkerAnimationPop;
        storeMark.snippet = store.name;
        storeMark.title = store.storeID;
        storeMark.userData = store.storeID;;
        storeMark.map = self.googleMap;
        [self.storeMarkers addObject:storeMark];
    }
    
    CLLocationCoordinate2D location;
    CLLocationCoordinate2D center;
    double radius;
    
    if (menu.menuSearchType == MenuMarker) {
        [self setMyMarkerByLocation:self.myMarkerLocation];
        location = self.myMarkerLocation;
        center = self.myMarkerLocation;
        radius = [menu.range doubleValue];
    } else if (menu.menuSearchType == MenuCurrentPosition) {
        location = CLLocationCoordinate2DMake(self.currentLocation.latitude, self.currentLocation.longitude);
        center = location;
        radius = [menu.range doubleValue];
    } else if (menu.menuSearchType == MenuAddress) {
        location = CLLocationCoordinate2DMake([[[otherInfo objectForKey:@"address_location"] objectForKey:@"lat"] doubleValue],
                                              [[[otherInfo objectForKey:@"address_location"] objectForKey:@"lng"] doubleValue]);
        [self setMyMarkerByLocation:location];
        center = location;
        radius = [menu.range doubleValue];
    } else {

        center = CLLocationCoordinate2DMake(self.currentLocation.latitude, self.currentLocation.longitude);
        if ([stores count]) {
            location = CLLocationCoordinate2DMake([((Store *)[stores firstObject]).latitude doubleValue], [((Store *)[stores firstObject]).longitude doubleValue]);
            radius = [((Store *)[stores lastObject]).distance doubleValue];
        } else {
            location = self.currentLocation;
            radius = 0.5;
        }
    }
    
    GMSCircle *circ = [GMSCircle circleWithPosition:center radius:radius*1000];
    circ.fillColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.05];
    circ.strokeColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
    circ.strokeWidth = 1;
    circ.map = self.googleMap;
    
    GMSCameraPosition *fancy = [GMSCameraPosition cameraWithLatitude:location.latitude longitude:location.longitude zoom:zoom bearing:0 viewingAngle:0];
    [self.googleMap setCamera:fancy];
    
    if (pageController.currentPage == 1 && pageController.totalPage != 1) {
    } else if (pageController.currentPage == pageController.totalPage && pageController.currentPage != 1) {
    } else if (pageController.totalPage == 1) {
    } else {
    }
}

- (void)resetMap {
    [self.googleMap clear];
    GMSCameraPosition *fancy = [GMSCameraPosition cameraWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude zoom:16 bearing:0 viewingAngle:0];
    [self.googleMap setCamera:fancy];
}

- (UIView *)getContentView {
    return self.googleMap;
}

- (CGSize)getContentSize {
    return self.mapViewSize;
}

- (void)changeTitleByMenu:(Menu *)menu {
    if (!self.hasShowVersion) {
        [self showVersionAlert];
    }
    switch (menu.menuSearchType) {
        case MenuCurrentPosition:
            [self setFormattedTitle:kTitleCurrentPosition];
            break;
        case MenuCities:
            [self setFormattedTitle:kTitleCities];
            break;
        case MenuKeyword:
            [self setFormattedTitle:kTitleKeyword];
            break;
        case MenuMarker:
            [self setFormattedTitle:kTitleMarker];
            break;
        case MenuAddress:
            [self setFormattedTitle:kTitleAddress];
            break;
        case MenuFavorite:
            [self setFormattedTitle:kTitleFavorite];
            break;
        default:
            break;
    }
    [self resetMap];
}

- (void)showVersionAlert {
    NSString *message = [NSString stringWithFormat:@"資料來源:%@\n最後更新日期:%@",self.hospitalDataSource,self.hospitalDataUpdateDate];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.hospitalDataTitle message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
    self.hasShowVersion = YES;
}

- (void)surfWebWithStore:(Store *)store {
    WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    webViewController.keyword = store.name;
    webViewController.searchType = SearchWeb;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)showOptionsWithStore:(Store *)store {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kOptionsTitle(store.name) message:kOptionMessage(@"你可以") preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *webSiteAction = [UIAlertAction actionWithTitle:kWebSiteActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"web site");
        WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
        webViewController.keyword = store.name;
        webViewController.searchType = SearchWeb;
        [self.navigationController pushViewController:webViewController animated:YES];
    }];
    
    UIAlertAction *streetViewAction = [UIAlertAction actionWithTitle:kRateActionStreetView style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"street view");
        CLLocationCoordinate2D panoramaNear = {[store.latitude doubleValue],[store.longitude doubleValue]};
        
        GMSPanoramaView *panoView = [GMSPanoramaView panoramaWithFrame:CGRectZero nearCoordinate:panoramaNear];
        
        GMSMarker *storeMarker = nil;
        for (GMSMarker *marker in self.storeMarkers) {
            NSString *markerTitle = [NSString stringWithFormat:@"%@",marker.title];
            NSString *storeID = [NSString stringWithFormat:@"%@",store.storeID];
            if ([markerTitle isEqualToString:storeID]) {
                storeMarker = marker;
                break;
            }
        }
        if (storeMarker) {
            storeMarker.panoramaView = panoView;
        }
        
        UIViewController *streetViewController = [[UIViewController alloc] init];
        streetViewController.view = panoView;
        streetViewController.navigationItem.title = store.name;
        [self.navigationController pushViewController:streetViewController animated:YES];
        
    }];
    
    UIAlertAction *pictureAction = [UIAlertAction actionWithTitle:kPicturesActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
        webViewController.keyword = store.name;
        webViewController.searchType = SearchImage;
        [self.navigationController pushViewController:webViewController animated:YES];
    }];
    
    UIAlertAction *navigateAction = [UIAlertAction actionWithTitle:kNavigateActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self selectDirectionsModeWithStore:store];
    }];
    
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:kCloseActionTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"close");
    }];
    
    //    [alertController addAction:callAction];
    [alertController addAction:navigateAction];
    [alertController addAction:streetViewAction];
    [alertController addAction:webSiteAction];
    [alertController addAction:pictureAction];
    [alertController addAction:closeAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showNavigationWithStore:(Store *)store {
    [self selectDirectionsModeWithStore:store];
}

- (void)selectDirectionsModeWithStore:(Store *)store {
    UIAlertController *selectDirectionMode = [UIAlertController alertControllerWithTitle:@"怎某去？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *directionsModeDriveing = [UIAlertAction actionWithTitle:kDirectionsModeDrivingTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self launchNavigateWithStore:store withDirectionsMode:kDirectionsModeDriving];
    }];
    
    UIAlertAction *directionsModeTransit = [UIAlertAction actionWithTitle:kDirectionsModeTransitTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self launchNavigateWithStore:store withDirectionsMode:kDirectionsModeTransit];
    }];

    UIAlertAction *directionsModeWalking = [UIAlertAction actionWithTitle:kDirectionsModeWalkingTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self launchNavigateWithStore:store withDirectionsMode:kDirectionsModeWalking];
    }];
    
    UIAlertAction *directionsModeCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [selectDirectionMode addAction:directionsModeDriveing];
    [selectDirectionMode addAction:directionsModeTransit];
    [selectDirectionMode addAction:directionsModeWalking];
    [selectDirectionMode addAction:directionsModeCancel];
    
    [self presentViewController:selectDirectionMode animated:YES completion:nil];
}

- (void)launchNavigateWithStore:(Store *)store withDirectionsMode:(NSString *)directionsMode{
    MenuSearchType menuSearchType = [self.filterTableViewController getMenuSearchType];
    CLLocationCoordinate2D location;
    if (menuSearchType == MenuMarker || menuSearchType == MenuAddress) {
        location = self.myMarkerLocation;
    } else {
        location = self.currentLocation;
    }
    [Utilities launchNavigateWithStore:store startLocation:location andDirectionsMode:directionsMode controller:self];
}

- (void)loadPreviousPage:(PageController *)pageController {
    [self resetMap];
}

- (void)loadNextPage:(PageController *)pageController {
    [self resetMap];
}

#pragma mark -
- (IBAction)buttonClicked:(UIButton *)sender {
    if ([self.searchViewTitle.text isEqualToString:kSearch]) {
        [self resetMap];
        self.searchViewTitle.text = kBack;
        self.searchViewIcon.image = [UIImage imageNamed:kLeftArrowImg];
        self.searchViewIcon.hidden = NO;
        self.filterTableViewController.accessToken = self.accessToken;
        [self.filterTableViewController resetPage];
        [self.filterTableViewController searchWithContent:@"開始搜尋"];
    } else {
        self.searchViewTitle.text = kSearch;
        self.searchViewIcon.hidden = NO;
        self.searchViewIcon.image = self.mirrorMagnifierImage;
        [self.filterTableViewController back];
        [self setOriginalTitle];
    }
}
- (IBAction)clickNavigationTitle:(UIButton *)sender {
    [self.filterTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - ManulViewControllerDelegate
- (void)manulConfirmClicked {
    [self.manulHospitalMenuViewController dismissViewControllerAnimated:YES completion:nil];
    self.hadShowManul = YES;
    if (self.manulHospitalMenuViewController.neverShowSwitch.on) {
        [Utilities setNeverShowManulMenuWithKey:kManulHospitalMenuKey];
    }
}

- (BOOL)allowActionToRun {
    return YES;
}

#pragma mark - ADBannerViewDelegate
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    NSLog(@"Banner view is beginning an ad action");
    BOOL shouldExecuteAction = [self allowActionToRun];
    if (!willLeave && shouldExecuteAction) {
        // insert code here to suspend any services that might conflict with the advertisement
    }
    return shouldExecuteAction;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [self layoutAnimated:YES];
}

- (void)layoutAnimated:(BOOL)animated {
    CGRect contentFrame = self.view.bounds;
    CGRect bannerFrame = self.adBannerView.frame;
    if (self.adBannerView.bannerLoaded) {
        contentFrame.size.height -= self.adBannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        self.adBannerView.frame = contentFrame;
        [self.adBannerView layoutIfNeeded];
        self.adBannerView.frame = bannerFrame;
    }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self layoutAnimated:YES];
}

- (IBAction)panInView:(UIPanGestureRecognizer *)recognizer {
    self.menuTransition.isInteraction = YES;
    self.transitioningDelegate = self.menuTransition;
    
    CGFloat percentageX = [recognizer translationInView:self.view.superview].x / self.view.superview.bounds.size.width;
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        if (percentageX > 0) {
            self.menuTransition.direction = DirectionRight;
            
            [self goHome];
            
        }
        return;
    }
    
    CGFloat percentage = 0.0;
    if (self.menuTransition.direction == DirectionRight) {
        percentage = percentageX;
    }
    [self.menuTransition updateInteractiveTransition:percentage];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGFloat velocityX = [recognizer velocityInView:recognizer.view.superview].x;
        
        BOOL cancel;
        CGFloat points;
        NSTimeInterval duration;
        if (self.menuTransition.direction == DirectionRight) {
            cancel = (percentageX < kThreshold);
            points = cancel ? recognizer.view.frame.origin.x : self.view.superview.bounds.size.width - recognizer.view.frame.origin.x;
            duration = points / velocityX;
        }
        
        if (duration < .2) {
            duration = .2;
        }else if(duration > .6){
            duration = .6;
        }
        
        cancel?[self.menuTransition cancelInteractiveTransitionWithDuration:duration]:[self.menuTransition finishInteractiveTransitionWithDuration:duration];
        
    } else if (recognizer.state == UIGestureRecognizerStateFailed){
        [self.menuTransition cancelInteractiveTransitionWithDuration:.35];
    }

}
@end
