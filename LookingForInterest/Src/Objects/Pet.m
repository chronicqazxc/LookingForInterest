//
//  Pet.m
//  LookingForInterest
//
//  Created by Wayne on 3/4/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "Pet.h"

@implementation Pet
- (id)initWithRecord:(NSDictionary *)record {
    self = [super init];
    if (self) {
        self.acceptNum = [record objectForKey:@"AcceptNum"];
        self.isSterilization = [record objectForKey:@"IsSterilization"];
        self.name = [record objectForKey:@"Name"];
        self.variety = [record objectForKey:@"Variety"];
        self.age = [record objectForKey:@"Age"];
        self.childreAnlong = [record objectForKey:@"ChildreAnlong"];
        self.resettlement = [record objectForKey:@"Resettlement"];
        self.sex = [record objectForKey:@"Sex"];
        self.note = [record objectForKey:@"Note"];
        self.phone = [record objectForKey:@"Phone"];
        self.reason = [record objectForKey:@"Reason"];
        self.imageName = [record objectForKey:@"ImageName"];
        self.hairType = [record objectForKey:@"HairType"];
        self.build = [record objectForKey:@"Build"];
        self.chipNum = [record objectForKey:@"ChipNum"];
        self.petID = [record objectForKey:@"_id"];
        self.type = [record objectForKey:@"Type"];
        self.email = [record objectForKey:@"Email"];
        self.bodyweight = [record objectForKey:@"Bodyweight"];
    }
    return self;
}

@end
