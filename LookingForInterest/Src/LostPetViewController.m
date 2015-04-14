//
//  LostPetViewController.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/14/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetViewController.h"
#import "LostPetRequest.h"

@interface LostPetViewController () <LostPetRequestDelegate>

@end

@implementation LostPetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    LostPetRequest *lostPetRequest = [[LostPetRequest alloc] init];
    lostPetRequest.lostPetRequestDelegate = self;
    LostPetFilters *lostPetFilters = [[LostPetFilters alloc] init];
    lostPetFilters.variety = @"貓";
    lostPetFilters.gender = @"母";
    [lostPetRequest sendRequestForLostPetWithLostPetFilters:lostPetFilters];
}

#pragma mark - LostPetRequestDelegate
- (void)lostPetResultBack:(NSArray *)lostPets {

    NSLog(@"%@",lostPets);
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
