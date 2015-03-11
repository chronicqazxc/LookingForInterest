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
- (void)reconnect:(NSURLConnection *)connection;
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
- (void)sendRequestForAdoptAnimalsWithPetFilters:(PetFilters *)petFilters;
- (void)sendRequestForPetThumbNail:(Pet *)pet indexPath:(NSIndexPath *)indexPath;
- (void)checkFavoriteAnimals:(NSArray *)animals;
@end

@protocol RequestSenderDelegate <NSObject>
@optional
- (void)requestFaildWithMessage:(NSString *)message connection:(NSURLConnection *)connection;
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
#pragma mark - delegate for adopt animal
- (void)petResultBack:(PetResult *)petResult;
- (void)thumbNailBack:(UIImage *)image indexPath:(NSIndexPath *)indexPath;
- (void)checkFavoriteAnimalsResultBack:(NSMutableArray *)results;
@end
