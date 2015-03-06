//
//  AdoptAnimalFilterController.h
//  LookingForInterest
//
//  Created by Wayne on 3/6/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AdoptAnimalFilterControllerDelegate;

@interface AdoptAnimalFilterController : NSObject
@property (strong, nonatomic) PetFilters *petFilters;
@property (strong, nonatomic) UIViewController <AdoptAnimalFilterControllerDelegate> *filterDelegate;
- (id)initWithPetFilters:(PetFilters *)petFilters andDelegate:(id)delegate andFrame:(CGRect)frame;
- (void)showPickerView;
@end

@protocol AdoptAnimalFilterControllerDelegate
- (void)clickSearchWithPetFilters:(PetFilters *)petFilters;
@end