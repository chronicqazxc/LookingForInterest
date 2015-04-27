//
//  RequestSender.h
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

typedef NS_ENUM(NSInteger, FilterType) {
    GetAccessToken
};

@protocol RequestSenderDelegate <NSObject>
@optional
- (void)accessTokenBack:(NSArray *)accessTokenData;
- (void)requestFaildWithMessage:(NSString *)message connection:(NSURLConnection *)connection;
- (void)faildResultWithHTMLContent:(NSString *)content;
@end

@interface RequestSender : NSObject
@property (assign, nonatomic) id <RequestSenderDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *receivedDatas;
@property (strong, nonatomic) NSString *accessToken;
@property (nonatomic) FilterType type;
@property (strong, nonatomic) NSMutableArray *connectionsArr;
@property (nonatomic) NSInteger statusCode;
- (void)reconnect:(NSURLConnection *)connection;
- (NSData *)appendDataFromDatas:(NSMutableArray *)datas;
- (NSArray *)parseAccessToken:(NSData *)data;
- (void)sendRequestByParams:(NSDictionary *)paramDic andURL:(NSString *)URL;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)getAccessToken;
@end


