//
//  AnimalListTableViewCell.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 3/10/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AnimalListTableViewCell.h"

@implementation AnimalListTableViewCell
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    self.thumbNail.layer.masksToBounds = YES;
    self.thumbNail.layer.borderWidth = 1.0;
    self.thumbNail.layer.cornerRadius = CGRectGetHeight(self.thumbNail.frame)/2.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
