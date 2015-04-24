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
#import "AnimalHospitalRequest.h"
#import "DialingButton.h"
#import "MarqueeLabel.h"
#import <iAd/iAd.h>

#define kScrollViewMaxScale 0.7
#define kScrollViewMinScale 0.3

@interface AnimalHospitalViewController () <FullScreenScrollViewDelegate, EndlessScrollGeneratorDelegate, UIScrollViewDelegate, ADBannerViewDelegate, GMSMapViewDelegate, GMSPanoramaViewDelegate, AnimalHospitalRequestDelegate>
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
@property (weak, nonatomic) IBOutlet MarqueeLabel *noteLabel;

@property (nonatomic) CGRect imageScrollFrame;
@property (nonatomic) BOOL isInitail;
@property (nonatomic) BOOL isViewDidAppear;
@property (weak, nonatomic) IBOutlet UIView *instructionContainer;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel1;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel2;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel3;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel4;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel5;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (strong, nonatomic) NSMutableArray *totalRoutes;
@property (strong, nonatomic) NSMutableString *htmlString;

@property (weak, nonatomic) IBOutlet DialingButton *favoriteButton;
@property (weak, nonatomic) IBOutlet DialingButton *navigationButton;
@property (weak, nonatomic) IBOutlet DialingButton *internetButton;
@property (weak, nonatomic) IBOutlet DialingButton *findImageButton;

- (IBAction)clickFavorite:(DialingButton *)sender;
- (IBAction)navigate:(DialingButton *)sender;
- (IBAction)surfWebBySender:(DialingButton *)sender;

@property (strong, nonatomic) UIImageView *catImageView;
@property (strong, nonatomic) UIImageView *dogImageView;
@property (strong, nonatomic) UIImageView *animalsImageView;

@property (strong, nonatomic) NSMutableArray *requests;

@property (strong, nonatomic) AppDelegate *appdelegate;

@property (nonatomic) BOOL hadShowManul;
@property (weak, nonatomic) IBOutlet ADBannerView *adBannerView;
@end

@implementation AnimalHospitalViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isInitail = NO;
        self.isViewDidAppear = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.favoriteButton.hidden = YES;
    self.navigationButton.hidden = YES;
    self.internetButton.hidden = YES;
    self.findImageButton.hidden = YES;
    self.mapModeSwitch.hidden = YES;
    self.directionModeSwitch.hidden = YES;
    self.noteLabel.hidden = YES;
    self.catImageView = nil;
    self.dogImageView = nil;
    self.animalsImageView = nil;
    self.requests = [NSMutableArray array];
    self.appdelegate = [Utilities appdelegate];
    self.addressLabel.text = [NSString stringWithFormat:@"地址：%@",self.store.address];
    self.addressLabel.hidden = YES;
    self.adBannerView.delegate = self;
    
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
    self.isViewDidAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearRequestDelegate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self clearRequestDelegate];
}

- (void)clearRequestDelegate {
    for (RequestSender *requestSender in self.requests) {
        requestSender.delegate = nil;
    }
    self.requests = [NSMutableArray array];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.isViewDidAppear && !self.isInitail) {
//        [self getDefaultImages];
        
        [self initButtons];
        
        self.addressLabel.hidden = NO;
        self.favoriteButton.hidden = NO;
        self.navigationButton.hidden = NO;
        self.internetButton.hidden = NO;
        self.mapModeSwitch.hidden = NO;
        self.directionModeSwitch.hidden = NO;
        self.findImageButton.hidden = NO;
        self.noteLabel.hidden = NO;
        
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
        [self.mapContainer bringSubviewToFront:self.noteLabel];
        
        self.isInitail = YES;
    }
}

- (void)getDefaultImages {
    AnimalHospitalRequest *requestSender = [[AnimalHospitalRequest alloc] init];
    requestSender.animalHospitalRequestDelegate = self;
    requestSender.accessToken = self.accessToken;
    [requestSender sendDefaultImagesRequest];
    [self.requests addObject:requestSender];
    self.appdelegate.viewController = self;
    [Utilities startLoading];
}

