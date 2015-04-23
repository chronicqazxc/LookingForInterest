//
//  LostPetFilters.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/13/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LostPetFilters : NSObject
- (id)initWithLostPetFilters:(LostPetFilters *)lostPetFilters;
@property (strong, nonatomic) NSString *chipNumber;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *variety;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *race;
@property (strong, nonatomic) NSString *hairColor;
@property (strong, nonatomic) NSString *hairStyle;
@property (strong, nonatomic) NSString *lostDate;
@property (strong, nonatomic) NSString *lostPlace;
- (NSString *)filterContent;

+ (NSString *)chipNumberFilterByValue:(NSString *)value;
+ (NSString *)nameFilterByValue:(NSString *)value;
+ (NSString *)varietyFilterByValue:(NSString *)value;
+ (NSString *)genderFilterByValue:(NSString *)value;
+ (NSString *)raceFilterByValue:(NSString *)value;
+ (NSString *)hairColorFilterByValue:(NSString *)value;
+ (NSString *)hairStyleFilterByValue:(NSString *)value;
+ (NSString *)lostDateFilterByValue:(NSString *)value;
+ (NSString *)lostPlaceFilterByValue:(NSString *)value;
@end
