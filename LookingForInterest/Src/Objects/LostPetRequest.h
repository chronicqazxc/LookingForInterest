//
//  LostPetRequest.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/13/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "RequestSender.h"
#import "LostPetFilters.h"

@interface LostPetRequest : RequestSender
- (void)sendRequestForLostPetWithLostPetFilters:(LostPetFilters *)lostPetFilters;
@end
