//
//  AnimalHospitalViewController.m
//  LookingForInterest
//
//  Created by Wayne on 2/25/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AnimalHospitalViewController.h"
#import "FullScreenScrollView.h"
#import "EndlessScrollGenerator.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapNavigation.h"

#define kScrollViewMaxScale 0.7
#define kScrollViewMinScale 0.3

@interface AnimalHospitalViewController () <FullScreenScrollViewDelegate, EndlessScrollGeneratorDelegate, UIScrollViewDelegate, GMSMapViewDelegate, GMSPanoramaViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) NSMutableArray *imageViews;
@property (strong, nonatomic) FullScreenScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *imageScrollContainer;
@property (strong, nonatomic) GMSMapView *googleMap;
@property (strong, nonatomic) GMSGeocoder *gmsGeoCoder;
@property (strong, nonatomic) GMSMarker *myMarker;
@property (strong, nonatomic) GMSPanoramaView *streetView;
@property (nonatomic) CLLocationCoordinate2D myMarkerLocation;
@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (nonatomic) CGRect mapContainerFrame;
- (IBAction)switchMapMode:(UISegmentedControl *)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapModeSwitch;

@property (nonatomic) CGRect imageScrollFrame;
@property (nonatomic) BOOL isInitail;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel1;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel2;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel3;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel4;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel5;

@property (strong, nonatomic) NSMutableArray *totalRoutes;
@end

@implementation AnimalHospitalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isInitail = NO;
    self.navigationItem.title = self.store.name;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.isInitail) {
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), 1163);
        self.imageScrollFrame = self.imageScrollContainer.frame;
        
        self.mapContainerFrame = self.mapContainer.frame;
        
        self.textView.layer.masksToBounds = YES;
        self.textView.layer.borderColor = [UIColor grayColor].CGColor;
        self.textView.layer.borderWidth = 1.0;
        self.textView.layer.cornerRadius = 5.0;
        
        self.imageScrollContainer.layer.masksToBounds = YES;
        self.imageScrollContainer.layer.borderColor = [UIColor grayColor].CGColor;
        self.imageScrollContainer.layer.borderWidth = 1.0;
        self.imageScrollContainer.layer.cornerRadius = 5.0;
        
        self.mapContainer.layer.masksToBounds = YES;
        self.mapContainer.layer.borderColor = [UIColor grayColor].CGColor;
        self.mapContainer.layer.borderWidth = 1.0;
        self.mapContainer.layer.cornerRadius = 5.0;
        
        // Override point for customization after application launch.
        dispatch_queue_t myQueue = dispatch_queue_create("Download images",NULL);
        dispatch_async(myQueue, ^{
            // Perform long running process
            NSData *data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"http://static.adzerk.net/Advertisers/d47c809dea6241b9933a81fe1d0f7085.jpg"]];
            NSData *data2 = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://www.gravatar.com/avatar/01a51566f6163e6e9608b7c1f80ec258?s=32&d=identicon&r=PG"]];
            NSData *data3 = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://www.gravatar.com/avatar/92fb4563ddc5ceeaa8b19b60a7a172f4?s=32&d=identicon&r=PG"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                if (data != nil && data2 != nil && data3 != nil) {
//                    self.imageViews = [NSMutableArray array];
                    NSMutableArray *imageViews = [NSMutableArray array];
                    [imageViews addObject:[[UIImageView alloc] initWithImage:[UIImage imageWithData: data]]];
                    [imageViews addObject:[[UIImageView alloc] initWithImage:[UIImage imageWithData: data2]]];
                    [imageViews addObject:[[UIImageView alloc] initWithImage:[UIImage imageWithData: data3]]];
                    [self reloadImage:0 withImages:imageViews];
                } else {
                    return;
                }
            });
        });
        
        self.infoLabel1.text = self.detail.otherInfo1;
        self.infoLabel2.text = self.detail.otherInfo2;
        self.infoLabel3.text = self.detail.otherInfo3;
        self.infoLabel4.text = self.detail.otherInfo4;
        self.infoLabel5.text = self.detail.otherInfo5;
        
        [self loadPath];
        
        [self showMap];
        
        self.isInitail = YES;
    }
}

