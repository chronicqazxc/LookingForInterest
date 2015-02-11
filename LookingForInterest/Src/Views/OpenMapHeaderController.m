//
//  OpenMapHeaderController.m
//  LookingForInterest
//
//  Created by Wayne on 2/11/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "OpenMapHeaderController.h"

@interface OpenMapHeaderController ()

@end

@implementation OpenMapHeaderController

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

- (IBAction)clickOpenMap:(UIButton *)sender {
    if (self.caller && self.callbackMethod) {
        if ([self.caller respondsToSelector:self.callbackMethod]) {
            [self.caller performSelectorOnMainThread:self.callbackMethod withObject:nil waitUntilDone:NO];
        }
    }
}
@end
