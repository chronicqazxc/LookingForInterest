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
#import <WebKit/WebKit.h>
#import "WebViewController.h"

#define kScrollViewMaxScale 0.7
#define kScrollViewMinScale 0.3
#define kScrollViewContentHeight 1085

@interface AnimalHospitalViewController () <FullScreenScrollViewDelegate, EndlessScrollGeneratorDelegate, UIScrollViewDelegate, GMSMapViewDelegate, GMSPanoramaViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *mainContainer;
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
@property (nonatomic) CGSize instructionContanerSize;
- (IBAction)switchMapMode:(UISegmentedControl *)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapModeSwitch;
- (IBAction)switchDirectionMode:(UISegmentedControl *)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionModeSwitch;

@property (nonatomic) CGRect imageScrollFrame;
@property (nonatomic) BOOL isInitail;
@property (weak, nonatomic) IBOutlet UIView *instructionContainer;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel1;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel2;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel3;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel4;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel5;

@property (strong, nonatomic) NSMutableArray *totalRoutes;
@property (strong, nonatomic) NSMutableString *htmlString;

@property (weak, nonatomic) IBOutlet UIImageView *iconButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneCallButton;
@property (weak, nonatomic) IBOutlet UIButton *navigationButton;
@property (weak, nonatomic) IBOutlet UIButton *internetButton;

- (IBAction)callOut:(UIButton *)sender;
- (IBAction)navigate:(UIButton *)sender;
- (IBAction)surfWeb:(UIButton *)sender;

@property (strong, nonatomic) NSMutableArray *tableData;
@end

@implementation AnimalHospitalViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isInitail = YES;
        self.tableData = [NSMutableArray array];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.iconButton.hidden = YES;
    self.phoneCallButton.hidden = YES;
    self.navigationButton.hidden = YES;
    self.internetButton.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = self.store.name;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isInitail = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.isInitail) {
        [self initButtons];
        
        self.iconButton.hidden = NO;
        self.phoneCallButton.hidden = NO;
        self.navigationButton.hidden = NO;
        self.internetButton.hidden = NO;
        
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), kScrollViewContentHeight);
        self.imageScrollFrame = self.imageScrollContainer.frame;
        self.mapContainerFrame = self.mapContainer.frame;
        self.instructionContanerSize = self.instructionContainer.frame.size;
        
        self.instructionContainer.layer.masksToBounds = YES;
        self.instructionContainer.layer.borderColor = [UIColor grayColor].CGColor;
        self.instructionContainer.layer.borderWidth = 1.0;
        self.instructionContainer.layer.cornerRadius = 5.0;
        
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
        
        [self showMap];
        [self loadPathWithMode:kDirectionsModeDriving];
        [self placeMarker];
        
        [self.mapContainer bringSubviewToFront:self.mapModeSwitch];
        [self.mapContainer bringSubviewToFront:self.directionModeSwitch];
        
        self.isInitail = YES;
    }
}

- (void)initButtons {
    [self initCircleView:self.iconButton];
    [self initCircleView:self.phoneCallButton];
    [self initCircleView:self.navigationButton];
    [self initCircleView:self.internetButton];
    
//    [self setUpTouchEventsToButton:self.phoneCallButton];
//    [self setUpTouchEventsToButton:self.navigationButton];
//    [self setUpTouchEventsToButton:self.internetButton];
}

- (void)initCircleView:(UIView *)view {
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = CGRectGetHeight(view.frame)/2.0;
    view.layer.borderWidth = 1.0;
    if ([view isKindOfClass:[UIButton class]]) {
        view.layer.borderColor = ((UIButton *)view).titleLabel.textColor.CGColor;
    }
}

//- (void)setUpTouchEventsToButton:(UIButton *)button {
//    [button addTarget:self action:@selector(didTapButtonForHighlight:) forControlEvents:UIControlEventTouchDown];
//    [button addTarget:self action:@selector(didUnTapButtonForHighlight:) forControlEvents:UIControlEventTouchDragInside];
//    [button addTarget:self action:@selector(didUnTapButtonForHighlight:) forControlEvents:UIControlEventTouchDragOutside];
//    [button addTarget:self action:@selector(didUnTapButtonForHighlight:) forControlEvents:UIControlEventTouchCancel];
//}

