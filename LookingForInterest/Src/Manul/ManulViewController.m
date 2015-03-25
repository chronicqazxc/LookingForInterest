//
//  ManulMenuViewController.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 3/21/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "ManulViewController.h"
#import "FullScreenScrollView.h"

@interface ManulViewController ()
@property (strong, nonatomic) FullScreenScrollView *scrollView;
@end

@implementation ManulViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.pageControl.currentPage = 0;
    self.pageControl.hidesForSinglePage = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect frame = self.scrollViewContainer.frame;
    self.scrollView = [[FullScreenScrollView alloc] initWithImageViews:self.imageViews withFrame:frame minzoomingScale:1.0 maxzoomingScale:1.0 delegate:self];
    [self.scrollViewContainer addSubview:self.scrollView];
}

- (IBAction)confirmClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(manulConfirmClicked)]) {
        [self.delegate manulConfirmClicked];
    }
}

- (IBAction)neverShowSwitch:(UISwitch *)sender {
}

#pragma mark - FullScreenScrollViewDelegate
- (void)pageChanged:(int)currentPage {
    self.pageControl.currentPage = currentPage;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    self.buttonContainer.center = pt;
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    self.buttonContainer.center = pt;
}
@end
