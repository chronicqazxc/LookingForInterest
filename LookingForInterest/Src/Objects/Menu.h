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

@interface Menu : NSObject
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) MajorType *majorType;
@property (strong, nonatomic) MinorType *minorType;
@property (strong, nonatomic) Store *store;
@property (strong, nonatomic) NSString *range;
@property (strong, nonatomic) NSString *numberOfRows;

- (id)initWithMenuDic:(NSDictionary *)menuDic;
@end
