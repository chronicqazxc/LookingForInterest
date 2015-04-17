//
//  AnimalHospitalNavigationController.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/16/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AnimalHospitalNavigationController.h"
#import "AnimalHospitalTransition.h"

@interface AnimalHospitalNavigationController ()
@property (strong, nonatomic) AnimalHospitalTransition *animalHospitalTransition;
@end

@implementation AnimalHospitalNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.animalHospitalTransition = [[AnimalHospitalTransition alloc] init];
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
