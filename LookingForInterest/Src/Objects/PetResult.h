//
//  PetResult.h
//  LookingForInterest
//
//  Created by Wayne on 3/4/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PetResult : NSObject
@property (strong, nonatomic) NSString *start;
@property (strong, nonatomic) NSString *previous;
@property (strong, nonatomic) NSString*next;
@property (strong, nonatomic) NSString *total;
@property (strong, nonatomic) NSString *offset;
@property (strong, nonatomic) NSDictionary *filters;
- (id)initWithResult:(NSDictionary *)result;
@end
