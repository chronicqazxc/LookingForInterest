//
//  RequestSender.h
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@protocol RequestSenderDelegate;

@interface RequestSender : NSObject
@property (assign, nonatomic) id <RequestSenderDelegate> delegate;

#pragma mark - properties and methods for animal hospital
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
- (void)sendStoreRequestByMenuObj:(Menu *)menu andLocationCoordinate:(CLLocationCoordinate2D)location andPageController:(PageController *)pageController;
- (void)sendDetailRequestByStore:(Store *)store;
- (void)sendDefaultImagesRequest;
#pragma mark - properies and methods for adopt animals

@end

@protocol RequestSenderDelegate <NSObject>
@optional
#pragma mark - delegate for animal hospital
- (void)accessTokenBack:(NSArray *)accessTokenData;
- (void)initMenuBack:(NSArray *)menuData;
- (void)menuTypesBack:(NSArray *)menuData;
- (void)majorsBack:(NSArray *)majorData;
- (void)minorsBack:(NSArray *)minorData;
- (void)storesBack:(NSMutableDictionary *)resultDic;
- (void)detailBack:(NSArray *)detailData;
- (void)rangesBack:(NSArray *)rangeData;
- (void)citiesBack:(NSArray *)citiesData;
- (void)defaultImagesIsBack:(NSArray *)datas;
@end
