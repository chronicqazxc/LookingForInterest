//
//  LookingForInterest_Tests.m
//  LookingForInterest Tests
//
//  Created by Wayne on 2/20/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface LookingForInterest_Tests : XCTestCase

@end

@implementation LookingForInterest_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testArray {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@"3"];
    BOOL result1 = [array containsObject:@"3"];
    BOOL result2 = [array containsObject:@"2"];
    NSLog(@"%d,%d",result1,result2);
}

@end
