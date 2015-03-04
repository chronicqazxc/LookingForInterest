//
//  RequestSender.m
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "RequestSender.h"

@interface RequestSender() <NSURLConnectionDelegate>
@property (strong, nonatomic) NSMutableArray *receivedDatas;
@property (nonatomic) FilterType type;
@end

@implementation RequestSender
#pragma mark - Request for animal hospital

- (id)init {
    self = [super init];
    if (self) {
        self.receivedDatas = [NSMutableArray array];
    }
    return self;
}

- (void)getAccessToken {
    self.type = GetAccessToken;
    [self sendRequestByParams:@{} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetAccessToken]];    
}

- (void)sendMenuRequest {
    self.type = FilterTypeMenu;
    [self sendRequestByParams:@{} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetInitMenuURL]];
}

- (void)sendMajorRequest {
    self.type = FilterTypeMajorType;
    [self sendRequestByParams:@{} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetMajorTypesURL]];
}

- (void)sendMinorRequestByMajorType:(MajorType *)majorType {
    self.type = FilterTypeMinorType;
    [self sendRequestByParams:@{@"major_type_id": majorType.typeID} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetMinorTypesURL]];
}

- (void)sendStoreRequestByMajorType:(MajorType *)majorType minorType:(MinorType *)minorType {
    self.type = FilterTypeStore;
    [self sendRequestByParams:@{@"major_type_id":majorType.typeID,
                                @"minor_type_id":minorType.typeID}
                       andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestTestURL,kGetStoresURL]];
}

- (void)sendStoreRequestByMenuObj:(Menu *)menu andLocationCoordinate:(CLLocationCoordinate2D)location andPageController:(PageController *)pageController{
    
    self.type = SearchStores;
    NSString *majorTypeID = menu.majorType.typeID;
    NSString *minorTypeID = menu.minorType.typeID;
    NSString *menuSearchType = menu.menuSearchType?[NSString stringWithFormat:@"%d",menu.menuSearchType]:@"0";
    NSNumber *currentPage = pageController.currentPage?[NSNumber numberWithInt:pageController.currentPage]:[NSNumber numberWithInt:1];
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
                       andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetStoresURL]];
}

- (void)sendDetailRequestByStore:(Store *)store {
    self.type = SearchDetail;
    [self sendRequestByParams:@{@"id":store.storeID} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetDetailURL]];
}

- (void)sendDefaultImagesRequest {
    self.type = GetDefaultImages;
    [self sendRequestByParams:@{} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetDefaultImagesURL]];
}

- (void)sendRangeRequest {
    self.type = FilterTypeRange;
    [self sendRequestByParams:@{} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetRangesURL]];
}

- (void)sendCityRequest {
    self.type = FilterTypeCity;
    [self sendRequestByParams:@{} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetCitiesURL]];
}

- (void)sendMenuRequestWithType:(MenuSearchType)menuSearchType {
    self.type = FilterTypeMenu;
    [self sendRequestByParams:@{@"menu_type":[NSString stringWithFormat:@"%d",menuSearchType]} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetInitMenuURL]];
}

- (void)sendMenutypesRequest {
    self.type = FilterTypeMenuTypes;
    [self sendRequestByParams:@{} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetMenuTypesURL]];
}


- (void)sendRequestByParams:(NSDictionary *)paramDic andURL:(NSString *)URL{
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:paramDic options:0 error:&error];
    
    NSURL *url = [NSURL URLWithString:URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Token token=%@",self.accessToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *error = nil;
    if (error == nil) {
        [self.receivedDatas addObject:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"%@",error.description);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.delegate) {
        switch (self.type) {
            case GetAccessToken:
                if ([self.delegate respondsToSelector:@selector(accessTokenBack:)]) {
                    NSArray *datas = [self parseAccessToken:[self appendDataFromDatas:self.receivedDatas]];
                    [self.delegate accessTokenBack:datas];
                }
                break;
            case FilterTypeMenu:
                if ([self.delegate respondsToSelector:@selector(initMenuBack:)]) {
                    NSArray *datas = [self parseMenuData:[self appendDataFromDatas:self.receivedDatas]];
                    [self.delegate initMenuBack:datas];
                }
                break;
            case FilterTypeMajorType:
                if ([self.delegate respondsToSelector:@selector(majorsBack:)]) {
                    NSArray *datas = [self parseMajorTypeData:[self appendDataFromDatas:self.receivedDatas]];
                    [self.delegate majorsBack:datas];
                }
                break;
            case FilterTypeMinorType:
                if ([self.delegate respondsToSelector:@selector(minorsBack:)]) {
                    NSArray *datas = [self parseMinorTypeData:[self appendDataFromDatas:self.receivedDatas]];
                    [self.delegate minorsBack:datas];
                }
                break;
            case FilterTypeStore:
                if ([self.delegate respondsToSelector:@selector(storesBack:)]) {
                    NSMutableDictionary *resultDic = [self parseStoreData:[self appendDataFromDatas:self.receivedDatas]];
                    [self.delegate storesBack:resultDic];
                }
                break;
            case FilterTypeRange:
                if ([self.delegate respondsToSelector:@selector(rangesBack:)]) {
                    NSArray *datas = [self parseRangeData:[self appendDataFromDatas:self.receivedDatas]];
                    [self.delegate rangesBack:datas];
                }
                break;
            case FilterTypeCity:
                if ([self.delegate respondsToSelector:@selector(rangesBack:)]) {
                    NSArray *datas = [self parseCitiesData:[self appendDataFromDatas:self.receivedDatas]];
                    [self.delegate citiesBack:datas];
                }
                break;
            case SearchStores:
                if ([self.delegate respondsToSelector:@selector(storesBack:)]) {
                    NSMutableDictionary *datas = [self parseStoreData:[self appendDataFromDatas:self.receivedDatas]];
                    [self.delegate storesBack:datas];
                }
                break;
            case SearchDetail:
                if ([self.delegate respondsToSelector:@selector(detailBack:)]) {
                    NSArray *datas = [self parseDetailData:[self appendDataFromDatas:self.receivedDatas]];
                    [self.delegate detailBack:datas];
                }
                break;
            case FilterTypeMenuTypes:
                if ([self.delegate respondsToSelector:@selector(menuTypesBack:)]) {
                    NSArray *datas = [self parseMenuTypesData:[self appendDataFromDatas:self.receivedDatas]];
                    [self.delegate menuTypesBack:datas];
                }
                break;
            case GetDefaultImages:
                if ([self.delegate respondsToSelector:@selector(defaultImagesIsBack:)]) {
                    NSArray *datas = [self parseImageData:[self appendDataFromDatas:self.receivedDatas]];
                    [self.delegate defaultImagesIsBack:datas];
                }
                break;
            default:
                break;
        }
    } else {
        [Utilities stopLoading];
    }
    
}

