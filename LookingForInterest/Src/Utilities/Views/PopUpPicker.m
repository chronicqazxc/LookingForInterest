//
//  PopUpPicker.m
//  Chinatrust
//
//  Created by Wayne on 6/25/14.
//
//

#import "PopUpPicker.h"

@implementation PopUpPicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)setOpaque:(BOOL)newIsOpaque
{
    // Ignore attempt to set opaque to YES.
}

- (void)popUpDatePickerView {
    if([self.delegate isKindOfClass:[UIViewController class]])
    {
        UIViewController* viewctrler = (UIViewController*)self.delegate;
        [viewctrler.view addSubview:self];
    }
//    self.datePicker.maximumDate = self.lastDateOfThisMonth;
    self.datePicker.minimumDate = self.lastDateOfLastYear;
    [self.datePicker setDate:self.thisDate];
    self.datePickerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.datePickerView.alpha = 0;
    self.buttonView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.buttonView.alpha = 1;
    [UIView beginAnimations:@"popupPicker" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.datePickerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    self.datePickerView.alpha = 1;
    self.buttonView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    self.buttonView.alpha = 1;
    [UIView commitAnimations];
}

- (void)popUpPickerView {
    UIViewController *viewctrler = self.container;
    [viewctrler.view addSubview:self];
    //    self.datePicker.maximumDate = self.lastDateOfThisMonth;
//    self.datePicker.minimumDate = self.lastDateOfLastYear;
//    [self.datePicker setDate:self.thisDate];
    self.datePickerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.datePickerView.alpha = 0;
    self.buttonView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.buttonView.alpha = 1;
    [UIView beginAnimations:@"popupPicker" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.datePickerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    self.datePickerView.alpha = 1;
    self.buttonView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    self.buttonView.alpha = 1;
    [UIView commitAnimations];
}

- (void)removePopUpDatePicker {
    [UIView beginAnimations:@"close" context:nil];
    [UIView setAnimationDelegate:self];
    self.datePickerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    self.datePickerView.alpha = 1;
    self.buttonView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    self.buttonView.alpha = 1;
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:@"close"]) {
        if (finished) {
            [UIView beginAnimations:@"closeDone" context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelegate:self];
            self.datePickerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.datePickerView.alpha = 0;
            self.buttonView.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.buttonView.alpha = 0;
            [UIView commitAnimations];
        }
    } else if ([animationID isEqualToString:@"closeDone"]) {
            [self removeFromSuperview];
    } else if ([animationID isEqualToString:@"popupPicker"]) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        self.datePickerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.datePickerView.alpha = 1;
        self.buttonView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.buttonView.alpha = 1;
        [UIView commitAnimations];
        }
    }

- (void)smoothBorderOfView:(UIView *)view withCornerRadius:(float)cornerRadius {
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = cornerRadius;
}

- (IBAction)clickButton:(UIButton *)sender {
    if (sender.tag) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(getDateFromPopUpDatePicker:)]) {
            [self.delegate getDateFromPopUpDatePicker:self.datePicker.date];
        } else if (self.delegate && [self.delegate respondsToSelector:@selector(getStringFromPopUpPicker:)]) {
            [self.delegate getStringFromPopUpPicker:@""];
        }
    }
    [self removePopUpDatePicker];
}
@end
