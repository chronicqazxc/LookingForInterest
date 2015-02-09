//
//  LookingForInterest.h
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "Store.h"
#import "Menu.h"
#import <CoreLocation/CoreLocation.h>

#ifndef LookingForInteresting_LookingForInterest_h
#define LookingForInteresting_LookingForInterest_h

#define kLookingForInterestURL kLookingForInterestHerokuURL
#define kLookingForInterestHerokuURL @"https://looking-for-interest.herokuapp.com/"
#define kLookingForInterestTestURL @"http://localhost:3000/"
#define kGetInitMenuURL @"menus/get_init_menus/"
#define kGetRangesURL @"menus/get_ranges/"
#define kGetMajorTypesURL @"major_types/get_major_types/"
#define kGetMinorTypesURL @"minor_types/get_minor_types/"
#define kGetStoresURL @"stores/get_stores/"
#define kGetStoresByLocationURL @"stores/get_stores_from_my_position/"
#define kLookingForInterestUserDefaultKey @"LookingForInterestMenu"

typedef enum filterType {
    FilterTypeMenu,
    FilterTypeMajorType,
    FilterTypeMinorType,
    FilterTypeStore,
    FilterTypeRange,
    SearchStores
} FilterType;

#endif
