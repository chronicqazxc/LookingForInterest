//
//  StoreTableHeaderViewController.m
//  LookingForInterest
//
//  Created by Wayne on 2/11/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "StoreTableHeaderViewController.h"
#import "GoTopButton.h"
#import "Utilities.h"

@interface StoreTableHeaderViewController ()

@end

@implementation StoreTableHeaderViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.goTopButton setTitleColor:UIColorFromRGB(0x006666) forState:UIControlStateNormal];
    [self.goTopButton setTitle:self.goTopButtonTitle?self.goTopButtonTitle:@"" forState:UIControlStateNormal];
    self.goTopButton.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    self.goTopButton.layer.masksToBounds = YES;
    self.goTopButton.layer.cornerRadius = 3.0;
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

- (IBAction)clickStoreTitle:(UIButton *)sender {
    if (self.caller && self.callBackMethod) {
        [self.caller performSelectorOnMainThread:self.callBackMethod withObject:nil waitUntilDone:NO];
    }
}
@end
