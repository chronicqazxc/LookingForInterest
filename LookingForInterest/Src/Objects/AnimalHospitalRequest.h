//
//  AnimalHospitalRequest.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/13/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "RequestSender.h"

@protocol AnimalHospitalRequestDelegate <RequestSenderDelegate>
@optional
- (void)animalHospitalInformationBack:(NSArray *)informationData;
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

@interface AnimalHospitalRequest:RequestSender
- (void)sendAnimalHospitalInformationRequest;
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
@property (assign, nonatomic) id <AnimalHospitalRequestDelegate> animalHospitalRequestDelegate;
@end


