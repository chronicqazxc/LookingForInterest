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

#define kScrollViewMaxScale 0.7
#define kScrollViewMinScale 0.3

@interface AnimalHospitalViewController () <FullScreenScrollViewDelegate, EndlessScrollGeneratorDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) NSMutableArray *imageViews;
@property (strong, nonatomic) FullScreenScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *imageScrollContainer;
@property (nonatomic) CGRect imageScrollFrame;
@property (nonatomic) BOOL isInitail;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel1;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel2;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel3;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel4;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel5;

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
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.isInitail) {
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), 1163);
        self.imageScrollFrame = self.imageScrollContainer.frame;
        
        self.textView.layer.masksToBounds = YES;
        self.textView.layer.borderColor = [UIColor grayColor].CGColor;
        self.textView.layer.borderWidth = 1.0;
        self.textView.layer.cornerRadius = 5.0;
        
        self.imageScrollContainer.layer.masksToBounds = YES;
        self.imageScrollContainer.layer.borderColor = [UIColor grayColor].CGColor;
        self.imageScrollContainer.layer.borderWidth = 1.0;
        self.imageScrollContainer.layer.cornerRadius = 5.0;
        
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
        
        self.isInitail = YES;
    }
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

@end
