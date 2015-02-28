//
//  AnimalHospitalViewController.h
//  LookingForInterest
//
//  Created by Wayne on 2/25/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AnimalHospitalViewController : UIViewController
@property (strong, nonatomic) Store *store;
@property (strong, nonatomic) Detail *detail;
@property (nonatomic) CLLocationCoordinate2D start;
@property (nonatomic) CLLocationCoordinate2D destination;
@property (strong, nonatomic) NSString *accessToken;
@end
