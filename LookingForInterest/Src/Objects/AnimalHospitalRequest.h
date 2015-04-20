//
//  AnimalHospitalRequest.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/13/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "RequestSender.h"
/*
 case FilterTypeAnimalHospitalInformation:
 if ([self.animalHospitalRequestDelegate respondsToSelector:@selector(animalHospitalInformationBack:)]) {
 NSArray *datas = [self parseAnimalHospitalInformationData:[self appendDataFromDatas:self.receivedDatas]];
 [self.animalHospitalRequestDelegate animalHospitalInformationBack:datas];
 }
 break;
 case FilterTypeMenu:
 if ([self.animalHospitalRequestDelegate respondsToSelector:@selector(initMenuBack:)]) {
 NSArray *datas = [self parseMenuData:[self appendDataFromDatas:self.receivedDatas]];
 [self.animalHospitalRequestDelegate initMenuBack:datas];
 }
 break;
 case FilterTypeMajorType:
 if ([self.animalHospitalRequestDelegate respondsToSelector:@selector(majorsBack:)]) {
 NSArray *datas = [self parseMajorTypeData:[self appendDataFromDatas:self.receivedDatas]];
 [self.animalHospitalRequestDelegate majorsBack:datas];
 }
 break;
 case FilterTypeMinorType:
 if ([self.animalHospitalRequestDelegate respondsToSelector:@selector(minorsBack:)]) {
 NSArray *datas = [self parseMinorTypeData:[self appendDataFromDatas:self.receivedDatas]];
 [self.animalHospitalRequestDelegate minorsBack:datas];
 }
 break;
 case FilterTypeStore:
 if ([self.animalHospitalRequestDelegate respondsToSelector:@selector(storesBack:)]) {
 NSMutableDictionary *resultDic = [self parseStoreData:[self appendDataFromDatas:self.receivedDatas]];
 [self.animalHospitalRequestDelegate storesBack:resultDic];
 }
 break;
 case FilterTypeRange:
 if ([self.animalHospitalRequestDelegate respondsToSelector:@selector(rangesBack:)]) {
 NSArray *datas = [self parseRangeData:[self appendDataFromDatas:self.receivedDatas]];
 [self.animalHospitalRequestDelegate rangesBack:datas];
 }
 break;
 case FilterTypeCity:
 if ([self.animalHospitalRequestDelegate respondsToSelector:@selector(rangesBack:)]) {
 NSArray *datas = [self parseCitiesData:[self appendDataFromDatas:self.receivedDatas]];
 [self.animalHospitalRequestDelegate citiesBack:datas];
 }
 break;
 case SearchStores:
 if ([self.animalHospitalRequestDelegate respondsToSelector:@selector(storesBack:)]) {
 NSMutableDictionary *datas = [self parseStoreData:[self appendDataFromDatas:self.receivedDatas]];
 [self.animalHospitalRequestDelegate storesBack:datas];
 }
 break;
 case SearchDetail:
 if ([self.animalHospitalRequestDelegate respondsToSelector:@selector(detailBack:)]) {
 NSArray *datas = [self parseDetailData:[self appendDataFromDatas:self.receivedDatas]];
 [self.animalHospitalRequestDelegate detailBack:datas];
 }
 break;
 case FilterTypeMenuTypes:
 if ([self.animalHospitalRequestDelegate respondsToSelector:@selector(menuTypesBack:)]) {
 NSArray *datas = [self parseMenuTypesData:[self appendDataFromDatas:self.receivedDatas]];
 [self.animalHospitalRequestDelegate menuTypesBack:datas];
 }
 break;
 case GetDefaultImages:
 */
typedef NS_ENUM(NSInteger, AnimalHospitalRequestType) {
    RequestTypeAnimalHospitalInformation = 0,
    RequestTypeMenu,
    RequestTypeMajorType,
    RequestTypeMinorType,
    RequestTypeStore,
    RequestTypeRange,
    RequestTypeCity,
    RequestTypeSearchStores,
    RequestTypeSearchDetail,
    RequestTypeMenuTypes,
    RequestTypeDefaultImages
};

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
@property (nonatomic) AnimalHospitalRequestType animalHospitalRequestType;
@end