//- (void)didTapButtonForHighlight:(UIButton *)button {
//    button.layer.borderColor = [UIColor blueColor].CGColor;
//    button.titleLabel.textColor = [UIColor blueColor];
//}

//- (void)didUnTapButtonForHighlight:(UIButton *)button {
//    button.titleLabel.textColor = [UIColor whiteColor];
//    button.layer.borderColor = button.titleLabel.textColor.CGColor;
//}

- (void)loadPathWithMode:(NSString *)mode {
    NSString *startLatitudeString = [NSString stringWithFormat:@"%f",self.start.latitude];
    NSString *startLongitudeString = [NSString stringWithFormat:@"%f",self.start.longitude];
    NSString *endLatitudeString = [NSString stringWithFormat:@"%f",self.destination.latitude];
    NSString *endLongitudeString = [NSString stringWithFormat:@"%f",self.destination.longitude];
    NSString *polyLineURLString = kPolylineURLString(startLatitudeString, startLongitudeString, endLatitudeString, endLongitudeString, mode);
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:polyLineURLString]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    NSDictionary *parseDataDic = nil;
    if (error == nil) {
        parseDataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    }
    if (parseDataDic && [[parseDataDic objectForKey:@"status"] isEqualToString:@"OK"]) {
        NSDictionary *route = [[parseDataDic objectForKey:@"routes"] firstObject];
        
        [self parseOverviewPolyline:[route objectForKey:@"overview_polyline"]];
        
        self.htmlString = [NSMutableString string];
        [self.htmlString appendFormat:@"<head><style>body{background-color:lightgray; font-size:40px;} table{border-collapse:collapse} table,td,th{padding:15px; border:1px solid blue; font-size:40px;} th{background-color:blue; color:white; font-size:40px;} p{color:red; font-size:40px;}</style></head>"];
        [self parseLegs:[route objectForKey:@"legs"]];
//        NSString *summary = [route objectForKey:@"summary"];
        NSString *warning = [[route objectForKey:@"warnings"] firstObject];
//        [self.htmlString appendFormat:@"<font size=\"3\">%@</font>",summary];
        if (warning) {
            [self.htmlString appendFormat:@"<p>%@</p>",warning];
        }
        [self loadHtmlWithStringContent:self.htmlString];
        
    }
    GMSMutablePath *path = [GMSMutablePath path];
    for (CLLocation *location in self.totalRoutes) {
        [path addCoordinate:location.coordinate];
    }
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.map = self.googleMap;
}


- (void)parseLegs:(NSArray *)legs {
//    NSLog(@"%@",legs);
    
    NSDictionary *leg = [legs firstObject];
    NSString *distance = [[leg objectForKey:@"distance"] objectForKey:@"text"];
    NSString *duration = [[leg objectForKey:@"duration"] objectForKey:@"text"];
    NSString *startAddress = [leg objectForKey:@"start_address"];
    NSString *endAddress = [leg objectForKey:@"end_address"];
//    NSLog(@"%@",[leg objectForKey:@"steps"]);
    
    [self.htmlString appendFormat:@"<dl><dt><b>Original</b></dt><dd>- %@</dd><dt><b>Destination</b></dt><dd>- %@</dd><dt><b>Distance</b></dt><dd>- %@</dd><dt><b>Duration</b></dt><dd>- %@</dd></dl>",startAddress,endAddress,distance,duration];
    [self.htmlString appendString:@"<table style=\"width:100%\" border>"];
    [self.htmlString appendString:@"<tr><th>Travel Mode</th><th>Distance</th><th>Duration</th><th>Steps</th></tr>"];
    for (NSDictionary *step in [leg objectForKey:@"steps"]) {
        [self parseStep:step];
    }
    [self.htmlString appendString:@"</table>"];
}

