//
//  Menu.m
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "Menu.h"

@implementation Menu

- (id)initWithMenuDic:(NSDictionary *)menuDic {
    self = [super init];
    if (self) {
        if (menuDic) {
            self.titles = [menuDic objectForKey:@"Titles"];
            self.content = [menuDic objectForKey:@"Content"];
            self.menuSearchType = [[menuDic objectForKey:@"MenuSearchType"] intValue];
            
            NSDictionary *majorTypeDic = [menuDic objectForKey:@"MajorType"];
            MajorType *majorType = [[MajorType alloc] initWithMajorTypeDic:majorTypeDic];
            self.majorType = majorType;
            
            NSDictionary *minorTypeDic = [menuDic objectForKey:@"MinorType"];
            MinorType *minorType = [[MinorType alloc] initWithMinorTypeDic:minorTypeDic];
            self.minorType = minorType;
            
            NSDictionary *storeDic = [menuDic objectForKey:@"Store"];
            Store *store = [[Store alloc] initWithStoreDic:storeDic];
            self.store = store;
            
            self.range = [menuDic objectForKey:@"Range"];
            self.numberOfRows = [menuDic objectForKey:@"NumberOfRows"];
        }
    }
    return self;
}
@end
