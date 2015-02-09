//
//  ViewController.m
//  LookingForInterest
//
//  Created by Wayne on 2/9/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "FilterTableViewController.h"

#define kSearch @"開始找"
#define kBack @"上一頁"

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
    self.storesOnMap = [NSArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.isSendForMenu) {
        self.filterTableViewController = [[FilterTableViewController alloc] init];
        self.filterTableViewController.delegate = self;
        self.filterTableViewController.filterType = FilterTypeMenu;
        self.filterTableViewController.filterTableView = self.filterTableView;
        self.filterTableView.dataSource = self.filterTableViewController;
        self.filterTableView.delegate = self.filterTableViewController;
        [self.filterTableViewController sendInitRequest];
        
        self.isSendForMenu = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews NS_AVAILABLE_IOS(5_0) {
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
    //    self.googleMap.accessibilityElementsHidden = NO;
    
    self.marker = [[GMSMarker alloc] init];
    self.marker.position = self.currentLocation;
    self.marker.snippet = @"You clicked me!";
    self.marker.appearAnimation = kGMSMarkerAnimationPop;
    self.marker.map = self.googleMap;
    
    [self.mapView addSubview:self.googleMap];
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
    GMSCameraPosition *fancy = [GMSCameraPosition cameraWithLatitude:mapView.myLocation.coordinate.latitude longitude:mapView.myLocation.coordinate.longitude zoom:17 bearing:30 viewingAngle:45];
    [mapView setCamera:fancy];
    return YES;
}

#pragma mark - FilterTableViewControllerDelegate
-(void)tableBeTapIn:(NSIndexPath *)indexPath {
    NSString *storyboardID = [self.filterTableViewController getStoryboardID];
    FilterTableViewController *filterTableViewController = nil;
    switch (indexPath.row) {
        case 0:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = FilterTypeMajorType;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        case 1:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = FilterTypeMinorType;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        case 2:
            filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
            filterTableViewController.filterType = FilterTypeRange;
            filterTableViewController.notifyReceiver = self.filterTableViewController;
            [self.navigationController pushViewController:filterTableViewController animated:YES];
            break;
        default:
            break;
    }
}

- (void)storeBeTapIn:(NSIndexPath *)indexPath {
    Store *store = [self.storesOnMap objectAtIndex:indexPath.row];
    GMSCameraPosition *fancy = [GMSCameraPosition cameraWithLatitude:[store.latitude doubleValue] longitude:[store.longitude doubleValue] zoom:16 bearing:30 viewingAngle:0];
    [self.googleMap setCamera:fancy];
}

- (CLLocationCoordinate2D)sendLocationBack {
    
    return CLLocationCoordinate2DMake(25.0525463, 121.5560048);
}

- (void)reloadMapByStores:(NSArray *)stores {
    self.storesOnMap = stores;
    for (Store *store in stores) {
        GMSMarker *storeMark = [[GMSMarker alloc] init];
        storeMark.position = CLLocationCoordinate2DMake([store.latitude doubleValue],[store.longitude doubleValue]);
        storeMark.appearAnimation = kGMSMarkerAnimationPop;
        storeMark.snippet = store.name;
        storeMark.icon = [UIImage imageNamed:@"Icon-Small@3x.png"];
        storeMark.map = self.googleMap;
    }
}

- (UIView *)getContentView {
    return self.mapView;
}
#pragma mark -
- (IBAction)buttonClicked:(UIButton *)sender {
    if ([self.button.titleLabel.text isEqualToString:kSearch]) {
        [self.button setTitle:kBack forState:UIControlStateNormal];
        [self.filterTableViewController search];
    } else {
        [self.button setTitle:kSearch forState:UIControlStateNormal];
        [self.filterTableViewController back];
    }
}
@end
