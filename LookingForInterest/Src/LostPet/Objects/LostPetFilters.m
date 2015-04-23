//
//  LostPetFilters.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/13/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetFilters.h"
#import "LostPet.h"

@implementation LostPetFilters
- (id)initWithLostPetFilters:(LostPetFilters *)lostPetFilters {
    self = [super init];
    if (self) {
        self.chipNumber = [NSString stringWithString:lostPetFilters.chipNumber?lostPetFilters.chipNumber:@""];
        self.name = [NSString stringWithString:lostPetFilters.name?lostPetFilters.name:@""];
        self.variety = [NSString stringWithString:lostPetFilters.variety?lostPetFilters.variety:@""];
        self.gender = [NSString stringWithString:lostPetFilters.gender?lostPetFilters.gender:@""];
        self.race = [NSString stringWithString:lostPetFilters.race?lostPetFilters.race:@""];
        self.hairColor = [NSString stringWithString:lostPetFilters.hairColor?lostPetFilters.hairColor:@""];
        self.hairStyle = [NSString stringWithString:lostPetFilters.hairStyle?lostPetFilters.hairStyle:@""];
        self.lostDate = [NSString stringWithString:lostPetFilters.lostDate?lostPetFilters.lostDate:@""];
        self.lostPlace = [NSString stringWithString:lostPetFilters.lostPlace?lostPetFilters.lostPlace:@""];
    }
    return self;
}

- (NSString *)filterContent {
    NSMutableString *tempString = [NSMutableString stringWithString:@""];
    NSMutableDictionary *propertiesDic = [self enumerationProperties];
    for (NSString *key in propertiesDic.allKeys) {
        NSString *property = [propertiesDic objectForKey:key];
        if (![property isEqualToString:@""]) {
            if ([tempString isEqualToString:@""]) {
                [tempString appendString:[NSString stringWithFormat:@"%@",[LostPetFilters combineStringKey:key value:property]]];
            } else {
                [tempString appendString:[NSString stringWithFormat:@"+and+%@",[LostPetFilters combineStringKey:key value:property]]];
            }
        }
    }
    return tempString;
}

- (NSMutableDictionary *)enumerationProperties {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.chipNumber?self.chipNumber:@"" forKey:[LostPet chipNumberKey]];
    [dic setObject:self.name?self.name:@"" forKey:[LostPet nameKey]];
    [dic setObject:self.variety?self.variety:@"" forKey:[LostPet varietyKey]];
    [dic setObject:self.gender?self.gender:@"" forKey:[LostPet genderKey]];
    [dic setObject:self.race?self.race:@"" forKey:[LostPet raceKey]];
    [dic setObject:self.hairColor?self.hairColor:@"" forKey:[LostPet hairColorKey]];
    [dic setObject:self.hairStyle?self.hairStyle:@"" forKey:[LostPet hairStyleKey]];
    [dic setObject:self.lostDate?self.lostDate:@"" forKey:[LostPet lostDateKey]];
    [dic setObject:self.lostPlace?self.lostPlace:@"" forKey:[LostPet lostPlaceKey]];

    return dic;
}

+ (NSString *)combineStringKey:(NSString *)key value:(NSString *)value {
    return [NSString stringWithFormat:@"%@+like+%@",key,value];
}

+ (NSString *)chipNumberFilterByValue:(NSString *)value {
    return [self combineStringKey:[LostPet chipNumberKey] value:value];
}

+ (NSString *)nameFilterByValue:(NSString *)value {
    return [self combineStringKey:[LostPet nameKey] value:value];
}

+ (NSString *)varietyFilterByValue:(NSString *)value {
    return [self combineStringKey:[LostPet varietyKey] value:value];
}

+ (NSString *)genderFilterByValue:(NSString *)value {
    return [self combineStringKey:[LostPet genderKey] value:value];
}

+ (NSString *)raceFilterByValue:(NSString *)value {
    return [self combineStringKey:[LostPet raceKey] value:value];
}

+ (NSString *)hairColorFilterByValue:(NSString *)value {
    return [self combineStringKey:[LostPet hairColorKey] value:value];
}

+ (NSString *)hairStyleFilterByValue:(NSString *)value {
    return [self combineStringKey:[LostPet hairStyleKey] value:value];
}

+ (NSString *)lostDateFilterByValue:(NSString *)value {
    return [self combineStringKey:[LostPet lostDateKey] value:value];
}

+ (NSString *)lostPlaceFilterByValue:(NSString *)value {
    return [self combineStringKey:[LostPet lostPlaceKey] value:value];
}

@end
