//
//  RequestSender.m
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "RequestSender.h"

#define kGetDataError @"擷取資料失敗"
#define kRequestError @"網路連線錯誤"
#define kPetThumbNailHeigh 120
#define kPetThumbNailWeigh 120

@interface RequestSender() <NSURLConnectionDelegate>
@property (strong, nonatomic) NSMutableArray *receivedDatas;
@property (nonatomic) FilterType type;
@property (strong, nonatomic) PetFilters *petFilters;
#pragma mark - PetAdopt properties
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSMutableArray *checkFavoriteAnimalsArr;
@property (strong, nonatomic) NSMutableArray *checkFavoriteAnimalsResult;
@property (strong, nonatomic) NSMutableArray *connectionsArr;
@end

@implementation RequestSender
#pragma mark - Request for animal hospital

- (id)init {
    self = [super init];
    if (self) {
        self.receivedDatas = [NSMutableArray array];
        self.connectionsArr = [NSMutableArray array];
    }
    return self;
}

- (void)reconnect:(NSURLConnection *)connection {

    NSURLConnection *newConnection = [NSURLConnection connectionWithRequest:connection.originalRequest delegate:self];
    [newConnection start];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
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
    [self sendRequestByParams:@{@"menu_type":[NSString stringWithFormat:@"%d",(int)menuSearchType]} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetInitMenuURL]];
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
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *error = nil;
    if (error == nil) {
        if (self.type != CheckFavoriteAnimals) {
            [self.receivedDatas addObject:data];
        } else {
            for (NSMutableDictionary *connectionDic in self.connectionsArr) {
                NSURLConnection *connectionObj = [connectionDic objectForKey:@"connection"];
                if (connectionObj == connection) {
                    NSMutableArray *dataArr = [connectionDic objectForKey:@"data"];
                    [dataArr addObject:data];
                    break;
                }
            }
        }
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
    [self processErrorWithMessage:[error localizedDescription] connection:connection];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
            case AdoptAnimals:
                if ([self.delegate respondsToSelector:@selector(petResultBack:)]) {
                    [self parsePetResultData:[self appendDataFromDatas:self.receivedDatas] withConnection:connection];
                }
                break;
            case PetThumbNail:
                if ([self.delegate respondsToSelector:@selector(thumbNailBack:indexPath:)]) {
                    [self parseThumbNailData:[self appendDataFromDatas:self.receivedDatas]];
                }
                break;
            case CheckFavoriteAnimals:
                for (NSMutableDictionary *connectionDic in self.connectionsArr) {
                    NSURLConnection *connectionObj = [connectionDic objectForKey:@"connection"];
                    if (connectionObj == connection) {
                        NSMutableArray *dataArr = [connectionDic objectForKey:@"data"];
                        [self combineFavoriteAnimals:[self appendDataFromDatas:dataArr]];
                        break;
                    }
                }
                
            default:
                break;
        }
    } else {
        [Utilities stopLoading];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
    NSString *hospitalSource = [parsedData objectForKey:kHospitalSourceKey];
    NSString *hospitalTitle = [parsedData objectForKey:kHospitalTitleKey];
    NSString *hospitalUpdateDate = [parsedData objectForKey:kHospitalUpdateDateKey];
    NSString *functionOpen = [parsedData objectForKey:kHospitalFunctionOpenKey];
    NSString *closeReason = [parsedData objectForKey:kHospitalFunctionCloseReasonKey];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:accessToken forKey:kAccessTokenKey];
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

#pragma mark - Request for adopt animals
- (NSString *)composeURL:(NSString *)url withParameters:(NSMutableArray *)parameters andFilters:(NSMutableArray *)filters{
    NSMutableString *tempString = [NSMutableString string];

    for (NSString *parameter in parameters) {
        if ([parameters indexOfObject:parameter] == 0) {
            [tempString appendString:[NSString stringWithFormat:@"?%@",parameter]];
        } else {
            [tempString appendString:[NSString stringWithFormat:@"&%@",parameter]];
        }
    }
    for (NSString *filter in filters) {
        if ([filters indexOfObject:filter] == 0) {
            [tempString appendString:[NSString stringWithFormat:@"&q=%@",filter]];
        } else {
            [tempString appendString:[NSString stringWithFormat:@",%@",filter]];
        }
    }
    NSString *newUrl = [NSString stringWithFormat:@"%@%@",url,tempString];
    return newUrl;
}

- (NSMutableArray *)generateParameterByDic:(NSMutableDictionary *)dic {
    NSMutableArray *parameters = [NSMutableArray array];
    NSArray *keys = [dic allKeys];
    for (NSString *key in keys) {
        NSString *value = [dic objectForKey:key];
        NSString *parameter = [NSString stringWithFormat:@"%@=%@",key,value];
        [parameters addObject:parameter];
    }
    return parameters;
}

