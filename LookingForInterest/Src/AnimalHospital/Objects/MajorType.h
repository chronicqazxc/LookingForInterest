//
//  MajorType.h
//  LookingForInteresting
//
//  Created by Wayne on 2/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MajorType : NSObject
@property (strong, nonatomic) NSString *typeID;
@property (strong, nonatomic) NSString *typeDescription;

- (id)initWithMajorTypeDic:(NSDictionary *)majorTypeDic;
@end
