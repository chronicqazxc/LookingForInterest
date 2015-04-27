//
//  LostPetCollectionViewCell.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/21/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetCollectionViewCell.h"
#import "LostPetDetailTableCell.h"
#import "LostPet.h"
#import "MarqueeLabel.h"
#import "GoogleMapNavigation.h"
#import "MarqueeLabel.h"

#define kPetImageWidth CGRectGetWidth([[UIScreen mainScreen] bounds])
#define kPetImageHeigh 300

@interface LostPetCollectionViewCell() <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) WKWebView *wkWebView;
@property (strong, nonatomic) UIImageView *lostPetImageView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIView *upperViewContainer;
@property (nonatomic) BOOL canLoadMap;
@end

@implementation LostPetCollectionViewCell

- (void)awakeFromNib {
    CGSize size = CGSizeMake([Utilities getScreenSize].width, 300);
    if (!self.upperViewContainer) {
        self.upperViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        [self addSubview:self.upperViewContainer];
    }
    if (!self.lostPetImageView) {
        self.lostPetImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.lostPetImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.upperViewContainer addSubview:self.lostPetImageView];
    }
    self.lostPetImageView.image = [UIImage imageNamed:@"background_img.png"];
    [self loadImage];
    
    self.canLoadMap = NO;
    if (!self.wkWebView) {
        self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        MarqueeLabel *marqueeLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, size.height - 30.0, size.width, 21.0)];
        marqueeLabel.text = @"地圖為利用google maps api將走失地點轉換而成，根據資料內容可能會有誤差，資料僅供參考！";
        marqueeLabel.textColor = [UIColor redColor];
        marqueeLabel.textAlignment = NSTextAlignmentCenter;
        marqueeLabel.marqueeType = MLContinuous;
        [self.wkWebView addSubview:marqueeLabel];
        
        self.wkWebView.navigationDelegate = self;
        [self.upperViewContainer addSubview:self.wkWebView];
    }
    [self.wkWebView loadHTMLString:@"<head><style>body{background-color:white; font-size:40px;}</style></head><body><H1><div align=\"center\">Loading...</div></H1></body>" baseURL:nil];
    
    [self showMapOrPictureByValue:self.showType];
    
    [self.tableView registerNib:[UINib nibWithNibName:kLostPetDetailTableCellIdentifier bundle:nil]
         forCellReuseIdentifier:kLostPetDetailTableCellIdentifier];
    
    self.tableView.dataSource = self;
    
    self.tableView.delegate = self;
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
    
    [self.tableView reloadData];
}

- (void)showMapOrPictureByValue:(LostPetScrollViewShowMapPictureType)value {
    if (value == LostPetScrollViewShowMap) {
        self.wkWebView.hidden = NO;
        self.lostPetImageView.hidden = YES;
    } else {
        self.wkWebView.hidden = YES;
        self.lostPetImageView.hidden = NO;
    }
    self.showType = value;
}

- (void)loadImage {
    dispatch_queue_t myQueue = dispatch_queue_create("Load image queue",NULL);
    dispatch_async(myQueue, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:kLostPetImageURL(self.lostPet.chipNumber)]];
        self.image = [UIImage imageWithData:imageData];
        if (self.image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lostPetImageView.alpha = 0.0;
                self.lostPetImageView.image = self.image;
                self.lostPetImageView.autoresizingMask =
                ( UIViewAutoresizingFlexibleBottomMargin
                 | UIViewAutoresizingFlexibleHeight
                 | UIViewAutoresizingFlexibleLeftMargin
                 | UIViewAutoresizingFlexibleRightMargin
                 | UIViewAutoresizingFlexibleTopMargin
                 | UIViewAutoresizingFlexibleWidth );
                [UIView animateWithDuration:1.0f animations:^{
                    self.lostPetImageView.alpha = 1.0;
                } completion:^(BOOL finished) {
                    
                }];
            });
        }
    });
}

- (void)wkWebView:(WKWebView *)wkWebView loadLocation:(NSString *)location size:(CGSize)size{
    
    NSString *width = [NSString stringWithFormat:@"%.f",size.width];
    NSString *height = [NSString stringWithFormat:@"%.f",size.height];
    NSLog(@"width:%.2f, height:%.2f",size.width, size.height);
    
    location = [location stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = kGoogleMapStaticMapURL(location,@"blue",width,height);
    
    NSLog(@"%@",urlString);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [wkWebView loadRequest:request];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LostPetDetailTableCell *lostPetDetailCell = [tableView dequeueReusableCellWithIdentifier:kLostPetDetailTableCellIdentifier];
    lostPetDetailCell.lostPetCollectionViewCell = self;
    lostPetDetailCell.lostPet = self.lostPet;
    [lostPetDetailCell settingContentsByLostPet:self.lostPet];
    lostPetDetailCell.backgroundColor = [UIColor clearColor];
    return lostPetDetailCell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    if (offset.y <= 0) {
        [self scaleItem:self.upperViewContainer];
        if (offset.y <= -50) {
            [self.tableView setContentOffset:CGPointMake(0, -50)];
        }
    } else if (y > h) {
        self.upperViewContainer.frame = CGRectMake(0, (h-y)*1.0, kPetImageWidth, kPetImageHeigh);
    }
}

- (void)scaleItem:(UIView *)item{
    CGFloat shiftInPercents = [self shiftInPercents];
    CGFloat buildigsScaleRatio = shiftInPercents;
    [item setTransform:CGAffineTransformMakeScale(buildigsScaleRatio,buildigsScaleRatio)];
}

-(CGFloat)shiftInPercents{
    return (-self.tableView.contentOffset.y/80)+1;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (!self.canLoadMap) {
        if (![self.lostPet.lostPlace isEqualToString:@""]) {
            CGSize size = CGSizeMake([Utilities getScreenSize].width, 300);
            [self wkWebView:self.wkWebView loadLocation:self.lostPet.lostPlace size:size];
        } else {
            [self.wkWebView loadHTMLString:@"<head><style>body{background-color:white; font-size:40px;}</style></head><body><H1><div align=\"center\">無走失地址</div></H1></body>" baseURL:nil];
        }
        self.canLoadMap = YES;
    }

}
@end