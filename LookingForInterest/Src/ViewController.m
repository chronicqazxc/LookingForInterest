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
#import "RequestSender.h"

#define kMagnifierImg @"iconmonstr-magnifier-3-icon-256.png"
#define kLeftArrowImg @"arrow-left@2x.png"

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
#define kPicturesActionTitle @"瀏覽店家圖片"
#define kNavigateActionTitle @"導航"
#define kCloseActionTitle @"關閉"

// call
// web site
// rate
// pictures
// navigate
// close

@interface ViewController () <CLLocationManagerDelegate, GMSMapViewDelegate, FilterTableViewControllerDelegate>
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
@property (strong, nonatomic) AppDelegate *appDelegate;

@property (weak, nonatomic) IBOutlet UIView *previousPageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *previousPageIndicator;
@property (weak, nonatomic) IBOutlet UIView *nextPageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *nextPageIndicator;
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
    self.accessToken = @"";
    self.appDelegate = [Utilities appdelegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ) {
        NSLog(@"%@",@"請開啟定位服務");
    }
    
    self.previousPageView.hidden = YES;
    self.nextPageView.hidden = YES;
    self.mirrorMagnifierImage = [Utilities rotateImage:[UIImage imageNamed:kMagnifierImg] toDirection:DirectionMirror withScale:1.0];
    self.searchViewIcon.image = self.mirrorMagnifierImage;
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
    for (RequestSender *requestSender in requestSenders) {
        requestSender.delegate = nil;
    }
    [self.filterTableViewController resetRequestArr];
}

- (void)setOriginalTitle {
    [self.navigationButton setTitle:kFormattedTitle(kTitleCurrentPosition) forState:UIControlStateNormal];
}

- (void)setFormattedTitle:(NSString *)title {
    [self.navigationButton setTitle:kFormattedTitle(title) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isSendForMenu) {
        self.filterTableViewController = [[FilterTableViewController alloc] init];
        self.filterTableViewController.delegate = self;
        self.filterTableViewController.filterType = FilterTypeMenu;
        self.filterTableViewController.filterTableView = self.filterTableView;
        self.filterTableView.dataSource = self.filterTableViewController;
        self.filterTableView.delegate = self.filterTableViewController;
        [self.filterTableViewController sendAccessTokenRequest];
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
    
//    [self.mapView addSubview:self.googleMap];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
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
    //selectedStoreIndexPath
    Store *store = nil;
    for (int i=0; i<[self.storesOnMap count]; i++) {
        store = [self.storesOnMap objectAtIndex:i];
        NSString *markerTitle = [NSString stringWithFormat:@"%@",marker.title];
        NSString *storeTitle = [NSString stringWithFormat:@"%@",store.storeID];
        if ([storeTitle isEqualToString:markerTitle]) {
            self.filterTableViewController.selectedStoreIndexPath = [NSIndexPath indexPathForRow:i inSection:1];
            break;
        }
    }
    
    UIView *markerInfoView = [[UIView alloc] initWithFrame:CGRectMake(0,0,290,100)];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:markerInfoView.bounds];
    
    markerInfoView.layer.masksToBounds = NO;
    markerInfoView.layer.cornerRadius = 5.0f;
    markerInfoView.layer.shadowColor = [UIColor blackColor].CGColor;
    markerInfoView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    markerInfoView.layer.shadowOpacity = 0.5f;
    markerInfoView.layer.shadowPath = shadowPath.CGPath;
    markerInfoView.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 237, 21)];
    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 41, 280, 21)];
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 63, 280, 21)];
    titleLabel.font = [UIFont systemFontOfSize:24];
    distanceLabel.textColor = [UIColor lightGrayColor];
    addressLabel.numberOfLines = 0;
    if (store) {
        titleLabel.text = store.name;
        distanceLabel.text = [NSString stringWithFormat:@"距離%.2f公里",[store.distance doubleValue]];
        addressLabel.text = store.address;
    } else {
        titleLabel.text = @"";
        distanceLabel.text = @"";
        addressLabel.text = @"";
    }
    [markerInfoView addSubview:titleLabel];
    [markerInfoView addSubview:distanceLabel];
    [markerInfoView addSubview:addressLabel];
    
    [self.view setNeedsDisplay];
    
    return markerInfoView;
}


