//
//  GoogleMapNavigation.h
//  LookingForInterest
//
//  Created by Wayne on 2/26/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#ifndef LookingForInterest_GoogleMapNavigation_h
#define LookingForInterest_GoogleMapNavigation_h

#define kGoogleMapType kGoogleMapTypeCallback
#define kGoogleMapTypeNormal @"comgooglemaps://"
#define kGoogleMapTypeCallback @"comgooglemaps-x-callback://"

#define kNavigateURLString(startLatitude, startLongitude, endLatitude, endLongitude, centerLatitude, centerLongitude, directionsMode, zoom) [NSString stringWithFormat:@"%@?saddr=%f,%f&daddr=%f,%f&center=%f,%f&directionsmode=%@&zoom=%d&x-success=animalhospital://?resume=true&x-source=thingsaboutpets",kGoogleMapType ,startLatitude, startLongitude, endLatitude, endLongitude, centerLatitude, centerLongitude, directionsMode, zoom]

#define kPolylineURLString(startLatitude, startLongitude, endLatitude, endLongitude, mode) [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@,%@&destination=%@,%@&mode=%@", startLatitude, startLongitude, endLatitude, endLongitude, mode]

#define kGoogleMapsAppURL @"itms://itunes.apple.com/en/app/google-maps/id585027354?mt=8"

#define kDirectionsModeDrivingTitle @"開車"
#define kDirectionsModeTransitTitle @"大眾交通工具"
#define kDirectionsModeBicyclingTitle @"腳踏車"
#define kDirectionsModeWalkingTitle @"走路"

#define kDirectionsModeDriving @"driving"
#define kDirectionsModeTransit @"transit"
#define kDirectionsModeBicycling @"bicycling"
#define kDirectionsModeWalking @"walking"

#define kGoogleMapStaticMapURL(center,color,size) [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=14&size=%@x%@&markers=color:%@%7Clabel:!%7C%@",center,size,size,color,center]
#endif