- (void)sendRequestForAdoptAnimalsWithPetFilters:(PetFilters *)petFilters {
    self.type = AdoptAnimals;
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:kResourceScope forKey:kResourceScopeKey];
    [dataDic setObject:kResourceID forKey:kResourceIDKey];
    [dataDic setObject:kResourceRID forKey:kResourceRIDKey];
    [dataDic setObject:kLimitValue forKey:kLimitKey];
    if (petFilters && petFilters.offset)
        [dataDic setObject:[NSNumber numberWithInt:[petFilters.offset intValue]] forKey:@"offset"];
    
    NSMutableArray *filters = [NSMutableArray array];
    if (petFilters.acceptNum)
        [filters addObject:petFilters.acceptNum];
    if (petFilters.isSterilization)
        [filters addObject:petFilters.isSterilization];
    if (petFilters.name)
        [filters addObject:petFilters.name];
    if (petFilters.variety)
        [filters addObject:petFilters.variety];
    if (petFilters.age)
        [filters addObject:petFilters.age];
    if (petFilters.childreAnlong)
        [filters addObject:petFilters.childreAnlong];
    if (petFilters.resettlement)
        [filters addObject:petFilters.resettlement];
    if (petFilters.sex)
        [filters addObject:petFilters.sex];
    if (petFilters.note)
        [filters addObject:petFilters.note];
    if (petFilters.phone)
        [filters addObject:petFilters.phone];
    if (petFilters.reason)
        [filters addObject:petFilters.reason];
    if (petFilters.imageName)
        [filters addObject:petFilters.imageName];
    if (petFilters.hairType)
        [filters addObject:petFilters.hairType];
    if (petFilters.build)
        [filters addObject:petFilters.build];
    if (petFilters.chipNum)
        [filters addObject:petFilters.chipNum];
    if (petFilters.petID)
        [filters addObject:petFilters.petID];
    if (petFilters.type)
        [filters addObject:petFilters.type];
    if (petFilters.email)
        [filters addObject:petFilters.email];
    if (petFilters.bodyweight)
        [filters addObject:petFilters.bodyweight];
    
    NSString *urlString = [self composeURL:kAdoptAnimalsInTPCURL withParameters:[self generateParameterByDic:dataDic]andFilters:filters];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    self.petFilters = petFilters;
    
    [connection start];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)checkFavoriteAnimals:(NSArray *)animals {
    self.type = CheckFavoriteAnimals;
    self.checkFavoriteAnimalsResult = [NSMutableArray array];
    self.checkFavoriteAnimalsArr = [NSMutableArray arrayWithArray:animals];
    for (Pet* pet in animals) {
        PetFilters *petFilters = [[PetFilters alloc] init];
        petFilters.acceptNum = pet.acceptNum;
        
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
        [dataDic setObject:kResourceScope forKey:kResourceScopeKey];
        [dataDic setObject:kResourceID forKey:kResourceIDKey];
        [dataDic setObject:kResourceRID forKey:kResourceRIDKey];
        [dataDic setObject:kLimitValue forKey:kLimitKey];
        
        NSMutableArray *filters = [NSMutableArray array];

        if (petFilters.acceptNum)
            [filters addObject:petFilters.acceptNum];

        NSString *urlString = [self composeURL:kAdoptAnimalsInTPCURL withParameters:[self generateParameterByDic:dataDic]andFilters:filters];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        [urlRequest setHTTPMethod:@"GET"];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//        self.petFilters = petFilters;
        
        [connection start];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSMutableDictionary *connectionObj = [NSMutableDictionary dictionary];
        [connectionObj setObject:connection forKey:@"connection"];
        NSMutableArray *dataArr = [NSMutableArray array];
        [connectionObj setObject:dataArr forKeyedSubscript:@"data"];
        [self.connectionsArr addObject:connectionObj];
    }
}

- (void)combineFavoriteAnimals:(NSData *)data {
    NSError *error = nil;
    NSDictionary *encodeStrings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    NSDictionary *result = [encodeStrings objectForKey:@"result"];
    NSArray *results = [result objectForKey:@"results"];
    for (NSDictionary *result in results) {
        [self.checkFavoriteAnimalsResult addObject:[self parseRecord:result]];
    }
    if ([self.checkFavoriteAnimalsResult count] == [self.checkFavoriteAnimalsArr count]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(checkFavoriteAnimalsResultBack:)]) {
            [self.delegate checkFavoriteAnimalsResultBack:self.checkFavoriteAnimalsResult];
        }
    }
}

- (void)parsePetResultData:(NSData *)data withConnection:(NSURLConnection *)connection{
    NSError *error = nil;
    NSDictionary *encodeStrings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:[encodeStrings objectForKey:@"result"]];
    
    PetResult *petResult = [self parseResult:result];
    
    NSArray *results = [result objectForKey:@"results"];
    NSMutableArray *pets = [NSMutableArray array];
    for (NSDictionary *result in results) {
        [pets addObject:[self parseRecord:result]];
    }
    petResult.pets = pets;
    
    petResult.filters = self.petFilters;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(petResultBack:)]) {
        [self.delegate petResultBack:petResult];
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

- (void)sendRequestForPetThumbNail:(Pet *)pet indexPath:(NSIndexPath *)indexPath {
    self.type = PetThumbNail;
    self.indexPath = indexPath;
    NSURL *url = [NSURL URLWithString:pet.imageName];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)parseThumbNailData:(NSData *)data {
    UIImage *image = [UIImage imageWithData:data];
    if (image.size.width != kPetThumbNailWeigh && image.size.height != kPetThumbNailHeigh) {
        CGSize itemSize = CGSizeMake(kPetThumbNailWeigh, kPetThumbNailHeigh);
        UIGraphicsBeginImageContext(itemSize);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [image drawInRect:imageRect];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    [self.delegate thumbNailBack:image indexPath:self.indexPath];
}

#pragma mark - process error
- (void)processErrorWithMessage:(NSString *)message connection:(NSURLConnection *)connection{
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestFaildWithMessage:connection:)]) {
        [self.delegate requestFaildWithMessage:message connection:connection];
    }
}
@end
