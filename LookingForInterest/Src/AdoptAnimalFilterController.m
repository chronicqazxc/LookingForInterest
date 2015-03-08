//
//  AdoptAnimalFilterController.m
//  LookingForInterest
//
//  Created by Wayne on 3/6/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AdoptAnimalFilterController.h"
#import "PopUpPicker.h"

typedef enum adoptAnimalFilterType {
    AdoptFilterType,
    AdoptFilterGender,
    AdoptFilterAge,
    AdoptFilterBody
} AdoptAnimalFilterType;

@interface AdoptAnimalFilterController () <UIPickerViewDelegate, UIPickerViewDataSource, PopUpPickerDelegate>
@property (strong, nonatomic) PopUpPicker *popUpPicker;
@property (strong, nonatomic) UIButton *clickedButton;
@property (nonatomic) AdoptAnimalFilterType adoptFilterType;
@end

@implementation AdoptAnimalFilterController
- (id)initWithPetFilters:(PetFilters *)petFilters andDelegate:(id)delegate andFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.filterDelegate = delegate;
        self.petFilters = petFilters;
        self.popUpPicker = (PopUpPicker *)[Utilities getNibWithName:@"PopUpPicker"];
        self.popUpPicker.delegate = self;
        self.popUpPicker.pickerView.dataSource = self;
        self.popUpPicker.pickerView.delegate = self;
        self.popUpPicker.container = self.filterDelegate;
        self.popUpPicker.frame = CGRectMake(0,0,CGRectGetWidth(frame),CGRectGetHeight(frame));
    }
    return self;
}

- (void)showPickerView {
    NSInteger selectedRow = 0;
    if (self.petFilters.age) {
        selectedRow = [self selectedRowInComponent:AdoptFilterAge];
        [self.popUpPicker.pickerView selectRow:selectedRow inComponent:AdoptFilterAge animated:YES];
    }
    
    if (self.petFilters.type) {
        selectedRow = [self selectedRowInComponent:AdoptFilterType];
        [self.popUpPicker.pickerView selectRow:selectedRow inComponent:AdoptFilterType animated:YES];
    }
    
    if (self.petFilters.sex) {
        selectedRow = [self selectedRowInComponent:AdoptFilterGender];
        [self.popUpPicker.pickerView selectRow:selectedRow inComponent:AdoptFilterGender animated:YES];
    }
    
    if (self.petFilters.build) {
        selectedRow = [self selectedRowInComponent:AdoptFilterBody];
        [self.popUpPicker.pickerView selectRow:selectedRow inComponent:AdoptFilterBody animated:YES];
    }
    
    [self.popUpPicker popUpPickerView];
}

- (NSInteger)selectedRowInComponent:(AdoptAnimalFilterType)adoptAnimalFilterType {
    NSInteger selectedRow = 0;
    switch (adoptAnimalFilterType) {
        case AdoptFilterAge:
            selectedRow = [self processFilterAge];
            break;
        case AdoptFilterType:
            selectedRow = [self processFilterType];
            break;
        case AdoptFilterGender:
            selectedRow = [self processFilterGender];
            break;
        case AdoptFilterBody:
            selectedRow = [self processFilterBody];
            break;
        default:
            break;
    }
    return selectedRow;
}

- (NSInteger)processFilterAge {
    NSInteger ageNumber = 0;
    if ([self.petFilters.age isEqualToString:kAdoptFilterAll]) {
        ageNumber = 0;
    } else if ([self.petFilters.age isEqualToString:kAdoptFilterAgeBaby]) {
        ageNumber = 1;
    } else if ([self.petFilters.age isEqualToString:kAdoptFilterAgeYoung]) {
        ageNumber = 2;
    } else if ([self.petFilters.age isEqualToString:kAdoptFilterAgeAdult]) {
        ageNumber = 3;
    } else if ([self.petFilters.age isEqualToString:kAdoptFilterAgeOld]) {
        ageNumber = 4;
    }
    return ageNumber;
}

- (NSInteger)processFilterType {
    NSInteger typeNumber = 0;
    if ([self.petFilters.type isEqualToString:kAdoptFilterAll]) {
        typeNumber = 0;
    } else if ([self.petFilters.type isEqualToString:kAdoptFilterTypeDog]) {
        typeNumber = 1;
    } else if ([self.petFilters.type isEqualToString:kAdoptFilterTypeCat]) {
        typeNumber = 2;
    } else if ([self.petFilters.type isEqualToString:kAdoptFilterTypeOther]) {
        typeNumber = 3;
    }
    return typeNumber;
}

