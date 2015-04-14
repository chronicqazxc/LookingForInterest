//
//  LostPetListCell.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/14/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LostPetListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *chipNumber;
@property (weak, nonatomic) IBOutlet UILabel *lostDate;
@property (weak, nonatomic) IBOutlet UILabel *lostPlace;
@property (weak, nonatomic) IBOutlet UILabel *variety;
@property (weak, nonatomic) IBOutlet UILabel *hairColor;
@property (weak, nonatomic) IBOutlet UILabel *hairStyle;
@property (weak, nonatomic) IBOutlet UITextView *describe;

@end
