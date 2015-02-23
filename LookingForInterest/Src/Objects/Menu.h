//
//  Menu.h
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MajorType.h"
#import "MinorType.h"
#import "Store.h"

typedef NS_ENUM(NSInteger, MenuSearchType) {
    MenuCurrentPosition = 0,
    MenuCities
};

@interface Menu : NSObject
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *content;
@property (strong, nonatomic) MajorType *majorType;
@property (strong, nonatomic) MinorType *minorType;
@property (strong, nonatomic) Store *store;
@property (strong, nonatomic) NSString *range;
@property (strong, nonatomic) NSString *numberOfRows;
@property (nonatomic) MenuSearchType menuSearchType;

- (id)initWithMenuDic:(NSDictionary *)menuDic;
@end
