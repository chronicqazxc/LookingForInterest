//
//  RequestSender.h
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LookingForInterest.h"

@protocol RequestSenderDelegate;

@interface RequestSender : NSObject
@property (assign, nonatomic) id <RequestSenderDelegate> delegate;
@property (strong, nonatomic) NSString *accessToken;
- (void)getAccessToken;
- (void)sendMenuRequest;
- (void)sendMenuRequestWithType:(MenuSearchType)menuSearchType;
- (void)sendMenutypesRequest;
- (void)sendRangeRequest;
- (void)sendCityRequest;
- (void)sendMajorRequest;
- (void)sendMinorRequestByMajorType:(MajorType *)majorType;
- (void)sendStoreRequestByMajorType:(MajorType *)majorType minorType:(MinorType *)minorType;
- (void)sendStoreRequestByMenuObj:(Menu *)menu andLocationCoordinate:(CLLocationCoordinate2D)location;
@end

@protocol RequestSenderDelegate <NSObject>
- (void)accessTokenBack:(NSArray *)accessTokenData;
- (void)initMenuBack:(NSArray *)menuData;
- (void)menuTypesBack:(NSArray *)menuData;
- (void)majorsBack:(NSArray *)majorData;
- (void)minorsBack:(NSArray *)minorData;
- (void)storesBack:(NSMutableDictionary *)resultDic;
- (void)rangesBack:(NSArray *)rangeData;
- (void)citiesBack:(NSArray *)citiesData;
@end
