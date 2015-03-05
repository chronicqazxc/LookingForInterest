//
//  PetResult.m
//  LookingForInterest
//
//  Created by Wayne on 3/4/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "PetResult.h"
#import "PetFilters.h"

@implementation PetResult
- (id)initWithResult:(NSDictionary *)result {
    self = [super init];
    if (self) {
        NSDictionary *links = [result objectForKey:@"_links"]?[result objectForKey:@"_links"]:@"";
        self.start = [links objectForKey:@"start"]?[links objectForKey:@"start"]:@"";
        self.previous = [links objectForKey:@"prev"]?[self parseOffset:[links objectForKey:@"prev"]]:@"";
        self.next = [links objectForKey:@"next"]?[self parseOffset:[links objectForKey:@"next"]]:@"";
        self.total = [result objectForKey:@"total"]?[NSNumber numberWithInteger:[[result objectForKey:@"total"] integerValue]]:@0;
        self.offset = [result objectForKey:@"offset"]?[result objectForKey:@"offset"]:@"";
    }
    return self;
}

- (NSString *)parseOffset:(NSString *)offset {
    NSArray *separateString = [offset componentsSeparatedByString:@"offset="];
    NSString *offsetString = [separateString lastObject];
    return offsetString;
}
@end
