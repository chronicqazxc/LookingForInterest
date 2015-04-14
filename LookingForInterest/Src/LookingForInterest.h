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
#define kLookingForInterestHerokuURL(directory) (directory && ![directory isEqualToString:@""])?[NSString stringWithFormat:@"https://animal-hospital.herokuapp.com/api/v1/%@",directory]:@"https://animal-hospital.herokuapp.com/api/v1/"
#define kLookingForInterestTestURL @"http://Waynes-MacBook-Pro.local:3000/api/v1/"
#define kGetInitMenuURL @"datas/get_init_menus/"
#define kGetAnimalHospitalInformation @"datas/get_animal_hospital_information/"
#define kGetRangesURL @"datas/get_ranges/"
#define kGetCitiesURL @"datas/get_cities/"
#define kGetMenuTypesURL @"datas/get_menu_types/"
#define kGetMajorTypesURL @"datas/get_major_types/"
#define kGetMinorTypesURL @"datas/get_minor_types/"
#define kGetStoresURL @"datas/get_stores/"
#define kGetDetailURL @"datas/get_detail/"
#define kGetDefaultImagesURL @"datas/get_default_images/"
//#define kGetAccessToken @"tokens/get_access_token/"
#define kGetAccessToken @"tokens/get_access_token2/"
#define kLookingForInterestUserDefaultKey @"LookingForInterestMenu"
#define kAccessTokenKey @"access_token"
#define kHospitalSourceKey @"source"
#define kHospitalTitleKey @"title"
#define kHospitalUpdateDateKey @"update_date"
#define kHospitalFunctionOpenKey @"function_open"
#define kHospitalFunctionCloseReasonKey @"close_reason"

#pragma mark - ThingsAboutAnimals Version URL
#define kThingAboutAnimalsVersionURL @"datas/get_ios_app_version"

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

#pragma mark - Lost pet URL
#define kLostPetDomain @"http://data.coa.gov.tw/Service/OpenData/DataFileService.aspx"
#define kLostPetUnitIDKey @"UnitId"
#define kLostPetUnitIDValue @"127"
#define kLostPetTopKey @"$top"
#define kLostPetSkipKey @"$skip"
#define kLostPetFiltersKey @"$filter"

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

#pragma mark - Favorite store colors
#define kColorIsFavoriteStore [UIColor redColor]
#define kColorNotFavoriteStore [UIColor greenColor]
#pragma mark -

#pragma mark - Second Storyboard
#define kSecondStoryboard @"Main2"
#define kLostPetStoryboardID @"LostPet"

typedef enum filterType {
    FilterTypeAnimalHospitalInformation,
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