#pragma mark - parse data
- (NSData *)appendDataFromDatas:(NSMutableArray *)datas {
    NSMutableData *mutableData = [NSMutableData data];
    for (NSData *data in datas) {
        [mutableData appendData:data];
    }
    NSData *returnData = [NSData dataWithData:mutableData];
    return returnData;
}

- (NSArray *)parseAccessToken:(NSData *)data {
    NSError *error = nil;
    NSMutableArray *array = [NSMutableArray array];
    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSString *accessToken = [parsedData objectForKey:kAccessTokenKey];
    [array addObject:accessToken];
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

#pragma mark - Request for adopt animals
- (void)requestForAdoptAnimalsWithPetFilters:(PetFilters *)petFilters {
    
    NSURL *url = [NSURL URLWithString:kAdoptAnimalsInTPCURL];
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:kResourceID forKey:kResourceIDKey];
    [dataDic setObject:kLimitValue forKey:kLimitKey];
    
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    if (petFilters.acceptNum)[filters setObject:petFilters.acceptNum forKey:@"AcceptNum"];
    if (petFilters.isSterilization)[filters setObject:petFilters.isSterilization forKey:@"IsSterilization"];
    if (petFilters.name)[filters setObject:petFilters.name forKey:@"Name"];
    if (petFilters.variety)[filters setObject:petFilters.variety forKey:@"Variety"];
    if (petFilters.age)[filters setObject:petFilters.age forKey:@"Age"];
    if (petFilters.childreAnlong)[filters setObject:petFilters.childreAnlong forKey:@"ChildreAnlong"];
    if (petFilters.resettlement)[filters setObject:petFilters.resettlement forKey:@"Resettlement"];
    if (petFilters.sex)[filters setObject:petFilters.sex forKey:@"Sex"];
    if (petFilters.note)[filters setObject:petFilters.note forKey:@"Note"];
    if (petFilters.phone)[filters setObject:petFilters.phone forKey:@"Phone"];
    if (petFilters.reason)[filters setObject:petFilters.reason forKey:@"Reason"];
    if (petFilters.imageName)[filters setObject:petFilters.imageName forKey:@"ImageName"];
    if (petFilters.hairType)[filters setObject:petFilters.hairType forKey:@"HairType"];
    if (petFilters.build)[filters setObject:petFilters.build forKey:@"Build"];
    if (petFilters.chipNum)[filters setObject:petFilters.chipNum forKey:@"ChipNum"];
    if (petFilters.petID)[filters setObject:petFilters.petID forKey:@"PetID"];
    if (petFilters.type)[filters setObject:petFilters.type forKey:@"Type"];
    if (petFilters.email)[filters setObject:petFilters.email forKey:@"Email"];
    if (petFilters.bodyweight)[filters setObject:petFilters.bodyweight forKey:@"Bodyweight"];
    if (petFilters.offset)[filters setObject:petFilters.offset forKey:@"Offset"];
    [dataDic setObject:filters forKey:@"filters"];
    
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dataDic options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:postData];
    
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    if (error == nil) {
        NSDictionary *encodeStrings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSString *success = [NSString stringWithFormat:@"%@",[encodeStrings objectForKey:@"success"]];
        if ([success isEqualToString:@"1"]) {
            NSDictionary *result = [encodeStrings objectForKey:@"result"];
            PetResult *petResult = [self parseResult:result];
            NSArray *records = [result objectForKey:@"records"];
            NSMutableArray *pets = [NSMutableArray array];
            for (NSDictionary *record in records) {
                [pets addObject:[self parseRecord:record]];
            }
            petResult.pets = pets;
            PetFilters *petFilters = [[PetFilters alloc] initWithFilters:[result objectForKey:@"filters"]];
            petResult.filters = petFilters;
        } else {
            NSLog(@"faild");
        }
        
    }
    
}

- (PetResult *)parseResult:(NSDictionary *)result {
    PetResult *petResult = [[PetResult alloc] initWithResult:result];
    return petResult;
}

- (Pet *)parseRecord:(NSDictionary *)record {
    Pet *pet = [[Pet alloc] initWithRecord:record];
    return pet;
}

- (PetFilters *)parseFilters:(NSDictionary *)filters {
    PetFilters *petFilters = [[PetFilters alloc] initWithFilters:filters];
    return petFilters;
}
@end
