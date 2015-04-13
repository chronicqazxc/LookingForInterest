//
//  LostPet.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/13/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LostPet : NSObject
/*!晶片號碼*/
@property (strong, nonatomic) NSString *chipNumber;
/*!寵物名*/
@property (strong, nonatomic) NSString *name;
/*!寵物別*/
@property (strong, nonatomic) NSString *variety;
/*!性別*/
@property (strong, nonatomic) NSString *gender;
/*!品種*/
@property (strong, nonatomic) NSString *race;
/*!毛色*/
@property (strong, nonatomic) NSString *hairColor;
/*!外觀*/
@property (strong, nonatomic) NSString *hairStyle;
/*!特徵*/
@property (strong, nonatomic) NSString *characterized;
/*!遺失時間*/
@property (strong, nonatomic) NSString *lostDate;
/*!遺失地點*/
@property (strong, nonatomic) NSString *lostPlace;
/*!飼主姓名*/
@property (strong, nonatomic) NSString *ownersName;
/*!連絡電話*/
@property (strong, nonatomic) NSString *phone;
/*!EMail*/
@property (strong, nonatomic) NSString *email;
- (id)initWithDic:(NSMutableDictionary *)dic;

+ (NSString *)chipNumberKey;
+ (NSString *)nameKey;
+ (NSString *)varietyKey;
+ (NSString *)genderKey;
+ (NSString *)raceKey;
+ (NSString *)hairColorKey;
+ (NSString *)hairStyleKey;
+ (NSString *)lostDateKey;
+ (NSString *)lostPlaceKey;
@end
