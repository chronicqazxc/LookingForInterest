//
//  PetFilters.m
//  LookingForInterest
//
//  Created by Wayne on 3/5/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "PetFilters.h"

@implementation PetFilters
- (id)initWithFilters:(NSDictionary *)filters {
    self = [super init];
    if (self) {
        if ([filters objectForKey:@"AcceptNum"])self.acceptNum = [filters objectForKey:@"AcceptNum"];
        if ([filters objectForKey:@"IsSterilization"])self.isSterilization = [filters objectForKey:@"IsSterilization"];
        if ([filters objectForKey:@"Name"])self.name = [filters objectForKey:@"Name"];
        if ([filters objectForKey:@"Variety"])self.variety = [filters objectForKey:@"Variety"];
        if ([filters objectForKey:@"Age"])self.age = [filters objectForKey:@"Age"];
        if ([filters objectForKey:@"ChildreAnlong"])self.childreAnlong = [filters objectForKey:@"ChildreAnlong"];
        if ([filters objectForKey:@"Resettlement"])self.resettlement = [filters objectForKey:@"Resettlement"];
        if ([filters objectForKey:@"Sex"])self.sex = [filters objectForKey:@"Sex"];
        if ([filters objectForKey:@"Note"])self.note = [filters objectForKey:@"Note"];
        if ([filters objectForKey:@"Phone"])self.phone = [filters objectForKey:@"Phone"];
        if ([filters objectForKey:@"Reason"])self.reason = [filters objectForKey:@"Reason"];
        if ([filters objectForKey:@"ImageName"])self.imageName = [filters objectForKey:@"ImageName"];
        if ([filters objectForKey:@"HairType"])self.hairType = [filters objectForKey:@"HairType"];
        if ([filters objectForKey:@"Build"])self.build = [filters objectForKey:@"Build"];
        if ([filters objectForKey:@"PetID"])self.chipNum = [filters objectForKey:@"ChipNum"];
        if ([filters objectForKey:@"ChipNum"])self.petID = [filters objectForKey:@"PetID"];
        if ([filters objectForKey:@"Type"])self.type = [filters objectForKey:@"Type"];
        if ([filters objectForKey:@"Email"])self.email = [filters objectForKey:@"Email"];
        if ([filters objectForKey:@"Bodyweight"])self.bodyweight = [filters objectForKey:@"Bodyweight"];
        if ([filters objectForKey:@"Offset"])self.offset = [filters objectForKey:@"Offset"];
    }
    return self;
}
@end
