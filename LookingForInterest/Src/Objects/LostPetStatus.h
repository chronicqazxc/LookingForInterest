//
//  LostPetStatus.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/18/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LoadingPageStatus) {
    LoadingPreviousPage = 0,
    LoadingNextPage,
    LoadingInitPage
};

@interface LostPetStatus : NSObject
@property (nonatomic) NSInteger countOfCurrentTotal;
@property (nonatomic, readonly) NSInteger top;
@property (nonatomic) NSInteger countOfCurrentPage;
@property (nonatomic) LoadingPageStatus loadingPageStatus;
- (NSString *)currentPage;
@end
