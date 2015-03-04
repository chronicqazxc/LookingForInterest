//
//  LookingForInterest_Tests.m
//  LookingForInterest Tests
//
//  Created by Wayne on 3/4/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Pet.h"
#import "PetResult.h"

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

- (NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary
{
//    NSMutableString *urlWithQuerystring = [[NSMutableString alloc] initWithString:urlString];
    NSMutableString *urlWithQuerystring = [[NSMutableString alloc] initWithString:@""];
    for (id key in dictionary) {
        NSString *keyString = [key description];
        NSString *valueString = [[dictionary objectForKey:key] description];
        
//        if ([urlWithQuerystring rangeOfString:@"?"].location == NSNotFound) {
//            [urlWithQuerystring appendFormat:@"?%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
//        } else {
//            [urlWithQuerystring appendFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
//        }
        [urlWithQuerystring appendFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
    }
    return urlWithQuerystring;
}

- (NSString*)urlEscapeString:(NSString *)unencodedString
{
    CFStringRef originalStringRef = (__bridge_retained CFStringRef)unencodedString;
    NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8);
    CFRelease(originalStringRef);
    return s;
}

- (void)testURL {
//    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://210.65.114.15/api/action/datastore_search?resource_id=c57f54e2-8ac3-4d30-bce0-637a8968796e&limit=500"]];
    
    NSURL *url = [NSURL URLWithString:@"http://210.65.114.15/api/action/datastore_search?"];
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:@"c57f54e2-8ac3-4d30-bce0-637a8968796e" forKey:@"resource_id"];
    [dataDic setObject:@20 forKey:@"limit"];
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    [filters setObject:@"年輕" forKey:@"Age"];
    [dataDic setObject:filters forKey:@"filters"];
    
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dataDic options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:postData];

    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    if (error == nil) {
        NSDictionary *encodeStrings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSString *success = [NSString stringWithFormat:@"%@",[encodeStrings objectForKey:@"success"]];
        if ([success isEqualToString:@"1"]) {
            NSDictionary *result = [encodeStrings objectForKey:@"result"];
            PetResult *petResult = [self parseResult:result];
            NSArray *records = [result objectForKey:@"records"];
            NSMutableArray *pets = [NSMutableArray array];
            for (NSDictionary *record in records) {
                [pets addObject:[self parseRecord:record]];
            }
        } else {
            NSLog(@"faild");
        }
        
    }
    
}

- (PetResult *)parseResult:(NSDictionary *)result {
    PetResult *petResult = [[PetResult alloc] initWithResult:result];
    return petResult;
}

- (Pet *)parseRecord:(NSDictionary *)record {
    Pet *pet = [[Pet alloc] initWithRecord:record];
    return pet;
}
@end
