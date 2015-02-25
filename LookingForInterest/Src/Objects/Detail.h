//
//  Detail.h
//  LookingForInterest
//
//  Created by Wayne on 2/25/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LookingForInterest.h"

@interface Detail : NSObject
@property (strong, nonatomic) Store *store;
@property (strong, nonatomic) NSString *openTime;
@property (strong, nonatomic) NSString *introduction;
@property (strong, nonatomic) NSString *iconURL;
@property (strong, nonatomic) NSString *imageURL1;
@property (strong, nonatomic) NSString *imageURL2;
@property (strong, nonatomic) NSString *imageURL3;
@property (strong, nonatomic) NSString *webAddress;
@property (nonatomic) NSUInteger totalRate;
@property (nonatomic) float averageRate;
@property (strong, nonatomic) NSString *otherInfo1;
@property (strong, nonatomic) NSString *otherInfo2;
@property (strong, nonatomic) NSString *otherInfo3;
@property (strong, nonatomic) NSString *otherInfo4;
@property (strong, nonatomic) NSString *otherInfo5;

- (id)initWithDetailDic:(NSDictionary *)detailDic;
@end
