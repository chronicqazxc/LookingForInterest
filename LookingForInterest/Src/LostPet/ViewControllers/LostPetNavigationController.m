//
//  LostPetNavigationController.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/16/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetNavigationController.h"
#import "LostPetTransition.h"

@interface LostPetNavigationController ()
@property (strong, nonatomic) LostPetTransition *lostPetTransition;
@end

@implementation LostPetNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lostPetTransition = [[LostPetTransition alloc] init];
    if (!self.transitioningDelegate) {
        self.transitioningDelegate = self.lostPetTransition;
    }
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

@end
