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
#import "Pet.h"
#import "PetFilters.h"
#import "PetResult.h"
#import "Utilities.h"
#import "AppDelegate.h"

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
#define kHospitalSourceKey @"source"
#define kHospitalTitleKey @"title"
#define kHospitalUpdateDateKey @"update_date"
#define kHospitalFunctionOpenKey @"function_open"
#define kHospitalFunctionCloseReasonKey @"close_reason"
#pragma mark -
#pragma mark - Adopt animals URL
#define kAppStoreURL @"http://appstore.com/關心毛小孩" // @"https://itunes.apple.com/tw/app/guan-xin-mao-xiao-hai/id977007555?mt=8&uo=4"
#define kAdoptAnimalsFacebookShareURL @"http://www.tcapo.gov.taipei"
#define kAdoptAnimalsInTPCURL @"http://data.taipei/opendata/datalist/apiAccess"
#define kResourceScopeKey @"scope"
#define kResourceScope @"resourceAquire"
#define kResourceIDKey @"id"
#define kResourceRIDKey @"rid"
#define kResourceID @"6a3e862a-e1cb-4e44-b989-d35609559463"
#define kResourceRID @"f4a75ba9-7721-4363-884d-c3820b0b917c"
#define kLimitKey @"limit"
#define kLimitValue @20

#pragma mark - Messages
#define kNoPhoneNumberAlertTitle @"Opps!"
#define kNoPhoneNumberAlertMessage @"資料庫中沒有建立電話號碼"
#define kWebSiteActionTitle @"網路搜尋更多資訊"
#define kFavoriteStoresKey @"favoriteStoresKey"
#define kFavoriteAnimalsKey @"favoriteAnimalsKey"
#define kManulMenuKey @"manulMenuKey"
#define kManulAdoptListKey @"manulAdoptListKey"
#define kManulAdoptDetailKey @"manulAdoptDetailKey"
#define kManulHospitalMenuKey @"manulHospitalMenuKey"
#define kManulHospitalListKey @"manulHospitalListKey"
#define kAddToFavorite @"加到我的最愛"
#define kRemoveFromFavorite @"移除我的最愛"
#pragma mark -

#pragma mark - AdoptAnimalNames
#define kAdoptFilterAll @"全"
#define kAdoptFilterAgeBaby @"幼齡"
#define kAdoptFilterAgeYoung @"年輕"
#define kAdoptFilterAgeAdult @"成年"
#define kAdoptFilterAgeOld @"老年"
#define kAdoptFilterTypeDog @"犬"
#define kAdoptFilterTypeCat @"貓"
#define kAdoptFilterTypeOther @"其他"
#define kAdoptFilterTypeMyFavorite @"我的最愛"
#define kAdoptFilterGenderMale @"雄"
#define kAdoptFilterGenderFemale @"雌"
#define kAdoptFilterGenderUnknow @"未知"
#define kAdoptFilterBodyMini @"微"
#define kAdoptFilterBodySmall @"小"
#define kAdoptFilterBodyMiddle @"中"
#define kAdoptFilterBodyBig @"大"
#pragma mark - 

#pragma mark - Favorite store colors
#define kColorIsFavoriteStore [UIColor redColor]
#define kColorNotFavoriteStore [UIColor greenColor]
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
    GetDefaultImages,
    AdoptAnimals,
    PetThumbNail,
    CheckFavoriteAnimals
} FilterType;

typedef NS_ENUM(NSInteger, Direction) {
    DirectionUp = 0,
    DirectionLeft,
    DirectionDown,
    DirectionRight,
    DirectionMirror
};
#endif
