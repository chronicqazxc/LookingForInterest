//
//  MinorType.m
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "MinorType.h"

@implementation MinorType

- (id)initWithMinorTypeDic:(NSDictionary *)minorTypeDic {
    self = [super init];
    if (self) {
        if (minorTypeDic) {
            self.typeID = [NSString stringWithFormat:@"%d",[[minorTypeDic objectForKey:@"id"] integerValue]];;
            self.typeDescription = [minorTypeDic objectForKey:@"type_description"];
            self.majorTypeID = [minorTypeDic objectForKey:@"major_type_id"];
        }
    }
    return self;
}
@end