- (void)initButtons {
    [self initDialingButton:self.favoriteButton];
    [self initDialingButton:self.navigationButton];
    [self initDialingButton:self.internetButton];
    [self initDialingButton:self.findImageButton];
    
    if ([Utilities isMyFavoriteStore:self.store]) {
        self.favoriteButton.borderColor = kColorIsFavoriteStore;
        [self.favoriteButton setTitle:kRemoveFromFavorite forState:UIControlStateNormal];
    } else {
        self.favoriteButton.borderColor = kColorNotFavoriteStore;
        [self.favoriteButton setTitle:kAddToFavorite forState:UIControlStateNormal];
    }
}

- (void)initDialingButton:(DialingButton *)button {
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5.0f;
}

- (void)loadPathWithMode:(NSString *)mode {
    [self loadHtmlWithStringContent:@"<head><style>body{background-color:white; font-size:40px;}</style></head><h1>Parsing...</h1>"];
    
    dispatch_queue_t myQueue = dispatch_queue_create("generate path",NULL);
    dispatch_async(myQueue, ^{
        
        NSString *startLatitudeString = [NSString stringWithFormat:@"%f",self.start.latitude];
        NSString *startLongitudeString = [NSString stringWithFormat:@"%f",self.start.longitude];
        NSString *endLatitudeString = [NSString stringWithFormat:@"%f",self.destination.latitude];
        NSString *endLongitudeString = [NSString stringWithFormat:@"%f",self.destination.longitude];
        NSString *polyLineURLString = kPolylineURLString(startLatitudeString, startLongitudeString, endLatitudeString, endLongitudeString, mode);
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:polyLineURLString]];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *parseDataDic = nil;
            NSError *error = nil;
            if (error == nil) {
                parseDataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            }
            if (parseDataDic && [[parseDataDic objectForKey:@"status"] isEqualToString:@"OK"]) {
                NSDictionary *route = [[parseDataDic objectForKey:@"routes"] firstObject];
                
                [self parseOverviewPolyline:[route objectForKey:@"overview_polyline"]];
                
                self.htmlString = [NSMutableString string];
                [self.htmlString appendFormat:@"<head><style>body{background-color:white; font-size:40px;} table{border-collapse:collapse} table,td,th{padding:15px; border:1px solid blue; font-size:40px;} th{background-color:blue; color:white; font-size:40px;} .warning{color:red; font-size:40px;} p{font-size:40px;}</style></head>"];
                [self.htmlString appendFormat:@"<h1>Route</h1>"];
                [self parseLegs:[route objectForKey:@"legs"]];
                //        NSString *summary = [route objectForKey:@"summary"];
                NSString *warning = [[route objectForKey:@"warnings"] firstObject];
                //        [self.htmlString appendFormat:@"<font size=\"3\">%@</font>",summary];
                if (warning) {
                    [self.htmlString appendFormat:@"<p class=\"warning\">%@</p>",warning];
                }
                [self.htmlString appendFormat:@"<p>更多路線請參考導航功能</p>"];
                [self loadHtmlWithStringContent:self.htmlString];
                
                GMSMutablePath *path = [GMSMutablePath path];
                for (CLLocation *location in self.totalRoutes) {
                    [path addCoordinate:location.coordinate];
                }
                GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
                polyline.map = self.googleMap;
            } else if (parseDataDic && [[parseDataDic objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"]) {
                [self loadHtmlWithStringContent:@"<head><style>body{background-color:white; font-size:40px;}</style></head><h1>無路徑...</h1>"];
            }
        });
    });

}

