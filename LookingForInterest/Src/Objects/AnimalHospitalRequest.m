//
//  AnimalHospitalRequest.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/13/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AnimalHospitalRequest.h"

@implementation AnimalHospitalRequest
- (void)setAnimalHospitalRequestDelegate:(id<AnimalHospitalRequestDelegate>)animalHospitalRequestDelegate {
    _animalHospitalRequestDelegate = animalHospitalRequestDelegate;
    self.delegate = _animalHospitalRequestDelegate;
}

- (void)sendAnimalHospitalInformationRequest {
    self.type = FilterTypeAnimalHospitalInformation;
    [self sendRequestByParams:@{} andURL:kLookingForInterestURL(kGetAnimalHospitalInformation)];
}

- (void)sendMenuRequest {
    self.type = FilterTypeMenu;
    [self sendRequestByParams:@{} andURL:kLookingForInterestURL(kGetInitMenuURL)];
}

- (void)sendMajorRequest {
    self.type = FilterTypeMajorType;
    [self sendRequestByParams:@{} andURL:kLookingForInterestURL(kGetMajorTypesURL)];
}

- (void)sendMinorRequestByMajorType:(MajorType *)majorType {
    self.type = FilterTypeMinorType;
    [self sendRequestByParams:@{@"major_type_id": majorType.typeID} andURL:kLookingForInterestURL(kGetMinorTypesURL)];
}

- (void)sendStoreRequestByMajorType:(MajorType *)majorType minorType:(MinorType *)minorType {
    self.type = FilterTypeStore;
    [self sendRequestByParams:@{@"major_type_id":majorType.typeID,
                                @"minor_type_id":minorType.typeID}
                       andURL:kLookingForInterestURL(kGetStoresURL)];
}

- (void)sendStoreRequestByMenuObj:(Menu *)menu andLocationCoordinate:(CLLocationCoordinate2D)location andPageController:(PageController *)pageController{
    
    self.type = SearchStores;
    NSString *majorTypeID = menu.majorType.typeID;
    NSString *minorTypeID = menu.minorType.typeID;
    NSString *menuSearchType = menu.menuSearchType?[NSString stringWithFormat:@"%d",(int)menu.menuSearchType]:@"0";
    NSNumber *currentPage = pageController.currentPage?[NSNumber numberWithUnsignedInteger:pageController.currentPage]:[NSNumber numberWithInt:1];
    NSNumber *range = menu.range?[NSNumber numberWithDouble:[menu.range doubleValue]]:[NSNumber numberWithDouble:0.0];
    NSString *city = menu.city?menu.city:@"";
    NSString *keyword = menu.keyword?[NSString stringWithFormat:@"%@%@%@",@"%",menu.keyword,@"%"]:@"";
    NSNumber *latitude = [NSNumber numberWithDouble:location.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:location.longitude];
    
    NSArray *storeIDs = [NSArray array];
    if (menu.menuSearchType == MenuFavorite) {
        storeIDs = [Utilities getMyFavoriteStores];
    }
    
    [self sendRequestByParams:@{@"major_type_id":majorTypeID,
                                @"minor_type_id":minorTypeID,
                                @"menu_type":menuSearchType,
                                @"page":currentPage,
                                @"range":range,
                                @"city":city,
                                @"keyword":keyword,
                                @"latitude":latitude,
                                @"longitude":longitude,
                                @"store_ids":storeIDs}
                       andURL:kLookingForInterestURL(kGetStoresURL)];
}

- (void)sendDetailRequestByStore:(Store *)store {
    self.type = SearchDetail;
    [self sendRequestByParams:@{@"id":store.storeID} andURL:kLookingForInterestURL(kGetDetailURL)];
}

- (void)sendDefaultImagesRequest {
    self.type = GetDefaultImages;
    [self sendRequestByParams:@{} andURL:kLookingForInterestURL(kGetDefaultImagesURL)];
}

- (void)sendRangeRequest {
    self.type = FilterTypeRange;
    [self sendRequestByParams:@{} andURL:kLookingForInterestURL(kGetRangesURL)];
}

- (void)sendCityRequest {
    self.type = FilterTypeCity;
    [self sendRequestByParams:@{} andURL:kLookingForInterestURL(kGetCitiesURL)];
}

- (void)sendMenuRequestWithType:(MenuSearchType)menuSearchType {
    self.type = FilterTypeMenu;
    [self sendRequestByParams:@{@"menu_type":[NSString stringWithFormat:@"%d",(int)menuSearchType]} andURL:kLookingForInterestURL(kGetInitMenuURL)];
}

- (void)sendMenutypesRequest {
    self.type = FilterTypeMenuTypes;
    [self sendRequestByParams:@{} andURL:kLookingForInterestURL(kGetMenuTypesURL)];
}