- (void)clickMarkerInfoDetail:(UIButton *)sender {
    [self.filterTableViewController tableView:self.filterTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:1]];
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
    self.myMarkerLocation = marker.position;
}

/**
 * Called while a marker is dragged.
 */
- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker {
//    marker.icon = [GMSMarker markerImageWithColor:[UIColor yellowColor]];
}

#pragma mark - FilterTableViewControllerDelegate
- (void)setAccessTokenValue:(NSString *)accessToken {
    self.accessToken = accessToken;
    self.filterTableViewController.accessToken = self.accessToken;
    [self.filterTableViewController sendInitRequest];    
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
            filterTableViewController.filterType = FilterTypeMenuTypes;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        case 1:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = FilterTypeRange;
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
            filterTableViewController.filterType = FilterTypeMenuTypes;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        case 1:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = FilterTypeCity;
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
    filterTableViewController.filterType = FilterTypeMenuTypes;
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
            filterTableViewController.filterType = FilterTypeMenuTypes;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        case 1:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = FilterTypeRange;
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
            filterTableViewController.filterType = FilterTypeMenuTypes;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        case 1:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = FilterTypeRange;
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
            filterTableViewController.filterType = FilterTypeMenuTypes;
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
    circ.fillColor = [UIColor colorWithRed:0.25 green:0 blue:0 alpha:0.25];
    circ.strokeColor = [UIColor blueColor];
    circ.strokeWidth = 1;
    circ.map = self.googleMap;
    
    GMSCameraPosition *fancy = [GMSCameraPosition cameraWithLatitude:location.latitude longitude:location.longitude zoom:zoom bearing:0 viewingAngle:0];
    [self.googleMap setCamera:fancy];
    
    if (pageController.currentPage == 1 && pageController.totalPage != 1) {
        self.previousPageView.hidden = YES;
        self.nextPageView.hidden = NO;
    } else if (pageController.currentPage == pageController.totalPage && pageController.currentPage != 1) {
        self.previousPageView.hidden = NO;
        self.nextPageView.hidden = YES;
    } else if (pageController.totalPage == 1) {
        self.previousPageView.hidden = YES;
        self.nextPageView.hidden = YES;
    } else {
        self.previousPageView.hidden = NO;
        self.nextPageView.hidden = NO;
    }
    [self.previousPageIndicator stopAnimating];
    [self.nextPageIndicator stopAnimating];
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

- (void)surfWebWithStore:(Store *)store {
    WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    webViewController.keyword = store.name;
    webViewController.searchType = SearchWeb;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)showOptionsWithStore:(Store *)store {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kOptionsTitle(store.name) message:kOptionMessage(@"你可以") preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *callAction = [UIAlertAction actionWithTitle:kCallActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ((NSNull *)store.phoneNumber == [NSNull null] ||
            !store.phoneNumber ||
            [store.phoneNumber isEqualToString:@""]) {
            UIAlertController *alert = [Utilities normalAlertWithTitle:kNoPhoneNumberAlertTitle message:kNoPhoneNumberAlertMessage store:store withSEL:@selector(surfWebWithStore:) byCaller:self];
            [self presentViewController:alert animated:YES completion:^{
                NSLog(@"click ok!");
            }];
        }
    }];
    
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
    
    [alertController addAction:callAction];
    [alertController addAction:webSiteAction];
    [alertController addAction:streetViewAction];
    [alertController addAction:pictureAction];
    [alertController addAction:navigateAction];
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
    [Utilities launchNavigateWithStore:store startLocation:location andDirectionsMode:directionsMode];
}

- (void)loadPreviousPage:(PageController *)pageController {
    [self resetMap];
    [self.previousPageIndicator startAnimating];
}

- (void)loadNextPage:(PageController *)pageController {
    [self resetMap];
    [self.nextPageIndicator startAnimating];
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
        [self.filterTableViewController search];
    } else {
        self.searchViewTitle.text = kSearch;
        self.searchViewIcon.hidden = NO;
        self.searchViewIcon.image = self.mirrorMagnifierImage;
        [self.filterTableViewController back];
        [self setOriginalTitle];
        self.previousPageView.hidden = YES;
        self.nextPageView.hidden = YES;
        [self.previousPageIndicator stopAnimating];
        [self.nextPageIndicator stopAnimating];
    }
}
- (IBAction)clickNavigationTitle:(UIButton *)sender {
    [self.filterTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
@end
