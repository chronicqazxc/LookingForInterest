//
//  LostPetSearchViewController.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/23/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LostPetFilters.h"

@protocol LostPetSearchViewControllerDelegate
- (void)processSearchWithFilters:(LostPetFilters *)lostPetFilters;
@end

@interface LostPetSearchViewController : UIViewController
@property (strong, nonatomic) LostPetFilters *lostPetFilters;
@property (assign, nonatomic) UIViewController <LostPetSearchViewControllerDelegate> *delegate;
@end
