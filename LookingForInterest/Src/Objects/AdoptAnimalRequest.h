//
//  AdoptAnimalRequest.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/13/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "RequestSender.h"

@protocol AdoptAnimalRequestDelegate <RequestSenderDelegate>
@optional
- (void)petResultBack:(PetResult *)petResult;
- (void)thumbNailBack:(UIImage *)image indexPath:(NSIndexPath *)indexPath;
- (void)checkFavoriteAnimalsResultBack:(NSMutableArray *)results;
@end

@interface AdoptAnimalRequest : RequestSender
- (void)sendRequestForAdoptAnimalsWithPetFilters:(PetFilters *)petFilters;
- (void)sendRequestForPetThumbNail:(Pet *)pet indexPath:(NSIndexPath *)indexPath;
- (void)checkFavoriteAnimals:(NSArray *)animals;
@property (assign, nonatomic) id <AdoptAnimalRequestDelegate> adoptAnimalRequestDelegate;
@end
