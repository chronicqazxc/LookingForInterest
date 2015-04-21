//
//  OpenMapHeaderController.h
//  LookingForInterest
//
//  Created by Wayne on 2/11/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenMapHeaderController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *openMapButton;
@property (weak, nonatomic) IBOutlet UIImageView *openMapIcon;
@property (weak, nonatomic) id caller;
@property (nonatomic) SEL callbackMethod;
- (IBAction)clickOpenMap:(UIButton *)sender;

@end
