//
//  PetResult.m
//  LookingForInterest
//
//  Created by Wayne on 3/4/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "PetResult.h"

@implementation PetResult
- (id)initWithResult:(NSDictionary *)result {
    self = [super init];
    if (self) {
        NSDictionary *links = [result objectForKey:@"_links"]?[result objectForKey:@"_links"]:@"";
        self.start = [links objectForKey:@"start"]?[links objectForKey:@"start"]:@"";
        self.previous = [links objectForKey:@"prev"]?[links objectForKey:@"prev"]:@"";
        self.next = [links objectForKey:@"next"]?[links objectForKey:@"next"]:@"";
        self.total = [result objectForKey:@"total"]?[result objectForKey:@"total"]:@"";
        self.offset = [result objectForKey:@"offset"]?[result objectForKey:@"offset"]:@"";
        self.filters = [result objectForKey:@"filters"];
    }
    return self;
}
@end
