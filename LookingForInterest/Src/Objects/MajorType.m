//
//  MajorType.m
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "MajorType.h"

@implementation MajorType

- (id)initWithMajorTypeDic:(NSDictionary *)majorTypeDic {
    self = [super init];
    if (self) {
        if (majorTypeDic) {
            self.typeID = [NSString stringWithFormat:@"%d",[[majorTypeDic objectForKey:@"id"] intValue]];
            self.typeDescription = [majorTypeDic objectForKey:@"type_description"];
        }
    }
    return self;
}
@end
