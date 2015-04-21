//
//  LostPet.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/13/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPet.h"

#define kChipNumber @"晶片號碼"
#define kName @"寵物名"
#define kVariety @"寵物別"
#define kGender @"性別"
#define kRace @"品種"
#define kHairColor @"毛色"
#define kHairStyle @"外觀"
#define kCharacterized @"特徵"
#define kLostDate @"遺失時間"
#define kLostPlace @"遺失地點"
#define kOwnersName @"飼主姓名"
#define kPhone @"連絡電話"
#define kEmail @"EMail"

@implementation LostPet
+ (NSString *)chipNumberKey {
    return kChipNumber;
}

+ (NSString *)nameKey {
    return kName;
}

+ (NSString *)varietyKey {
    return kVariety;
}

+ (NSString *)genderKey {
    return kGender;
}

+ (NSString *)raceKey {
    return kRace;
}

+ (NSString *)hairColorKey {
    return kHairColor;
}

+ (NSString *)hairStyleKey {
    return kHairStyle;
}

+ (NSString *)lostDateKey {
    return kLostDate;
}

+ (NSString *)lostPlaceKey {
    return kLostPlace;
}

- (id)initWithDic:(NSMutableDictionary *)dic {
    self = [super init];
    if (self) {
        self.chipNumber = [dic objectForKey:kChipNumber]?[dic objectForKey:kChipNumber]:@"";
        self.name = [dic objectForKey:kName]?[dic objectForKey:kName]:@"";
        self.variety = [dic objectForKey:kVariety]?[dic objectForKey:kVariety]:@"";
        self.gender = [dic objectForKey:kGender]?[dic objectForKey:kGender]:@"";
        self.race = [dic objectForKey:kRace]?[dic objectForKey:kRace]:@"";
        self.hairColor = [dic objectForKey:kHairColor]?[dic objectForKey:kHairColor]:@"";
        self.hairStyle = [dic objectForKey:kHairStyle]?[dic objectForKey:kHairStyle]:@"";
        self.characterized = [dic objectForKey:kCharacterized]?[dic objectForKey:kCharacterized]:@"";
        self.lostDate = [dic objectForKey:kLostDate]?[dic objectForKey:kLostDate]:@"";
        self.lostPlace = [dic objectForKey:kLostPlace]?[dic objectForKey:kLostPlace]:@"";
        self.ownersName = [dic objectForKey:kOwnersName]?[dic objectForKey:kOwnersName]:@"";
        self.phone = [dic objectForKey:kPhone]?[dic objectForKey:kPhone]:@"";
        self.email = [dic objectForKey:kEmail]?[dic objectForKey:kEmail]:@"";
    }
    return self;
}
@end
