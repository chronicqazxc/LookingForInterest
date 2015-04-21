//
//  AdoptAnimalViewController.h
//  LookingForInterest
//
//  Created by Wayne on 3/5/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdoptAnimalViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkButton;
- (IBAction)clickCheck:(UIBarButtonItem *)sender;

@end
