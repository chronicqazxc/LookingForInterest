//
//  ManulAdoptListViewController.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 3/21/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "ManulAdoptListViewController.h"

@interface ManulAdoptListViewController ()

@end

@implementation ManulAdoptListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"manul_adopt_list.png"]];
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

@end
