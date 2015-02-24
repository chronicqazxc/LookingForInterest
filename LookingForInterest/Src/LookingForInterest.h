//
//  LookingForInterest.h
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "Store.h"
#import "Menu.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "Utilities.h"

#ifndef LookingForInteresting_LookingForInterest_h
#define LookingForInteresting_LookingForInterest_h

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
#define kGetStoresByLocationURL @"datas/get_stores_from_my_position/"
#define kGetAccessToken @"tokens/get_access_token/"
#define kLookingForInterestUserDefaultKey @"LookingForInterestMenu"
#define kAccessTokenKey @"access_token"

typedef enum filterType {
    FilterTypeMenu,
    FilterTypeMajorType,
    FilterTypeMinorType,
    FilterTypeStore,
    FilterTypeRange,
    FilterTypeCity,
    SearchStores,
    GetAccessToken,
    FilterTypeMenuTypes
} FilterType;

typedef NS_ENUM(NSInteger, Direction) {
    DirectionUp = 0,
    DirectionLeft,
    DirectionDown,
    DirectionRight,
    DirectionMirror
};
#endif
