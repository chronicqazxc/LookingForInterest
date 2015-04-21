//
//  AnimalListTableViewCell.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 3/10/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>

#define kPetListCellIdentifier @"PetListCell"
@interface AnimalListTableViewCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *age;
@property (weak, nonatomic) IBOutlet UILabel *gender;
@property (weak, nonatomic) IBOutlet UILabel *body;
@property (weak, nonatomic) IBOutlet UIImageView *thumbNail;
@property (weak, nonatomic) IBOutlet UILabel *variety;
@end
