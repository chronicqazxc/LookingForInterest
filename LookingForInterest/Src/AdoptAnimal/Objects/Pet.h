//
//  Pet.h
//  LookingForInterest
//
//  Created by Wayne on 3/4/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Pet : NSObject
@property (strong, nonatomic) NSString *acceptNum;
@property (strong, nonatomic) NSString *isSterilization;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *variety;
@property (strong, nonatomic) NSString *age;
@property (strong, nonatomic) NSString *childreAnlong;
@property (strong, nonatomic) NSString *resettlement;
@property (strong, nonatomic) NSString *sex;
@property (strong, nonatomic) NSString *note;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *reason;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSString *hairType;
@property (strong, nonatomic) NSString *build;
@property (strong, nonatomic) NSString *chipNum;
@property (strong, nonatomic) NSString *petID;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *bodyweight;
@property (strong, nonatomic) UIImage *thumbNail;
@property (strong, nonatomic) NSString *animalAnlong;
@property (strong, nonatomic) UIImage *petBigPic;
- (id)initWithRecord:(NSDictionary *)record;

+ (NSString *)adoptFilterAll;
+ (NSString *)adoptFilterAgeBaby;
+ (NSString *)adoptFilterAgeYoung;
+ (NSString *)adoptFilterAgeAdult;
+ (NSString *)adoptFilterAgeOld;
+ (NSString *)adoptFilterTypeDog;
+ (NSString *)adoptFilterTypeCat;
+ (NSString *)adoptFilterTypeOther;
+ (NSString *)adoptFilterTypeMyFavorite;
+ (NSString *)adoptFilterGenderMale;
+ (NSString *)adoptFilterGenderFemale;
+ (NSString *)adoptFilterGenderUnknow;
+ (NSString *)adoptFilterBodyMini;
+ (NSString *)adoptFilterBodySmall;
+ (NSString *)adoptFilterBodyMiddle;
+ (NSString *)adoptFilterBodyBig;
@end
