//
//  LostPetSearchViewController.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/23/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetSearchViewController.h"

@interface LostPetSearchViewController ()
- (IBAction)clickCancel:(UIButton *)sender;

@end

@implementation LostPetSearchViewController

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

- (IBAction)clickCancel:(UIButton *)sender {
    self.transitioningDelegate = self.myTransitionDelegate;
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
