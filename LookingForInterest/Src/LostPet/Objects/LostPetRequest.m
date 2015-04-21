//
//  LostPetRequest.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/13/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetRequest.h"
#import "LostPet.h"
#import "GoogleMapNavigation.h"

@interface LostPetRequest()
@property (strong, nonatomic) NSIndexPath *indexPath;
@end

@implementation LostPetRequest
- (void)setLostPetRequestDelegate:(id<LostPetRequestDelegate>)lostPetRequestDelegate {
    _lostPetRequestDelegate = lostPetRequestDelegate;
    self.delegate = _lostPetRequestDelegate;
}

- (void)sendRequestForLostPetGeocoder:(LostPet *)lostPet indexPath:(NSIndexPath *)indexPath {
    self.lostPetRequestType = RequestTypeLostPetGeocoder;
    self.indexPath = indexPath;
    NSString *lostLocation = kGoogleGeocodeURL(lostPet.lostPlace);
    lostLocation = [lostLocation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:lostLocation];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)sendRequestForLostPetWithLostPetFilters:(LostPetFilters *)lostPetFilters top:(NSString *)top skip:(NSString *)skip{
    NSString *filterContent = [lostPetFilters filterContent];
    
    NSString *filterString = [NSString stringWithFormat:@"%@=%@",kLostPetFiltersKey,filterContent];
    
    NSString *urlString = [NSString stringWithFormat:
                           @"%@?%@=%@&%@=%@&%@=%@&%@",
                           kLostPetDomain,
                           kLostPetUnitIDKey,
                           kLostPetUnitIDValue,
                           kLostPetTopKey,
                           top,
                           kLostPetSkipKey,
                           skip,
                           filterString];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    [connection start];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    switch (self.lostPetRequestType) {
        case RequestTypeLostPetResult:
            if (self.lostPetRequestDelegate) {
                if ([self.lostPetRequestDelegate respondsToSelector:@selector(lostPetResultBack:)]) {
                    NSMutableArray *lostPets = [self parseLostPetResultData:[super appendDataFromDatas:self.receivedDatas]];
                    [self.lostPetRequestDelegate lostPetResultBack:lostPets];
                }
            } else {
                [Utilities stopLoading];
            }
            break;
        case RequestTypeLostPetGeocoder:
            if (self.lostPetRequestDelegate) {
                if ([self.lostPetRequestDelegate respondsToSelector:@selector(lostPetLocationBack:indexPath:)]) {
                    NSMutableDictionary *locationDic = [self parseGeocoder:[super appendDataFromDatas:self.receivedDatas]];
                    [self.lostPetRequestDelegate lostPetLocationBack:locationDic indexPath:self.indexPath];
                } else {
                    [Utilities stopLoading];
                }
            }
            break;
        default:
            [Utilities stopLoading];
            break;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (NSMutableArray *)parseLostPetResultData:(NSData *)data{
    NSError *error = nil;
    NSArray *lostPets = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSMutableArray *arr = [NSMutableArray array];
    for (NSMutableDictionary *petDic in lostPets) {
        LostPet *lostPet = [[LostPet alloc] initWithDic:petDic];
        [arr addObject:lostPet];
    }
    return arr;
}

- (NSMutableDictionary *)parseGeocoder:(NSData *)data {
    NSError *error = nil;
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSString *status = [dataDic objectForKey:@"status"];
    NSMutableDictionary *locationDic = [NSMutableDictionary dictionary];
    if ([status isEqualToString:@"OK"]) {
        NSArray *results = [dataDic objectForKey:@"results"];
        NSDictionary *result = [results firstObject];
        NSDictionary *geometry = [result objectForKey:@"geometry"];
        NSDictionary *location = [geometry objectForKey:@"location"];
        double lat = [[location objectForKey:@"lat"] doubleValue];
        double lng = [[location objectForKey:@"lng"] doubleValue];
        [locationDic setObject:[NSNumber numberWithDouble:lat] forKey:@"latitude"];
        [locationDic setObject:[NSNumber numberWithDouble:lng] forKey:@"longitude"];
    } else {
        NSLog(@"faild");
    }
    return locationDic;
}
@end
