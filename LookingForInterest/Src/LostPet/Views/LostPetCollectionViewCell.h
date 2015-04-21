//
//  LostPetCollectionViewCell.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/21/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LostPet;

#define kLostPetCollectionViewCellIdentifier @"LostPetCollectionViewCell"

@interface LostPetCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) LostPet *lostPet;
@end
