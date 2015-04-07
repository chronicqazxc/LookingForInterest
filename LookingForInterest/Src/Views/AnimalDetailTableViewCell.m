//
//  AnimalDetailTableViewCell.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AnimalDetailTableViewCell.h"
#import "MarqueeLabel.h"

@interface AnimalDetailTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *age;
@property (weak, nonatomic) IBOutlet UILabel *variety;
@property (weak, nonatomic) IBOutlet UILabel *sex;
@property (weak, nonatomic) IBOutlet UILabel *isSterilization;
@property (weak, nonatomic) IBOutlet UITextView *note;
@property (weak, nonatomic) IBOutlet UILabel *resettlement;
@property (weak, nonatomic) IBOutlet MarqueeLabel *childreAnlong;
@property (weak, nonatomic) IBOutlet MarqueeLabel *animalAnlong;
@property (weak, nonatomic) IBOutlet UILabel *reason;
@property (weak, nonatomic) IBOutlet UILabel *bodyweight;
@property (strong, nonatomic) Pet *pet;
@end

@implementation AnimalDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)settingContentsByPet:(Pet *)pet {
    self.pet = pet;
    [self.age setText:pet.age?pet.age:@""];
    [self.variety setText:pet.variety?pet.variety:@""];
    [self.sex setText:pet.sex?pet.sex:@""];
    [self.isSterilization setText:pet.isSterilization?pet.isSterilization:@""];
    [self.note setText:pet.note?pet.note:@""];
    [self.resettlement setText:pet.resettlement?pet.resettlement:@""];
    [self.childreAnlong setText:pet.childreAnlong?pet.childreAnlong:@""];
    [self.animalAnlong setText:pet.animalAnlong?pet.animalAnlong:@""];
    [self.bodyweight setText:pet.bodyweight?pet.bodyweight:@""];
}
@end