- (NSInteger)processFilterGender {
    NSInteger genderNumber = 0;
    if ([self.petFilters.sex isEqualToString:kAdoptFilterAll]) {
        genderNumber = 0;
    } else if ([self.petFilters.sex isEqualToString:kAdoptFilterGenderMale]) {
        genderNumber = 1;
    } else if ([self.petFilters.sex isEqualToString:kAdoptFilterGenderFemale]) {
        genderNumber = 2;
    } else if ([self.petFilters.sex isEqualToString:kAdoptFilterGenderUnknow]) {
        genderNumber = 3;
    }
    return genderNumber;
}

- (NSInteger)processFilterBody {
    NSInteger bodyNumber = 0;
    if ([self.petFilters.build isEqualToString:kAdoptFilterAll]) {
        bodyNumber = 0;
    } else if ([self.petFilters.build isEqualToString:kAdoptFilterBodyMini]) {
        bodyNumber = 1;
    } else if ([self.petFilters.build isEqualToString:kAdoptFilterBodySmall]) {
        bodyNumber = 2;
    } else if ([self.petFilters.build isEqualToString:kAdoptFilterBodyMiddle]) {
        bodyNumber = 3;
    } else if ([self.petFilters.build isEqualToString:kAdoptFilterBodyBig]) {
        bodyNumber = 4;
    }
    return bodyNumber;
}

#pragma mark - PopUpPickerDelegate
- (void)getStringFromPopUpPicker:(NSString *)string {
    NSString *selectedType = [self parseSelectedType];
    NSString *selectedGender = [self parseSelectedGender];
    NSString *selectedAge = [self parseSelectedAge];
    NSString *selectedBody = [self parseSelectedBody];
    
    if (![selectedType isEqualToString:@""]) {
        self.petFilters.type = selectedType;
    }
    
    if (![selectedGender isEqualToString:@""]) {
        self.petFilters.sex = selectedGender;
    }
    
    if (![selectedAge isEqualToString:@""]) {
        self.petFilters.age = selectedAge;
    }
    
    if (![selectedBody isEqualToString:@""]) {
        self.petFilters.build = selectedBody;
    }
    
    [self.clickedButton setTitle:string forState:UIControlStateNormal];
    if (self.filterDelegate && [self.filterDelegate respondsToSelector:@selector(clickSearchWithPetFilters:)]) {
        [self.filterDelegate clickSearchWithPetFilters:self.petFilters];
    }
}

- (NSString *)parseSelectedType {
    NSString *selectedType = kAdoptFilterAll;
    NSInteger selectedRow = [self.popUpPicker.pickerView selectedRowInComponent:AdoptFilterType];
    switch (selectedRow) {
        case -1:
            selectedType = @"";
            break;
        case 0:
            selectedType = kAdoptFilterAll;
            break;
        case 1:
            selectedType = kAdoptFilterTypeDog;
            break;
        case 2:
            selectedType = kAdoptFilterTypeCat;
            break;
        case 3:
            selectedType = kAdoptFilterTypeOther;
            break;
        default:
            break;
    }
    return selectedType;
}

- (NSString *)parseSelectedGender {
    NSString *selectedGender = kAdoptFilterAll;
    NSInteger selectedRow = [self.popUpPicker.pickerView selectedRowInComponent:AdoptFilterGender];
    switch (selectedRow) {
        case -1:
            selectedGender = @"";
            break;
        case 0:
            selectedGender = kAdoptFilterAll;
            break;
        case 1:
            selectedGender = kAdoptFilterGenderMale;
            break;
        case 2:
            selectedGender = kAdoptFilterGenderFemale;
            break;
        case 3:
            selectedGender = kAdoptFilterGenderUnknow;
            break;
        default:
            break;
    }
    return selectedGender;
}

- (NSString *)parseSelectedAge {
    NSString *selectedAge = kAdoptFilterAll;
    NSInteger selectedRow = [self.popUpPicker.pickerView selectedRowInComponent:AdoptFilterAge];
    switch (selectedRow) {
        case -1:
            selectedAge = @"";
            break;
        case 0:
            selectedAge = kAdoptFilterAll;
            break;
        case 1:
            selectedAge = kAdoptFilterAgeBaby;
            break;
        case 2:
            selectedAge = kAdoptFilterAgeYoung;
            break;
        case 3:
            selectedAge = kAdoptFilterAgeAdult;
            break;
        case 4:
            selectedAge = kAdoptFilterAgeOld;
            break;
        default:
            break;
    }
    return selectedAge;
}

