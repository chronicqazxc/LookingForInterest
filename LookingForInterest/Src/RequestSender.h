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
@property (strong, nonatomic) NSMutableArray *receivedDatas;
@property (strong, nonatomic) NSString *accessToken;
@property (nonatomic) FilterType type;
@property (strong, nonatomic) NSMutableArray *connectionsArr;
- (void)reconnect:(NSURLConnection *)connection;
- (NSData *)appendDataFromDatas:(NSMutableArray *)datas;
- (NSArray *)parseAccessToken:(NSData *)data;
- (void)sendRequestByParams:(NSDictionary *)paramDic andURL:(NSString *)URL;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)getAccessToken;
@end

@protocol RequestSenderDelegate <NSObject>
@optional
- (void)accessTokenBack:(NSArray *)accessTokenData;
- (void)requestFaildWithMessage:(NSString *)message connection:(NSURLConnection *)connection;
@end
