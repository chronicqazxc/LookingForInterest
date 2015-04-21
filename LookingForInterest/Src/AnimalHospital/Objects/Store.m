//
//  Store.m
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "Store.h"

@implementation Store

- (id)initWithStoreDic:(NSDictionary *)storeDic {
    self = [super init];
    if (self) {
        if (storeDic) {
            self.storeID = [storeDic objectForKey:@"id"];
            self.name = [storeDic objectForKey:@"name"];
            self.phoneNumber = [storeDic objectForKey:@"phone_number"];
            self.address = [storeDic objectForKey:@"address"];
            self.majorTypeID = [storeDic objectForKey:@"major_type_id"];
            self.minorTypeID = [storeDic objectForKey:@"minor_type_id"];
            self.latitude = [storeDic objectForKey:@"latitude"];
            self.longitude = [storeDic objectForKey:@"longitude"];
            self.distance = [storeDic objectForKey:@"distance"];
        }
    }
    return self;
}
@end
