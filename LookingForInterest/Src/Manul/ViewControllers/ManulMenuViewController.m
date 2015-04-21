//
//  ManulMenuViewController.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 3/21/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "ManulMenuViewController.h"

@interface ManulMenuViewController ()

@end

@implementation ManulMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"manul_menu.png"]];
    self.imageViews = [NSMutableArray arrayWithObject:imageView];
    self.pageControl.numberOfPages = 1;
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

- (IBAction)confirmClicked:(UIButton *)sender {
    [super confirmClicked:sender];
}

- (IBAction)neverShowSwitch:(UISwitch *)sender {
    [super neverShowSwitch:sender];
}

@end
