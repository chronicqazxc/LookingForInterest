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
        
        NSInteger offset = [[result objectForKey:@"offset"] intValue]?[[result objectForKey:@"offset"] intValue ]:0;
        NSInteger limit = [[result objectForKey:@"limit"] intValue]?[[result objectForKey:@"limit"] intValue ]:0;
        NSInteger count = [[result objectForKey:@"count"] intValue]?[[result objectForKey:@"count"] intValue ]:0;
        
        if (offset - limit) {
            self.previous = [NSString stringWithFormat:@"%ld",offset-limit];
        } else  {
            self.previous = @"0";
        }
        
        self.next = (limit+offset < count)?[NSString stringWithFormat:@"%ld",limit+offset]:@"";
        
        self.total = [NSNumber numberWithInteger:count];
        
        self.limit = [NSNumber numberWithInteger:limit];
        
        self.offset = [NSString stringWithFormat:@"%ld",offset];
    }
    return self;
}
@end
