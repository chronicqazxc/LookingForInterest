//
//  LostPetCollectionViewCell.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/21/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LostPetScrollViewShowMapPictureType) {
    LostPetScrollViewShowMap = 0,
    LostPetScrollViewShowPicture
};

@class LostPet;

#define kLostPetCollectionViewCellIdentifier @"LostPetCollectionViewCell"

@interface LostPetCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) LostPet *lostPet;
@property (nonatomic) LostPetScrollViewShowMapPictureType showType;
- (void)showMapOrPictureByValue:(LostPetScrollViewShowMapPictureType)value;
@end
