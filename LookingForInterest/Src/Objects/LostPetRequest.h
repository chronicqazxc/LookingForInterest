//
//  LostPetRequest.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/13/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "RequestSender.h"
#import "LostPetFilters.h"

@protocol LostPetRequestDelegate <RequestSenderDelegate>
@optional
- (void)lostPetResultBack:(NSArray *)lostPets;
@end

@interface LostPetRequest : RequestSender
- (void)sendRequestForLostPetWithLostPetFilters:(LostPetFilters *)lostPetFilters top:(NSString *)top skip:(NSString *)skip;
@property (assign, nonatomic) id <LostPetRequestDelegate> lostPetRequestDelegate;
@end
