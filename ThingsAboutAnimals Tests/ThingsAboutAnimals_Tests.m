//
//  ThingsAboutAnimals_Tests.m
//  ThingsAboutAnimals Tests
//
//  Created by Wayne on 3/12/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LookingForInterest.h"
#import "LostPetRequest.h"
#import "LostPet.h"
#import "LostPetFilters.h"
#import "LostPetRequest.h"

@interface ThingsAboutAnimals_Tests : XCTestCase <LostPetRequestDelegate>
@property (nonatomic) BOOL callbackInvoked;
@end

@implementation ThingsAboutAnimals_Tests

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
            //            PetResult *petResult = [self parseResult:result];
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

- (void)testNewURL {
    //    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://210.65.114.15/api/action/datastore_search?resource_id=c57f54e2-8ac3-4d30-bce0-637a8968796e&limit=500"]];
    
    NSURL *url = [NSURL URLWithString:@"http://data.taipei/opendata/datalist/apiAccess?rid=f4a75ba9-7721-4363-884d-c3820b0b917c&scope=resourceAquire&id=6a3e862a-e1cb-4e44-b989-d35609559463&limit=20&offset=20"];
    
    NSError *error = nil;
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    if (error == nil) {
        NSDictionary *encodeStrings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSString *success = [NSString stringWithFormat:@"%@",[encodeStrings objectForKey:@"success"]];
        if ([success isEqualToString:@"1"]) {
            NSDictionary *result = [encodeStrings objectForKey:@"result"];
            //            PetResult *petResult = [self parseResult:result];
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

- (void) testPet {
    //    Pet *pet = [[Pet alloc] init];
    PetResult *petResult = [[PetResult alloc] init];
    NSLog(@"%@",petResult);
}

- (void)testCharactorInIndex {
    NSString *encoded = @"ivzwCow~dVbHjd@Y|o@[lrAoS`jBaJbiBbO|OvLvRaXvn@eWfn@rRte@dpAr`D`w@l{Efl@jv@xV`oA|Y`qApEbcAni@lZzNhk@tBlnAhn@laBpRn{BaCzvBha@`pAvdAthBzeAnsEh^rb@v]bNv\r~@j}A~jAdp@bz@ziB`zBbMptDwFt\nXv|@vr@bqBbdAxtEnc@luBy@vwArAtfAdS~cAiAt]bj@`m@eI`PnIpVrPbUjRh[nYgTp_@|CpWhI|M|XvwA`b@jw@~_@heB|aCv_An[hd@lkBd`@jrArb@hNz]`Od]pGjf@za@pw@xRxa@rLfVb]xaAjhBvr@rcAxbAdX~qAhDxg@rWznAltA|rAdwAxQ~Xlj@rfBd}@hcArd@blAxbAzoApn@bZrvAlwAOfXze@hy@`q@h`@jcAfiApYzj@h`@pHb\dT|Mz\ni@dTrhAdv@j}Ar_@zrD|`@bnBbcAl\pMUhR`DfTdp@nl@phAlj@h_@rn@raBtl@`kAxeAdd@zn@lrA~a@xqAno@jfArtAv{@bw@rcBgAbcBpiAfsCbl@~xBhhAfzD~v@naD|cAxvDvmA`pBzp@bhBthAbw@jQd\fo@D|R_Jxy@{AlVdE`LvCveAnR`n@nFxq@iF`e@gPta@cHds@dInQnFzd@oEh^lAjg@a@pcAxKj{AxN`jAfGvTgBxHsFh]dGbcBtl@rlA|w@btDuRteDyJz]cFlv@v[|qB`|@twBvz@z`Ad@dqExEj}@gGboAwXj{B|WjgAzVrRhTn@hO|OtK|s@bObaAnUlsAbv@n{@d}@b]tF~fAfFnfAQpQ_A``@ns@dbAz|@bwAfl@p`Azd@xuCbeAl^rEr@hAvZ`Fxm@_DfxAzl@noAdb@v]nTbHx[fgAnDpkDpj@xQoCrRx@n|@vkAbu@hh@xhAfHxgCpErlDnGxxEnK|l@vOtRjSvj@pLtQWhGhNjGjIpInKvsAbi@vl@pV`f@dBjh@`f@vb@xf@pkBllAdhEv@xWz@|HjGbQvCba@qId~CoWd`BqCht@fTrjAjMzs@j]tWjEdF|Tlh@xJprAjUvKuAni@cF~JnMRXj\dKlx@aBx{@z_@~w@|Jvn@sCjf@zHrpA`oAzlAtErh@he@rl@l`Ape@xz@~U@vz@qUfwAyItzAia@pfAmO~|@|@hjAz\b`@zBp[}Lxv@kI|g@nBhuA`Y~oA~DpaCcb@zpDcYlmA}SneBaYnjCyb@|zAfUpnA|MzpBof@ttA_T~dBm`@jaBwHrt@aUNwC";
    NSInteger a = [encoded length];
    NSInteger b = [encoded characterAtIndex:1276];
    //- 63
    NSLog(@"%d",b);
}

- (void)testLostPet {
    LostPetFilters *lostPetFilters = [[LostPetFilters alloc] init];
    lostPetFilters.variety = @"貓";
    lostPetFilters.gender = @"母";
    lostPetFilters.chipNumber = @"92";
    NSString *filterContent = [lostPetFilters filterContent];
    
    NSString *filterString = [NSString stringWithFormat:@"%@=%@",kLostPetFiltersKey,filterContent];
    NSString *urlString = [NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@&%@",kLostPetDomain,kLostPetUnitIDKey,kLostPetUnitIDValue,kLostPetTopKey,@"20",kLostPetSkipKey,@"0",filterString];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSError *error = nil;
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    if (error == nil) {
        NSArray *lostPets = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *petDic in lostPets) {
            LostPet *lostPet = [[LostPet alloc] initWithDic:petDic];
            [arr addObject:lostPet];
        }
        NSLog(@"encodeStrings:%@",arr);
        
    } else {
        NSLog(@"faild");
    }
    
}

- (void)testLostPetRequest {
    LostPetRequest *lostPetRequest = [[LostPetRequest alloc] init];
    lostPetRequest.lostPetRequestDelegate = self;
    LostPetFilters *lostPetFilters = [[LostPetFilters alloc] init];
    lostPetFilters.variety = @"貓";
    lostPetFilters.gender = @"母";
    [lostPetRequest sendRequestForLostPetWithLostPetFilters:lostPetFilters];
    XCTAssertTrue(self.callbackInvoked, @"Delegate should send -something:delegateInvoked:");
}

- (void)lostPetResultBack:(NSArray *)lostPets {
    self.callbackInvoked = YES;
    NSLog(@"%@",lostPets);
}

@end
