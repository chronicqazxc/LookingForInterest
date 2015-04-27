//
//  LostPetListCell.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/14/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetListCell.h"

@implementation LostPetListCell

- (void)awakeFromNib {
    self.describe.layer.borderColor = [UIColor blackColor].CGColor;
    self.describe.layer.borderWidth = 1.0;
    self.describe.layer.masksToBounds = YES;
    self.describe.layer.cornerRadius = 5.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
