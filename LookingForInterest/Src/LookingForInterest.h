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
#pragma mark -
#pragma mark - Adopt animals URL
#define kAdoptAnimalsInTPCURL @"http://210.65.114.15/api/action/datastore_search"
#define kResourceIDKey @"resource_id"
#define kResourceID @"c57f54e2-8ac3-4d30-bce0-637a8968796e"
#define kLimitKey @"limit"
#define kLimitValue @20

#pragma mark - Messages
#define kNoPhoneNumberAlertTitle @"Opps!"
#define kNoPhoneNumberAlertMessage @"資料庫中沒有建立電話號碼"
#define kWebSiteActionTitle @"網路搜尋更多資訊"
#define kFavoriteStoresKey @"favoriteStoresKey"
#define kAddToFavorite @"加到我的最愛"
#define kRemoveFromFavorite @"移除我的最愛"
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
    PetThumbNail
} FilterType;

typedef NS_ENUM(NSInteger, Direction) {
    DirectionUp = 0,
    DirectionLeft,
    DirectionDown,
    DirectionRight,
    DirectionMirror
};
#endif
