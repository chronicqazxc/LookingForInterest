//
//  LostPetListCell.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/14/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetListCell.h"

@interface LostPetListCell()
@property (weak, nonatomic) IBOutlet UIView *container;
@end

@implementation LostPetListCell

- (void)awakeFromNib {
    self.transform = CGAffineTransformMakeScale(.6, .8);
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
    self.describe.font = [UIFont systemFontOfSize:17.0];
    
    [self addShadowWithSize:CGSizeMake(5.0, 5.0)];
}

- (void)addShadowWithSize:(CGSize)size {
    CGFloat width = 0;
    if (CGRectGetWidth(self.container.bounds) < [Utilities getScreenSize].width - 20) {
        width = [Utilities getScreenSize].width - 20;
    } else {
        width = CGRectGetWidth(self.container.bounds);
    }
    CGRect rect = self.container.bounds;
    rect.size.width = width;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:rect];
    self.container.layer.masksToBounds = NO;
    self.container.layer.shadowColor = [UIColor blackColor].CGColor;
    self.container.layer.shadowOffset = CGSizeMake(size.width, size.height);
    self.container.layer.shadowOpacity = 0.5f;
    self.container.layer.shadowPath = shadowPath.CGPath;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
