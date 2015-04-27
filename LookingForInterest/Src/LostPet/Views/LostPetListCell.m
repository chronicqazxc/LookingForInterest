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
    
    self.transform = CGAffineTransformMakeScale(.8, .8);
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
