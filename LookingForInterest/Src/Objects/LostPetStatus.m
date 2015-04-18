//
//  LostPetStatus.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/18/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetStatus.h"

@implementation LostPetStatus
- (id)init {
    self = [super init];
    if (self) {
        self.countOfCurrentPage = 0;
        self.countOfCurrentTotal = 0;
        _top = 20;
    }
    return self;
}

- (NSString *)currentPage {
    NSString *currentPage = @"";
    if (self.countOfCurrentTotal / self.top <= 1) {
        currentPage = @"第1頁";
    } else if (self.countOfCurrentTotal % self.top) {
        currentPage = [NSString stringWithFormat:@"第%d頁",(int)(self.countOfCurrentTotal / self.top + 1)];
    } else {
        currentPage = [NSString stringWithFormat:@"第%d頁",(int)(self.countOfCurrentTotal / self.top)];
    }
    return currentPage;
}
@end
