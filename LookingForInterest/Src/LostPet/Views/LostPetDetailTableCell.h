//
//  LostPetDetailTableCell.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "LostPetCollectionViewCell.h"

#define kLostPetDetailTableCellIdentifier @"LostPetDetailTableCell"

@class LostPet;

@interface LostPetDetailTableCell : UITableViewCell
- (void)settingContentsByLostPet:(LostPet *)lostPet;
@property (strong, nonatomic) LostPet *lostPet;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (strong, nonatomic) LostPetCollectionViewCell *lostPetCollectionViewCell;
@end
