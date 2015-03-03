//
//  MenuViewController.m
//  LookingForInterest
//
//  Created by Wayne on 3/3/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "MenuViewController.h"
#import "DialingButton.h"

@interface MenuViewController ()
@property (nonatomic) BOOL isInitial;
@property (nonatomic) BOOL isViewDidAppear;
@property (weak, nonatomic) IBOutlet DialingButton *adoptButton;
@property (weak, nonatomic) IBOutlet DialingButton *animalHospitalButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@end

@implementation MenuViewController
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isInitial = NO;
        self.isViewDidAppear = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adoptButton.hidden = YES;
    self.animalHospitalButton.hidden = YES;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://i.ytimg.com/vi/usasigkvhDY/hqdefault.jpg"]]];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            self.backgroundImageView.image = image;
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isViewDidAppear = YES;
    [self viewDidLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.isViewDidAppear && !self.isInitial) {
        [self initButtons];
        self.isInitial = YES;
    }
}

- (void)initButtons {
    [self initCircleView:self.adoptButton];
    [self initCircleView:self.animalHospitalButton];
    self.adoptButton.hidden = NO;
    self.animalHospitalButton.hidden = NO;
}

- (void)initCircleView:(UIView *)view {
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = CGRectGetHeight(view.frame)/2.0;
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
