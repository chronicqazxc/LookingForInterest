//
//  ManulViewController.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 3/21/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ManulViewControllerDelegate;

@interface ManulViewController : UIViewController
@property (weak, nonatomic) UIViewController <ManulViewControllerDelegate> *delegate;
@property (weak, nonatomic) IBOutlet UIView *scrollViewContainer;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UISwitch *neverShowSwitch;
@property (strong, nonatomic) NSMutableArray *imageViews;
- (IBAction)confirmClicked:(UIButton *)sender;
- (IBAction)neverShowSwitch:(UISwitch *)sender;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@end

@protocol ManulViewControllerDelegate

- (void)manulConfirmClicked;

@end
