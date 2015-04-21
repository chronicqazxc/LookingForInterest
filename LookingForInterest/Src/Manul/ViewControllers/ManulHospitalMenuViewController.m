//
//  ManulHospitalMenuViewController.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 3/21/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "ManulHospitalMenuViewController.h"

@interface ManulHospitalMenuViewController ()

@end

@implementation ManulHospitalMenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image1 = [UIImage imageNamed:@"manul_hospital_menu.png"];
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:image1];
    UIImage *image2 = [UIImage imageNamed:@"manul_hospital_list.png"];
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:image2];
    self.imageViews = [NSMutableArray arrayWithObjects:imageView1, imageView2, nil];
    self.pageControl.numberOfPages = 2;
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