#pragma mark - NSURLConnectionDelegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.animalHospitalRequestDelegate) {
        switch (self.type) {
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
                if ([self.animalHospitalRequestDelegate respondsToSelector:@selector(defaultImagesIsBack:)]) {
                    NSArray *datas = [self parseImageData:[self appendDataFromDatas:self.receivedDatas]];
                    [self.animalHospitalRequestDelegate defaultImagesIsBack:datas];
                }
                break;
            default:
                break;
        }
    } else {
        [Utilities stopLoading];
    }
    [super connectionDidFinishLoading:connection];
}

#pragma mark - parse data
- (NSArray *)parseAnimalHospitalInformationData:(NSData *)data {
    NSError *error = nil;
    NSMutableArray *array = [NSMutableArray array];
    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSString *hospitalSource = [parsedData objectForKey:kHospitalSourceKey];
    NSString *hospitalTitle = [parsedData objectForKey:kHospitalTitleKey];
    NSString *hospitalUpdateDate = [parsedData objectForKey:kHospitalUpdateDateKey];
    NSString *functionOpen = [parsedData objectForKey:kHospitalFunctionOpenKey];
    NSString *closeReason = [parsedData objectForKey:kHospitalFunctionCloseReasonKey];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:hospitalSource forKey:kHospitalSourceKey];
    [dic setObject:hospitalTitle forKey:kHospitalTitleKey];
    [dic setObject:hospitalUpdateDate forKey:kHospitalUpdateDateKey];
    [dic setObject:functionOpen forKey:kHospitalFunctionOpenKey];
    [dic setObject:closeReason forKey:kHospitalFunctionCloseReasonKey];
    [array addObject:dic];
    return array;
}

- (NSArray *)parseMenuData:(NSData *)data {
    NSError *error = nil;
    NSMutableArray *array = [NSMutableArray array];
    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    Menu *menu = [[Menu alloc] initWithMenuDic:parsedData];
    [array addObject:menu];
    return array;
}

- (NSArray *)parseMajorTypeData:(NSData *)data {
    NSError *error = nil;
    NSMutableArray *array = [NSMutableArray array];
    NSArray *majorTypesData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    for (int i=0; i<[majorTypesData count]; i++) {
        MajorType *majorType = [[MajorType alloc] initWithMajorTypeDic:[majorTypesData objectAtIndex:i]];
        [array addObject:majorType];
    }
    return array;
}

- (NSArray *)parseMinorTypeData:(NSData *)data {
    NSError *error = nil;
    NSMutableArray *array = [NSMutableArray array];
    NSArray *minorTypesData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    for (int i=0; i<[minorTypesData count]; i++) {
        MinorType *minorType = [[MinorType alloc] initWithMinorTypeDic:[minorTypesData objectAtIndex:i]];
        [array addObject:minorType];
    }
    return array;
}

- (NSMutableDictionary *)parseStoreData:(NSData *)data {
    NSError *error = nil;
    NSMutableArray *array = [NSMutableArray array];
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    PageController *pageController = [[PageController alloc] init];
    pageController.currentPage = [[parsedData objectForKey:@"current_page"] intValue];
    pageController.totalPage = [[parsedData objectForKey:@"total_page"] intValue];
    NSArray *storesData = [parsedData objectForKey:@"stores"];
    for (int i=0; i<[storesData count]; i++) {
        Store *store = [[Store alloc] initWithStoreDic:[storesData objectAtIndex:i]];
        [array addObject:store];
    }
    [resultDic setObject:array forKey:@"stores"];
    [resultDic setObject:pageController forKey:@"pageController"];
    if ([parsedData objectForKey:@"address_location"]) {
        [resultDic setObject:[parsedData objectForKey:@"address_location"] forKey:@"address_location"];
    }
    return resultDic;
}

- (NSArray *)parseDetailData:(NSData *)data {
    NSError *error = nil;
    NSMutableArray *array = [NSMutableArray array];
    NSDictionary *detailData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    Detail *detail = [[Detail alloc] initWithDetailDic:detailData];
    [array addObject:detail];
    return array;
}

- (NSArray *)parseRangeData:(NSData *)data {
    NSError *error = nil;
    NSMutableArray *array = [NSMutableArray array];
    NSArray *rangesData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    [array addObject:rangesData];
    return array;
}

- (NSArray *)parseCitiesData:(NSData *)data {
    NSError *error = nil;
    NSMutableArray *array = [NSMutableArray array];
    NSArray *citiesData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    for (NSDictionary *dic in citiesData) {
        [array addObject:[dic objectForKey:@"city"]];
    }
    return array;
}

- (NSArray *)parseMenuTypesData:(NSData *)data {
    NSError *error = nil;
    NSMutableArray *array = [NSMutableArray array];
    NSArray *menuTypesData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    [array addObject:menuTypesData];
    return array;
}

- (NSArray *)parseImageData:(NSData *)data {
    NSError *error = nil;
    NSMutableArray *array = [NSMutableArray array];
    NSArray *encodeStrings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    for (NSString *encode in encodeStrings) {
        NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:encode options:0];
        [array addObject:decodeData];
    }
    return array;
}
@end
