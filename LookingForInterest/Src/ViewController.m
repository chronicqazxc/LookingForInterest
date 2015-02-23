//
//  ViewController.m
//  LookingForInterest
//
//  Created by Wayne on 2/9/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "ViewController.h"
#import "FilterTableViewController.h"
#import "LookingForInterest.h"
#import "WebViewController.h"

#define kMagnifierImg @"iconmonstr-magnifier-3-icon-256.png"
#define kLeftArrowImg @"arrow-left@2x.png"

#define kSearch @"開始找"
#define kBack @"返回"
#define kTitle @"目前位置附近的動物醫院"
#define kFormattedTitle(title) [NSString stringWithFormat:@"找%@",title]

#define kOptionsTitle(title) title?title:@""
#define kOptionMessage(message) message?message:@""
#define kCallActionTitle @"撥打電話"
#define kWebSiteActionTitle @"網路搜尋更多資訊"
#define kRateActionTitle @"我要評分"
#define kRateActionStreetView @"瀏覽街景"
#define kPicturesActionTitle @"瀏覽店家圖片"
#define kNavigateActionTitle @"導航"
#define kCloseActionTitle @"關閉"

#define kNoPhoneNumberAlertTitle @"Opps!"
#define kNoPhoneNumberAlertMessage @"資料庫中沒有建立電話號碼"

#define kGoogleMapType kGoogleMapTypeCallback
#define kGoogleMapTypeNormal @"comgooglemaps://"
#define kGoogleMapTypeCallback @"comgooglemaps-x-callback://"

#define kNavigateURLString(startLatitude, startLongitude, endLatitude, endLongitude, centerLatitude, centerLongitude, directionsMode, zoom) [NSString stringWithFormat:@"%@?saddr=%f,%f&daddr=%f,%f&center=%f,%f&directionsmode=%@&zoom=%d&x-success=animalhospital://?resume=true&x-source=thingsaboutpets",kGoogleMapType ,startLatitude, startLongitude, endLatitude, endLongitude, centerLatitude, centerLongitude, directionsMode, zoom]

#define kDirectionsModeDrivingTitle @"開車"
#define kDirectionsModeTransitTitle @"大眾交通工具"
#define kDirectionsModeBicyclingTitle @"腳踏車"
#define kDirectionsModeWalkingTitle @"走路"

#define kDirectionsModeDriving @"driving"
#define kDirectionsModeTransit @"transit"
#define kDirectionsModeBicycling @"bicycling"
#define kDirectionsModeWalking @"walking"

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
@property (strong, nonatomic) GMSMapView *googleMap;
@property (strong, nonatomic) GMSMarker *marker;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.mirrorMagnifierImage = [Utilities rotateImage:[UIImage imageNamed:kMagnifierImg] toDirection:DirectionMirror withScale:1.0];
    self.searchViewIcon.image = self.mirrorMagnifierImage;
    [self setOriginalTitle];
}

- (void)setOriginalTitle {
    [self.navigationButton setTitle:kTitle forState:UIControlStateNormal];
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
        if ([store.storeID isEqualToString:marker.title]) {
            self.filterTableViewController.selectedStoreIndexPath = [NSIndexPath indexPathForRow:i inSection:1];
            break;
        }
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    view.backgroundColor = [UIColor yellowColor];
    return view;
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    
}

/**
 * Called when dragging has been initiated on a marker.
 */
- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    
}

/**
 * Called after dragging of a marker ended.
 */
- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    
}

/**
 * Called while a marker is dragged.
 */
- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker {
    
}

#pragma mark - FilterTableViewControllerDelegate
- (void)setAccessTokenValue:(NSString *)accessToken {
    self.accessToken = accessToken;
    self.filterTableViewController.accessToken = self.accessToken;
    [self.filterTableViewController sendInitRequest];    
}

-(void)tableBeTapIn:(NSIndexPath *)indexPath {
    NSString *storyboardID = [self.filterTableViewController getStoryboardID];
    FilterTableViewController *filterTableViewController = nil;
    switch (indexPath.row) {
        case 0:
//            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
//            filterTableViewController.filterType = FilterTypeMajorType;
//            filterTableViewController.notifyReceiver = self.filterTableViewController;
//            filterTableViewController.accessToken = self.accessToken;
//            [self.navigationController pushViewController:filterTableViewController animated:YES];
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = FilterTypeMenuTypes;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        case 1:
//            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
//            filterTableViewController.filterType = FilterTypeMinorType;
//            filterTableViewController.notifyReceiver = self.filterTableViewController;
//            filterTableViewController.accessToken = self.accessToken;
//            [self.navigationController pushViewController:filterTableViewController animated:YES];
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = FilterTypeRange;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            filterTableViewController.accessToken = self.accessToken;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
//        case 2:
//            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
//            filterTableViewController.filterType = FilterTypeRange;
//            filterTableViewController.notifyReceiver = self.filterTableViewController;
//            filterTableViewController.accessToken = self.accessToken;            
//            [self.navigationController pushViewController:filterTableViewController animated:YES];
//            break;
        default:
            break;
    }
}

