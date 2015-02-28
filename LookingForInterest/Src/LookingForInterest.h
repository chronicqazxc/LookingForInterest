//
//  LookingForInterest.h
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "MajorType.h"
#import "MinorType.h"
#import "Store.h"
#import "PageController.h"
#import "Menu.h"
#import "Detail.h"
#import "Utilities.h"

#ifndef LookingForInteresting_LookingForInterest_h
#define LookingForInteresting_LookingForInterest_h

#pragma mark - API URL
#define kLookingForInterestURL kLookingForInterestHerokuURL
#define kLookingForInterestHerokuURL @"https://animal-hospital.herokuapp.com/api/v1/"
#define kLookingForInterestTestURL @"http://Waynes-MacBook-Pro.local:3000/api/v1/"
#define kGetInitMenuURL @"datas/get_init_menus/"
#define kGetRangesURL @"datas/get_ranges/"
#define kGetCitiesURL @"datas/get_cities/"
#define kGetMenuTypesURL @"datas/get_menu_types/"
#define kGetMajorTypesURL @"datas/get_major_types/"
#define kGetMinorTypesURL @"datas/get_minor_types/"
#define kGetStoresURL @"datas/get_stores/"
#define kGetDetailURL @"datas/get_detail/"
#define kGetDefaultImagesURL @"datas/get_default_images/"
#define kGetAccessToken @"tokens/get_access_token/"
#define kLookingForInterestUserDefaultKey @"LookingForInterestMenu"
#define kAccessTokenKey @"access_token"
#pragma mark -

#pragma mark - Messages
#define kNoPhoneNumberAlertTitle @"Opps!"
#define kNoPhoneNumberAlertMessage @"資料庫中沒有建立電話號碼"
#define kWebSiteActionTitle @"網路搜尋更多資訊"
#pragma mark -

typedef enum filterType {
    FilterTypeMenu,
    FilterTypeMajorType,
    FilterTypeMinorType,
    FilterTypeStore,
    FilterTypeRange,
    FilterTypeCity,
    SearchStores,
    SearchDetail,
    GetAccessToken,
    FilterTypeMenuTypes,
    GetDefaultImages
} FilterType;

typedef NS_ENUM(NSInteger, Direction) {
    DirectionUp = 0,
    DirectionLeft,
    DirectionDown,
    DirectionRight,
    DirectionMirror
};
#endif
