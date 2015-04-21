//
//  Store.h
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Store : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSNumber *distance;
@property (strong, nonatomic) NSString *imageURL1;
@property (strong, nonatomic) NSString *imageURL2;
@property (strong, nonatomic) NSString *imageURL3;
@property (strong, nonatomic) NSString *totalRate;
@property (strong, nonatomic) NSString *averageRate;
@property (strong, nonatomic) NSString *storeID;
@property (strong, nonatomic) NSString *majorTypeID;
@property (strong, nonatomic) NSString *minorTypeID;
@property (strong, nonatomic) NSArray *ranges;

- (id)initWithStoreDic:(NSDictionary *)storeDic;
@end
