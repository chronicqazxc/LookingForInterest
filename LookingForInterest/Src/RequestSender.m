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
    
    [self sendRequestByParams:@{@"major_type_id":majorTypeID,
                                @"minor_type_id":minorTypeID,
                                @"menu_type":menuSearchType,
                                @"page":currentPage,
                                @"range":range,
                                @"city":city,
                                @"keyword":keyword,
                                @"latitude":latitude,
                                @"longitude":longitude}
                       andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetStoresURL]];
}

- (void)sendDetailRequestByStore:(Store *)store {
    self.type = SearchDetail;
    [self sendRequestByParams:@{@"id":store.storeID} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetDetailURL]];
}

- (void)sendCatImageRequest {
    self.type = GetCatImage;
    [self sendRequestByParams:@{} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetCatImageURL]];
}

- (void)sendDogImageRequest {
    self.type = GetDogImage;
    [self sendRequestByParams:@{} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetDogImageURL]];
}

- (void)sendAnimalsImageRequest {
    self.type = GetAnimalsImage;
    [self sendRequestByParams:@{} andURL:[NSString stringWithFormat:@"%@%@",kLookingForInterestURL,kGetAnimalsImageURL]];
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
            case GetCatImage:
                if ([self.delegate respondsToSelector:@selector(catIsBack:)]) {
                    NSArray *datas = [self parseImageData:[self appendDataFromDatas:self.receivedDatas]];
                    [self.delegate catIsBack:datas];
                }
                break;
            case GetDogImage:
                if ([self.delegate respondsToSelector:@selector(dogIsBack:)]) {
                    NSArray *datas = [self parseImageData:[self appendDataFromDatas:self.receivedDatas]];
                    [self.delegate dogIsBack:datas];
                }
                break;
            case GetAnimalsImage:
                if ([self.delegate respondsToSelector:@selector(animalsIsBack:)]) {
                    NSArray *datas = [self parseImageData:[self appendDataFromDatas:self.receivedDatas]];
                    [self.delegate animalsIsBack:datas];
                }
                break;
            default:
                break;
        }
    }
    
}

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
    NSMutableArray *array = [NSMutableArray array];
    NSData *catImageData = [NSData dataWithData:data];
    [array addObject:catImageData];
    return array;
}

@end
