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
    [self sendRequestByParams:@{} andURL:kLookingForInterestURL(kGetAccessToken)];
}

- (void)sendRequestByParams:(NSDictionary *)paramDic andURL:(NSString *)URL {
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

#pragma mark - NSURLconnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedDatas addObject:data];
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

#pragma mark - process error
- (void)processErrorWithMessage:(NSString *)message connection:(NSURLConnection *)connection{
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestFaildWithMessage:connection:)]) {
        [self.delegate requestFaildWithMessage:message connection:connection];
    }
}
@end
