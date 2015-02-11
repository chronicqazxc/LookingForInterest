//
//  StoreTableHeaderViewController.h
//  LookingForInterest
//
//  Created by Wayne on 2/11/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreTableHeaderViewController : UIViewController
- (IBAction)clickStoreTitle:(UIButton *)sender;
@property (weak, nonatomic) id caller;
@property (nonatomic) SEL callBackMethod;
@end
