//
//  Pet.m
//  LookingForInterest
//
//  Created by Wayne on 3/4/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "Pet.h"

#define kAdoptFilterAll @"全"
#define kAdoptFilterAgeBaby @"幼齡"
#define kAdoptFilterAgeYoung @"年輕"
#define kAdoptFilterAgeAdult @"成年"
#define kAdoptFilterAgeOld @"老年"
#define kAdoptFilterTypeDog @"犬"
#define kAdoptFilterTypeCat @"貓"
#define kAdoptFilterTypeOther @"其他"
#define kAdoptFilterTypeMyFavorite @"我的最愛"
#define kAdoptFilterGenderMale @"雄"
#define kAdoptFilterGenderFemale @"雌"
#define kAdoptFilterGenderUnknow @"未知"
#define kAdoptFilterBodyMini @"微"
#define kAdoptFilterBodySmall @"小"
#define kAdoptFilterBodyMiddle @"中"
#define kAdoptFilterBodyBig @"大"

@implementation Pet
- (id)initWithRecord:(NSDictionary *)record {
    self = [super init];
    if (self) {
        self.acceptNum = [record objectForKey:@"AcceptNum"];
        self.isSterilization = [record objectForKey:@"IsSterilization"];
        self.name = [record objectForKey:@"Name"];
        self.variety = [record objectForKey:@"Variety"];
        self.age = [record objectForKey:@"Age"];
        self.childreAnlong = [record objectForKey:@"ChildreAnlong"];
        self.resettlement = [record objectForKey:@"Resettlement"];
        self.sex = [record objectForKey:@"Sex"];
        self.note = [record objectForKey:@"Note"];
        self.phone = [record objectForKey:@"Phone"];
        self.reason = [record objectForKey:@"Reason"];
        self.imageName = [record objectForKey:@"ImageName"];
        self.hairType = [record objectForKey:@"HairType"];
        self.build = [record objectForKey:@"Build"];
        self.chipNum = [record objectForKey:@"ChipNum"];
        self.petID = [record objectForKey:@"_id"];
        self.type = [record objectForKey:@"Type"];
        self.email = [record objectForKey:@"Email"];
        self.bodyweight = [record objectForKey:@"Bodyweight"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.acceptNum forKey:@"AcceptNum"];
    [encoder encodeObject:self.isSterilization forKey:@"IsSterilization"];
    [encoder encodeObject:self.name forKey:@"Name"];
    [encoder encodeObject:self.variety forKey:@"Variety"];
    [encoder encodeObject:self.age forKey:@"Age"];
    [encoder encodeObject:self.childreAnlong forKey:@"ChildreAnlong"];
    [encoder encodeObject:self.resettlement forKey:@"Resettlement"];
    [encoder encodeObject:self.sex forKey:@"Sex"];
    [encoder encodeObject:self.note forKey:@"Note"];
    [encoder encodeObject:self.phone forKey:@"Phone"];
    [encoder encodeObject:self.reason forKey:@"Reason"];
    [encoder encodeObject:self.imageName forKey:@"ImageName"];
    [encoder encodeObject:self.hairType forKey:@"HairType"];
    [encoder encodeObject:self.build forKey:@"Build"];
    [encoder encodeObject:self.chipNum forKey:@"ChipNum"];
    [encoder encodeObject:self.petID forKey:@"_id"];
    [encoder encodeObject:self.type forKey:@"Type"];
    [encoder encodeObject:self.email forKey:@"Email"];
    [encoder encodeObject:self.bodyweight forKey:@"Bodyweight"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.acceptNum = [decoder decodeObjectForKey:@"AcceptNum"];
        self.isSterilization = [decoder decodeObjectForKey:@"IsSterilization"];
        self.name = [decoder decodeObjectForKey:@"Name"];
        self.variety = [decoder decodeObjectForKey:@"Variety"];
        self.age = [decoder decodeObjectForKey:@"Age"];
        self.childreAnlong = [decoder decodeObjectForKey:@"ChildreAnlong"];
        self.resettlement = [decoder decodeObjectForKey:@"Resettlement"];
        self.sex = [decoder decodeObjectForKey:@"Sex"];
        self.note = [decoder decodeObjectForKey:@"Note"];
        self.phone = [decoder decodeObjectForKey:@"Phone"];
        self.reason = [decoder decodeObjectForKey:@"Reason"];
        self.imageName = [decoder decodeObjectForKey:@"ImageName"];
        self.hairType = [decoder decodeObjectForKey:@"HairType"];
        self.build = [decoder decodeObjectForKey:@"Build"];
        self.chipNum = [decoder decodeObjectForKey:@"ChipNum"];
        self.petID = [decoder decodeObjectForKey:@"_id"];
        self.type = [decoder decodeObjectForKey:@"Type"];
        self.email = [decoder decodeObjectForKey:@"Email"];
        self.bodyweight = [decoder decodeObjectForKey:@"Bodyweight"];
    }
    return self;
}

+ (NSString *)adoptFilterAll {
    return kAdoptFilterAll;
}

+ (NSString *)adoptFilterAgeBaby {
    return kAdoptFilterAgeBaby;
}

+ (NSString *)adoptFilterAgeYoung {
    return kAdoptFilterAgeYoung;
}

+ (NSString *)adoptFilterAgeAdult {
    return kAdoptFilterAgeAdult;
}

+ (NSString *)adoptFilterAgeOld {
    return kAdoptFilterAgeOld;
}

+ (NSString *)adoptFilterTypeDog {
    return kAdoptFilterTypeDog;
}

+ (NSString *)adoptFilterTypeCat {
    return kAdoptFilterTypeCat;
}

+ (NSString *)adoptFilterTypeOther {
    return kAdoptFilterTypeOther;
}

+ (NSString *)adoptFilterTypeMyFavorite {
    return kAdoptFilterTypeMyFavorite;
}

+ (NSString *)adoptFilterGenderMale {
    return kAdoptFilterGenderMale;
}

+ (NSString *)adoptFilterGenderFemale {
    return kAdoptFilterGenderFemale;
}

+ (NSString *)adoptFilterGenderUnknow {
    return kAdoptFilterGenderUnknow;
}

+ (NSString *)adoptFilterBodyMini {
    return kAdoptFilterBodyMini;
}

+ (NSString *)adoptFilterBodySmall {
    return kAdoptFilterBodySmall;
}

+ (NSString *)adoptFilterBodyMiddle {
    return kAdoptFilterBodyMiddle;
}

+ (NSString *)adoptFilterBodyBig {
    return kAdoptFilterBodyBig;
}
@end
