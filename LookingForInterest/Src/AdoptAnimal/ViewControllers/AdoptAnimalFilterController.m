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
    if ([self.petFilters.age isEqualToString:[Pet adoptFilterAll]]) {
        ageNumber = 0;
    } else if ([self.petFilters.age isEqualToString:[Pet adoptFilterAgeBaby]]) {
        ageNumber = 1;
    } else if ([self.petFilters.age isEqualToString:[Pet adoptFilterAgeYoung]]) {
        ageNumber = 2;
    } else if ([self.petFilters.age isEqualToString:[Pet adoptFilterAgeAdult]]) {
        ageNumber = 3;
    } else if ([self.petFilters.age isEqualToString:[Pet adoptFilterAgeOld]]) {
        ageNumber = 4;
    }
    return ageNumber;
}

- (NSInteger)processFilterType {
    NSInteger typeNumber = 0;
    if ([self.petFilters.type isEqualToString:[Pet adoptFilterAll]]) {
        typeNumber = 0;
    } else if ([self.petFilters.type isEqualToString:[Pet adoptFilterTypeDog]]) {
        typeNumber = 1;
    } else if ([self.petFilters.type isEqualToString:[Pet adoptFilterTypeCat]]) {
        typeNumber = 2;
    } else if ([self.petFilters.type isEqualToString:[Pet adoptFilterTypeOther]]) {
        typeNumber = 3;
    }
    return typeNumber;
}

- (NSInteger)processFilterGender {
    NSInteger genderNumber = 0;
    if ([self.petFilters.sex isEqualToString:[Pet adoptFilterAll]]) {
        genderNumber = 0;
    } else if ([self.petFilters.sex isEqualToString:[Pet adoptFilterGenderMale]]) {
        genderNumber = 1;
    } else if ([self.petFilters.sex isEqualToString:[Pet adoptFilterGenderFemale]]) {
        genderNumber = 2;
    } else if ([self.petFilters.sex isEqualToString:[Pet adoptFilterGenderUnknow]]) {
        genderNumber = 3;
    }
    return genderNumber;
}

- (NSInteger)processFilterBody {
    NSInteger bodyNumber = 0;
    if ([self.petFilters.build isEqualToString:[Pet adoptFilterAll]]) {
        bodyNumber = 0;
    } else if ([self.petFilters.build isEqualToString:[Pet adoptFilterBodyMini]]) {
        bodyNumber = 1;
    } else if ([self.petFilters.build isEqualToString:[Pet adoptFilterBodySmall]]) {
        bodyNumber = 2;
    } else if ([self.petFilters.build isEqualToString:[Pet adoptFilterBodyMiddle]]) {
        bodyNumber = 3;
    } else if ([self.petFilters.build isEqualToString:[Pet adoptFilterBodyBig]]) {
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
    NSString *selectedType = [Pet adoptFilterAll];
    NSInteger selectedRow = [self.popUpPicker.pickerView selectedRowInComponent:AdoptFilterType];
    switch (selectedRow) {
        case -1:
            selectedType = @"";
            break;
        case 0:
            selectedType = [Pet adoptFilterAll];
            break;
        case 1:
            selectedType = [Pet adoptFilterTypeDog];
            break;
        case 2:
            selectedType = [Pet adoptFilterTypeCat];
            break;
        case 3:
            selectedType = [Pet adoptFilterTypeOther];
            break;
        default:
            break;
    }
    return selectedType;
}

- (NSString *)parseSelectedGender {
    NSString *selectedGender = [Pet adoptFilterAll];
    NSInteger selectedRow = [self.popUpPicker.pickerView selectedRowInComponent:AdoptFilterGender];
    switch (selectedRow) {
        case -1:
            selectedGender = @"";
            break;
        case 0:
            selectedGender = [Pet adoptFilterAll];
            break;
        case 1:
            selectedGender = [Pet adoptFilterGenderMale];
            break;
        case 2:
            selectedGender = [Pet adoptFilterGenderFemale];
            break;
        case 3:
            selectedGender = [Pet adoptFilterGenderUnknow];
            break;
        default:
            break;
    }
    return selectedGender;
}

- (NSString *)parseSelectedAge {
    NSString *selectedAge = [Pet adoptFilterAll];
    NSInteger selectedRow = [self.popUpPicker.pickerView selectedRowInComponent:AdoptFilterAge];
    switch (selectedRow) {
        case -1:
            selectedAge = @"";
            break;
        case 0:
            selectedAge = [Pet adoptFilterAll];
            break;
        case 1:
            selectedAge = [Pet adoptFilterAgeBaby];
            break;
        case 2:
            selectedAge = [Pet adoptFilterAgeYoung];
            break;
        case 3:
            selectedAge = [Pet adoptFilterAgeAdult];
            break;
        case 4:
            selectedAge = [Pet adoptFilterAgeOld];
            break;
        default:
            break;
    }
    return selectedAge;
}

- (NSString *)parseSelectedBody {
    NSString *selectedBody = [Pet adoptFilterAll];
    NSInteger selectedRow = [self.popUpPicker.pickerView selectedRowInComponent:AdoptFilterBody];
    switch (selectedRow) {
        case -1:
            selectedBody = @"";
            break;
        case 0:
            selectedBody = [Pet adoptFilterAll];
            break;
        case 1:
            selectedBody = [Pet adoptFilterBodyMini];
            break;
        case 2:
            selectedBody = [Pet adoptFilterBodySmall];
            break;
        case 3:
            selectedBody = [Pet adoptFilterBodyMiddle];
            break;
        case 4:
            selectedBody = [Pet adoptFilterBodyBig];
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
            ageTitle = [Pet adoptFilterAll];
            break;
        case 1:
            ageTitle = [Pet adoptFilterAgeBaby];
            break;
        case 2:
            ageTitle = [Pet adoptFilterAgeYoung];
            break;
        case 3:
            ageTitle = [Pet adoptFilterAgeAdult];
            break;
        case 4:
            ageTitle = [Pet adoptFilterAgeOld];
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
            typeTitle = [Pet adoptFilterAll];
            break;
        case 1:
            typeTitle = [Pet adoptFilterTypeDog];
            break;
        case 2:
            typeTitle = [Pet adoptFilterTypeCat];
            break;
        case 3:
            typeTitle = [Pet adoptFilterTypeOther];
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
            genderTitle = [Pet adoptFilterAll];
            break;
        case 1:
            genderTitle = [Pet adoptFilterGenderMale];
            break;
        case 2:
            genderTitle = [Pet adoptFilterGenderFemale];
            break;
        case 3:
            genderTitle = [Pet adoptFilterGenderUnknow];
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
            bodyTitle = [Pet adoptFilterAll];
            break;
        case 1:
            bodyTitle = [Pet adoptFilterBodyMini];
            break;
        case 2:
            bodyTitle = [Pet adoptFilterBodySmall];
            break;
        case 3:
            bodyTitle = [Pet adoptFilterBodyMiddle];
            break;
        case 4:
            bodyTitle = [Pet adoptFilterBodyBig];
            break;
        default:
            break;
    }
    return bodyTitle;
}
@end
