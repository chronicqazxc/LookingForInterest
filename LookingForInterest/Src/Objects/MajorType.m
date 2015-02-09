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
            self.typeID = [majorTypeDic objectForKey:@"type_id"];
            self.typeDescription = [majorTypeDic objectForKey:@"type_description"];
        }
    }
    return self;
}
@end
