//
//  LostPetRequest.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/13/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetRequest.h"

@implementation LostPetRequest
- (void)sendRequestForLostPetWithLostPetFilters:(LostPetFilters *)lostPetFilters {
    NSString *filterContent = [NSString stringWithFormat:@"%@AND%@",[LostPetFilters varietyFilterByValue:@"狗"], [LostPetFilters genderFilterByValue:@"雌"]];    
}
@end