- (void)parseLegs:(NSArray *)legs {
    NSLog(@"legs:%lu",(unsigned long)[legs count]);
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
//    NSLog(@"%@",instructions);
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
            [self.mapContainer bringSubviewToFront:self.noteLabel];
            self.scrollView.scrollEnabled = YES;
            break;
        case 1:
            [self.googleMap removeFromSuperview];
            self.streetView = [GMSPanoramaView panoramaWithFrame:CGRectMake(0,0,CGRectGetWidth(self.mapContainer.frame),CGRectGetHeight(self.mapContainer.frame)) nearCoordinate:panoramaNear];
            self.myMarker.panoramaView = self.streetView;
            self.streetView.delegate = self;
            [self.mapContainer addSubview:self.streetView];
            [self.mapContainer bringSubviewToFront:self.mapModeSwitch];
            [self.scrollView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f) animated:YES];
            self.scrollView.scrollEnabled = NO;
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

- (IBAction)clickFavorite:(DialingButton *)sender {
    NSArray *favoriteStores = [Utilities getMyFavoriteStores];
    if ([favoriteStores containsObject:self.store.storeID]) {
        [Utilities removeFromMyFavoriteStore:self.store];
        [Utilities addHudViewTo:self withMessage:kRemoveFromFavorite];
        self.favoriteButton.borderColor = kColorNotFavoriteStore;
        [self.favoriteButton setTitle:kAddToFavorite forState:UIControlStateNormal];
    } else {
        [Utilities addToMyFavoriteStore:self.store];
        [Utilities addHudViewTo:self withMessage:kAddToFavorite];
        self.favoriteButton.borderColor = kColorIsFavoriteStore;
        [self.favoriteButton setTitle:kRemoveFromFavorite forState:UIControlStateNormal];
    }
}

- (void)surfWebWithStore:(Store *)store type:(SearchType)type{
    WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    webViewController.keyword = store.name;
    webViewController.searchType = type;
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
    [Utilities launchNavigateWithStore:self.store startLocation:self.start andDirectionsMode:directionMode controller:self];
}

- (IBAction)surfWebBySender:(DialingButton *)sender{
    if (sender.tag == 0) {
        [self surfWebWithStore:self.store type:SearchWeb];
    } else {
        [self surfWebWithStore:self.store type:SearchImage];
    }
}

#pragma mark - RequestSenderDelegate
- (void)defaultImagesIsBack:(NSArray *)datas {
    NSMutableArray *imagesArr = [NSMutableArray array];
    for (NSData *imageData in datas) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
        [imagesArr addObject:imageView];
    }
    [self reloadImage:0 withImages:imagesArr];
    [Utilities stopLoading];
}

- (void)requestFaildWithMessage:(NSString *)message connection:(NSURLConnection *)connection{
    [Utilities stopLoading];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"錯誤" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *reConnectAction = [UIAlertAction actionWithTitle:@"重新連線" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        RequestSender *requestSender = [[RequestSender alloc] init];
        requestSender.delegate = self;
        requestSender.accessToken = self.accessToken;
        [requestSender reconnect:connection];
        [self.requests addObject:requestSender];
        
        [Utilities startLoading];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:reConnectAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
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
    if ([self isADBannerViewHidden]) {
        [self showADBanner];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    if (![self isADBannerViewHidden]) {
        [self hideADBanner];
    }
}

- (void)showADBanner {
    [UIView animateWithDuration:1.0 animations:^{
        [self.adBannerView layoutIfNeeded];
        self.adBannerView.frame = CGRectMake(0,
                                             CGRectGetHeight(self.view.frame)-CGRectGetHeight(self.adBannerView.frame),
                                             CGRectGetWidth(self.adBannerView.frame),
                                             CGRectGetHeight(self.adBannerView.frame));
    }];
}

- (void)hideADBanner {
    self.adBannerView.hidden = NO;
    [UIView animateWithDuration:1.0 animations:^{
        [self.adBannerView layoutIfNeeded];
        self.adBannerView.frame = CGRectMake(0,
                                             CGRectGetHeight(self.view.frame),
                                             CGRectGetWidth(self.adBannerView.frame),
                                             CGRectGetHeight(self.adBannerView.frame));
    }];
}

- (BOOL)isADBannerViewHidden {
    return (CGRectGetMinY(self.adBannerView.frame) == CGRectGetHeight(self.view.frame));
}
@end
