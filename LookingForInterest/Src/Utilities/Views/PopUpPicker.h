//
//  PopUpPicker.h
//  Chinatrust
//
//  Created by Wayne on 6/25/14.
//
//

#import <UIKit/UIKit.h>

@protocol PopUpPickerDelegate;

@interface PopUpPicker : UIView
@property (weak, nonatomic) IBOutlet UIView *buttonView;

@property (weak, nonatomic) IBOutlet UIView *datePickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) id <PopUpPickerDelegate> delegate;
@property (weak, nonatomic) UIViewController *container;

@property (strong, nonatomic) NSDate *lastDateOfThisMonth;
@property (strong, nonatomic) NSDate *lastDateOfLastYear;
@property (strong, nonatomic) NSDate *thisDate;

- (IBAction)clickButton:(UIButton *)sender;
- (void)popUpPickerView;
@end

@protocol PopUpPickerDelegate <NSObject>
@optional
- (void)getDateFromPopUpDatePicker:(NSDate *)date;
- (void)getStringFromPopUpPicker:(NSString *)string;
@end