- (NSString *)parseSelectedBody {
    NSString *selectedBody = kAdoptFilterAll;
    NSInteger selectedRow = [self.popUpPicker.pickerView selectedRowInComponent:AdoptFilterBody];
    switch (selectedRow) {
        case -1:
            selectedBody = @"";
            break;
        case 0:
            selectedBody = kAdoptFilterAll;
            break;
        case 1:
            selectedBody = kAdoptFilterBodyMini;
            break;
        case 2:
            selectedBody = kAdoptFilterBodySmall;
            break;
        case 3:
            selectedBody = kAdoptFilterBodyMiddle;
            break;
        case 4:
            selectedBody = kAdoptFilterBodyBig;
            break;
        default:
            break;
    }
    return selectedBody;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSInteger numberOfComponents = 4;
    return numberOfComponents;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numberOfRows = 0;
    switch (component) {
        case AdoptFilterAge:
            numberOfRows = 5; // 全, 幼齡, 年輕, 成年, 老年
            break;
        case AdoptFilterType:
            numberOfRows = 4; // 全, 犬, 貓, 其他
            break;
        case AdoptFilterGender:
            numberOfRows = 4; // 全, 雄, 雌, 未知
            break;
        case AdoptFilterBody:
            numberOfRows = 5; // 全, 大, 中, 小, 幼
            break;
        default:
            break;
    }
    return numberOfRows;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = @"";
    switch (component) {
        case AdoptFilterAge:
            title = [self processAgeTitleByRow:row];
            break;
        case AdoptFilterType:
            title = [self processTypeTitleByRow:row];
            break;
        case AdoptFilterGender:
            title = [self processGenderTitleByRow:row];
            break;
        case AdoptFilterBody:
            title = [self processBodyTitleByRow:row];
            break;
        default:
            break;
    }
    return title;
}

- (NSString *)processAgeTitleByRow:(NSInteger)row {
    NSString *ageTitle = @"";
    switch (row) {
        case 0:
            ageTitle = kAdoptFilterAll;
            break;
        case 1:
            ageTitle = kAdoptFilterAgeBaby;
            break;
        case 2:
            ageTitle = kAdoptFilterAgeYoung;
            break;
        case 3:
            ageTitle = kAdoptFilterAgeAdult;
            break;
        case 4:
            ageTitle = kAdoptFilterAgeOld;
            break;
        default:
            break;
    }
    return ageTitle;
}

- (NSString *)processTypeTitleByRow:(NSInteger)row {
    NSString *typeTitle = @"";
    switch (row) {
        case 0:
            typeTitle = kAdoptFilterAll;
            break;
        case 1:
            typeTitle = kAdoptFilterTypeDog;
            break;
        case 2:
            typeTitle = kAdoptFilterTypeCat;
            break;
        case 3:
            typeTitle = kAdoptFilterTypeOther;
            break;
        default:
            break;
    }
    return typeTitle;
}

- (NSString *)processGenderTitleByRow:(NSInteger)row {
    NSString *genderTitle = @"";
    switch (row) {
        case 0:
            genderTitle = kAdoptFilterAll;
            break;
        case 1:
            genderTitle = kAdoptFilterGenderMale;
            break;
        case 2:
            genderTitle = kAdoptFilterGenderFemale;
            break;
        case 3:
            genderTitle = kAdoptFilterGenderUnknow;
            break;
        default:
            break;
    }
    return genderTitle;
}

- (NSString *)processBodyTitleByRow:(NSInteger)row {
    NSString *bodyTitle = @"";
    switch (row) {
        case 0:
            bodyTitle = kAdoptFilterAll;
            break;
        case 1:
            bodyTitle = kAdoptFilterBodyMini;
            break;
        case 2:
            bodyTitle = kAdoptFilterBodySmall;
            break;
        case 3:
            bodyTitle = kAdoptFilterBodyMiddle;
            break;
        case 4:
            bodyTitle = kAdoptFilterBodyBig;
            break;
        default:
            break;
    }
    return bodyTitle;
}
@end
