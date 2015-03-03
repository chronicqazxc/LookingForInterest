//
//  DialingButton.m
//  LookingForInterest
//
//  Created by Wayne on 3/3/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "DialingButton.h"

@interface DialingButton()
@property (strong, nonatomic) UIView *highLightView;
@end

@implementation DialingButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.borderColor = self.titleLabel.textColor;
    self.layer.borderColor = [self.borderColor colorWithAlphaComponent:0.7].CGColor;
    self.layer.borderWidth = 1.0;
    self.highLightView = [[UIView alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(self.frame),CGRectGetHeight(self.frame))];
    self.highLightView.userInteractionEnabled = YES;
    self.highLightView.alpha = 0;
    self.highLightView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self addSubview:self.highLightView];
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.layer.borderColor = [_borderColor colorWithAlphaComponent:1.0].CGColor;
        [self dialing];
    }
    else {
        self.layer.borderColor = [_borderColor colorWithAlphaComponent:0.7].CGColor;
    }
}

- (void)dialing {
    self.highLightView.frame = CGRectMake(0,0,CGRectGetWidth(self.frame),CGRectGetHeight(self.frame));
    self.highLightView.alpha = 1;
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.highLightView.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];
}

@end
