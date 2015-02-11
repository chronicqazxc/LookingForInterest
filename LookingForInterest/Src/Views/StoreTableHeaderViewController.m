//
//  StoreTableHeaderViewController.m
//  LookingForInterest
//
//  Created by Wayne on 2/11/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "StoreTableHeaderViewController.h"

@interface StoreTableHeaderViewController ()

@end

@implementation StoreTableHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