- (void)parseStep:(NSDictionary *)step {
    NSString *distance = [[step objectForKey:@"distance"] objectForKey:@"text"];
    NSString *duration = [[step objectForKey:@"duration"] objectForKey:@"text"];
    NSString *travelMode = [step objectForKey:@"travel_mode"];;
    NSString *instructions = [step objectForKey:@"html_instructions"];
//    NSString *travelMode = [step objectForKey:@"travel_mode"];
    NSLog(@"%@",instructions);
    [self.htmlString appendFormat:@"<tr><td>%@</td><td>%@</td><td>%@</td><td>%@</td><tr>",travelMode,distance, duration, instructions];
}

- (void)loadHtmlWithStringContent:(NSString *)content {
    WKWebView *wkwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0,0,self.instructionContanerSize.width,self.instructionContanerSize.height)];
    [wkwebView loadHTMLString:content baseURL:nil];
    [self.instructionContainer addSubview:wkwebView];
}

- (void)parseOverviewPolyline:(NSDictionary *)overviewPolyline {
    NSString *encodePolyline = [overviewPolyline objectForKey:@"points"];
    self.totalRoutes = [NSMutableArray array];
    NSMutableString *polyline = [NSMutableString stringWithString:encodePolyline];
    self.totalRoutes = [Utilities decodePolyLine:polyline];
}

- (void)placeMarker {
    GMSMarker *originalMarker = [[GMSMarker alloc] init];
    originalMarker.position = CLLocationCoordinate2DMake(self.start.latitude, self.start.longitude);
    originalMarker.appearAnimation = kGMSMarkerAnimationPop;
    originalMarker.snippet = @"起始位置";
    originalMarker.map = self.googleMap;
    
    GMSMarker *destinationMarker = [[GMSMarker alloc] init];
    destinationMarker.position = CLLocationCoordinate2DMake(self.destination.latitude, self.destination.longitude);
    destinationMarker.appearAnimation = kGMSMarkerAnimationPop;
    destinationMarker.snippet = self.store.name;
    destinationMarker.map = self.googleMap;
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
            [self.mapContainer bringSubviewToFront:self.directionModeSwitch];
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

- (IBAction)switchDirectionMode:(UISegmentedControl *)sender {
    [self.googleMap clear];
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self loadPathWithMode:kDirectionsModeDriving];
            break;
        case 1:
            [self loadPathWithMode:kDirectionsModeTransit];
            break;
        case 2:
            [self loadPathWithMode:kDirectionsModeWalking];
            break;
        default:
            break;
    }
    [self placeMarker];
}

- (IBAction)callOut:(UIButton *)sender {
    
    if ((NSNull *)self.store.phoneNumber == [NSNull null] ||
        !self.store.phoneNumber ||
        [self.store.phoneNumber isEqualToString:@""]) {
            UIAlertController *alert = [Utilities normalAlertWithTitle:kNoPhoneNumberAlertTitle message:kNoPhoneNumberAlertMessage store:self.store withSEL:@selector(surfWebWithStore:) byCaller:self];
            [self presentViewController:alert animated:YES completion:^{
                nil;
        }];
    }
}

- (void)surfWebWithStore:(Store *)store {
    WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    webViewController.keyword = store.name;
    webViewController.searchType = SearchWeb;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)navigate:(UIButton *)sender {
    NSString *directionMode = @"";
    switch (self.directionModeSwitch.selectedSegmentIndex) {
        case 0:
            directionMode = kDirectionsModeDriving;
            break;
        case 1:
            directionMode = kDirectionsModeTransit;
            break;
        case 2:
            directionMode = kDirectionsModeWalking;
            break;
        default:
            directionMode = kDirectionsModeDriving;
            break;
    }
    [Utilities launchNavigateWithStore:self.store startLocation:self.start andDirectionsMode:directionMode];
}

- (IBAction)surfWeb:(UIButton *)sender {
    [self surfWebWithStore:self.store];
}
@end