- (void)storeBeTapIn:(NSIndexPath *)indexPath {
    Store *store = [self.storesOnMap objectAtIndex:indexPath.row];
    GMSCameraPosition *fancy = [GMSCameraPosition cameraWithLatitude:[store.latitude doubleValue] longitude:[store.longitude doubleValue] zoom:16 bearing:0 viewingAngle:0];
    [self.googleMap setCamera:fancy];
}

- (CLLocationCoordinate2D)sendLocationBack {
    
    return self.currentLocation;
}

- (void)reloadMapByStores:(NSArray *)stores withZoomLevel:(NSUInteger)zoom{
    GMSCameraPosition *fancy = [GMSCameraPosition cameraWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude zoom:zoom bearing:0 viewingAngle:0];
    [self.googleMap setCamera:fancy];
    
    self.storesOnMap = stores;
    for (Store *store in stores) {
        GMSMarker *storeMark = [[GMSMarker alloc] init];
        storeMark.position = CLLocationCoordinate2DMake([store.latitude doubleValue],[store.longitude doubleValue]);
        storeMark.appearAnimation = kGMSMarkerAnimationPop;
        storeMark.snippet = store.name;
        storeMark.title = store.storeID;
        storeMark.map = self.googleMap;
    }
}

- (UIView *)getContentView {
    return self.googleMap;
}

- (CGSize)getContentSize {
    return self.mapViewSize;
}

- (void)changeTitle:(NSString *)title {
    [self setFormattedTitle:title];
}

- (void)showOptionsWithStore:(Store *)store {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kOptionsTitle(store.name) message:kOptionMessage(@"你可以") preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *callAction = [UIAlertAction actionWithTitle:kCallActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (((NSNull *)store.phoneNumber == [NSNull null]) ||
            !store.phoneNumber ||
            [store.phoneNumber isEqualToString:@""]) {
            UIAlertController *alert = [self normalAlertWithTitle:kNoPhoneNumberAlertTitle message:kNoPhoneNumberAlertMessage store:store];
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
    
//    UIAlertAction *rateAction = [UIAlertAction actionWithTitle:kRateActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        NSLog(@"rate");
//    }];
    
    UIAlertAction *streetViewAction = [UIAlertAction actionWithTitle:kRateActionStreetView style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"street view");
        CLLocationCoordinate2D panoramaNear = {[store.latitude doubleValue],[store.longitude doubleValue]};
        
        GMSPanoramaView *panoView = [GMSPanoramaView panoramaWithFrame:CGRectZero nearCoordinate:panoramaNear];
        
        UIViewController *streetViewController = [[UIViewController alloc] init];
        streetViewController.view = panoView;
        streetViewController.navigationItem.title = store.name;
        [self.navigationController pushViewController:streetViewController animated:YES];
        
    }];
    
    UIAlertAction *pictureAction = [UIAlertAction actionWithTitle:kPicturesActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSLog(@"picture");
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ok" message:@"test" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *webSiteAction = [UIAlertAction actionWithTitle:kWebSiteActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            NSLog(@"web site");
//            WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
//            webViewController.keyword = store.name;
//            webViewController.searchType = SearchImage;
//            [self.navigationController pushViewController:webViewController animated:YES];
//        }];
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//            NSLog(@"click cancel!");
//        }];
//        [alertController addAction:webSiteAction];
//        [alertController addAction:okAction];
//        [self presentViewController:alertController animated:YES completion:nil];
        
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
//    [alertController addAction:rateAction];
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
    [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kGoogleMapType]];
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:kGoogleMapType]]) {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:kNavigateURLString(self.currentLocation.latitude, self.currentLocation.longitude, [store.latitude doubleValue], [store.longitude doubleValue], self.currentLocation.latitude, self.currentLocation.longitude, directionsMode,6)]];
    } else {
        NSLog(@"Can't use comgooglemaps://");
    }
}

- (UIAlertController *)normalAlertWithTitle:(NSString *)title message:(NSString *)message store:(Store *)store{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *webSiteAction = [UIAlertAction actionWithTitle:kWebSiteActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"web site");
        WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
        webViewController.keyword = store.name;
        webViewController.searchType = SearchWeb;
        [self.navigationController pushViewController:webViewController animated:YES];
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"click cancel!");
    }];
    
    [alertController addAction:webSiteAction];
    [alertController addAction:okAction];
    
    return alertController;
}

#pragma mark -
- (IBAction)buttonClicked:(UIButton *)sender {
    if ([self.searchViewTitle.text isEqualToString:kSearch]) {
        [self.googleMap clear];
        self.searchViewTitle.text = kBack;
        self.searchViewIcon.image = [UIImage imageNamed:kLeftArrowImg];
        self.searchViewIcon.hidden = NO;
        self.filterTableViewController.accessToken = self.accessToken;
        [self.filterTableViewController search];
    } else {
        self.searchViewTitle.text = kSearch;
        self.searchViewIcon.hidden = NO;
        self.searchViewIcon.image = self.mirrorMagnifierImage;
        [self.filterTableViewController back];
        [self setOriginalTitle];
    }
}
- (IBAction)clickNavigationTitle:(UIButton *)sender {
    [self.filterTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}
@end
