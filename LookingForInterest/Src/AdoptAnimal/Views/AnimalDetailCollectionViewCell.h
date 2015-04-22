//
//  AnimalDetailCollectionViewCell.h
//  LookingForInterest
//
//  Created by Wayne on 3/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimalDetailTableViewCell.h"

@interface AnimalDetailCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) AnimalDetailTableViewCell *tableCell;
@property (strong, nonatomic) Pet *pet;
@property (strong, nonatomic) PetResult *petResult;
@end