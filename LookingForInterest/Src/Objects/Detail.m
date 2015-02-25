//
//  Detail.m
//  LookingForInterest
//
//  Created by Wayne on 2/25/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "Detail.h"

@implementation Detail
- (id)initWithDetailDic:(NSDictionary *)detailDic {
    self = [super init];
    if (self) {
        self.openTime = [detailDic objectForKey:@"open_time"]?[detailDic objectForKey:@"open_time"]:@"";
        self.introduction = [detailDic objectForKey:@"introduction"]?[detailDic objectForKey:@"introduction"]:@"";
        self.iconURL = [detailDic objectForKey:@"icon_url"]?[detailDic objectForKey:@"icon_url"]:@"";
        self.imageURL1 = [detailDic objectForKey:@"image_url_1"]?[detailDic objectForKey:@"image_url_1"]:@"";
        self.imageURL2 = [detailDic objectForKey:@"image_url_2"]?[detailDic objectForKey:@"image_url_2"]:@"";
        self.imageURL3 = [detailDic objectForKey:@"image_url_3"]?[detailDic objectForKey:@"image_url_3"]:@"";
        self.webAddress = [detailDic objectForKey:@"web_address"]?[detailDic objectForKey:@"web_address"]:@"";
        self.totalRate = [detailDic objectForKey:@"total_rate"]==[NSNull null]?0:[[detailDic objectForKey:@"total_rate"] intValue];
        self.averageRate = [detailDic objectForKey:@"average_rate"]==[NSNull null]?0.0:[[detailDic objectForKey:@"average_rate"] floatValue];
        self.otherInfo1 = [detailDic objectForKey:@"other_info_1"]?[detailDic objectForKey:@"other_info_1"]:@"";
        self.otherInfo2 = [detailDic objectForKey:@"other_info_2"]?[detailDic objectForKey:@"other_info_2"]:@"";
        self.otherInfo3 = [detailDic objectForKey:@"other_info_3"]?[detailDic objectForKey:@"other_info_3"]:@"";
        self.otherInfo4 = [detailDic objectForKey:@"other_info_4"]?[detailDic objectForKey:@"other_info_4"]:@"";
        self.otherInfo5 = [detailDic objectForKey:@"other_info_5"]?[detailDic objectForKey:@"other_info_5"]:@"";
    }
    return self;
}
@end