- (void)loadPath {
    NSString *startLatitudeString = [NSString stringWithFormat:@"%f",self.start.latitude];
    NSString *startLongitudeString = [NSString stringWithFormat:@"%f",self.start.longitude];
    NSString *endLatitudeString = [NSString stringWithFormat:@"%f",self.destination.latitude];
    NSString *endLongitudeString = [NSString stringWithFormat:@"%f",self.destination.longitude];
    NSString *polyLineURLString = kPolylineURLString(startLatitudeString, startLongitudeString, endLatitudeString, endLongitudeString, kDirectionsModeDriving);
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:polyLineURLString]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    NSDictionary *parseDataDic = nil;
    if (error == nil) {
        parseDataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    }
    if (parseDataDic) {
        NSLog(@"%@",parseDataDic);
        NSString *encodePolyline = [[[[parseDataDic objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"overview_polyline"] objectForKey:@"points"];
        self.totalRoutes = [NSMutableArray array];
        NSMutableString *polyline = [NSMutableString stringWithString:encodePolyline];
        self.totalRoutes = [self decodePolyLine:polyline];
    }
    NSLog(@"%@",self.totalRoutes);
}

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
        NSLog(@"%f,%f",[latitude floatValue],[longitude floatValue]);
    }
    return array;
}

- (void)showMap {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.start.latitude longitude:self.start.longitude zoom:16];
    self.googleMap = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.mapContainerFrame.size.width, self.mapContainerFrame.size.height) camera:camera];
    self.googleMap.delegate = self;
    self.googleMap.settings.myLocationButton = YES;
    self.googleMap.myLocationEnabled = YES;
    self.googleMap.settings.compassButton = YES;
    self.googleMap.accessibilityElementsHidden = NO;
    [self.mapContainer addSubview:self.googleMap];
    [self.mapContainer bringSubviewToFront:self.mapModeSwitch];
}

- (void)reloadImage:(NSUInteger)index withImages:(NSMutableArray *)images {
    CGRect screenRect = self.imageScrollFrame;
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    self.imageScrollView = [[FullScreenScrollView alloc] init];
    EndlessScrollGenerator *generator = [[EndlessScrollGenerator alloc] initWithScrollViewContainer:self];
    NSMutableArray *newData = [generator setUpData:images];
    self.imageScrollView = [[FullScreenScrollView alloc] initWithImageViews:newData withFrame:CGRectMake(0,
                                                                                                    0,
                                                                                                    screenWidth,
                                                                                                    screenHeight)
                                                       minzoomingScale:kScrollViewMinScale maxzoomingScale:kScrollViewMaxScale delegate:self];
    [self.imageScrollContainer addSubview:self.imageScrollView];
    [generator setUpScrollView:self.imageScrollView];
    [generator startPaging];
}

#pragma mark - FullScreenScrollViewDelegate
- (void)pageChanged:(int)currentPage {
    switch (currentPage) {
        case 0:
            NSLog(@"0");
            break;
        case 1:
            NSLog(@"1");
            break;
        case 2:
            NSLog(@"2");
            break;
        default:
            break;
    }
}

- (void)nextPageNotify {
//    NSLog(@"nextPageNotify");
}

- (void)previousPageNotify {
//    NSLog(@"previousPageNotify");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)switchMapMode:(UISegmentedControl *)sender {
    CLLocationCoordinate2D panoramaNear = self.myMarkerLocation;
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.streetView removeFromSuperview];
            [self.mapContainer addSubview:self.googleMap];
            [self.mapContainer bringSubviewToFront:self.mapModeSwitch];
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), 1163);
            break;
        case 1:
            [self.googleMap removeFromSuperview];
            self.streetView = [GMSPanoramaView panoramaWithFrame:CGRectMake(0,0,CGRectGetWidth(self.mapContainer.frame),CGRectGetHeight(self.mapContainer.frame)) nearCoordinate:panoramaNear];
            self.myMarker.panoramaView = self.streetView;
            self.streetView.delegate = self;
            [self.mapContainer addSubview:self.streetView];
            [self.mapContainer bringSubviewToFront:self.mapModeSwitch];
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.view.frame));
            break;
        default:
            break;
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

//- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
//    //selectedStoreIndexPath
//    
//    Store *store = nil;
//    for (int i=0; i<[self.storesOnMap count]; i++) {
//        store = [self.storesOnMap objectAtIndex:i];
//        if ([store.storeID isEqualToString:marker.title]) {
//            self.filterTableViewController.selectedStoreIndexPath = [NSIndexPath indexPathForRow:i inSection:1];
//            break;
//        }
//    }
//    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
//    view.backgroundColor = [UIColor yellowColor];
//    return view;
//}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
//    [self.googleMap clear];
    if (!self.myMarker) {
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
    //    storeMark.title = store.storeID;
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

#pragma mark - GMSPanoramaViewDelegate
- (BOOL)panoramaView:(GMSPanoramaView *)panoramaView didTapMarker:(GMSMarker *)marker {
    return YES;
}
@end
