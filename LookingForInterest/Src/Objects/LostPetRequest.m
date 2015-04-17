//
//  LostPetRequest.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/13/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetRequest.h"
#import "LostPet.h"

@implementation LostPetRequest
- (void)setLostPetRequestDelegate:(id<LostPetRequestDelegate>)lostPetRequestDelegate {
    _lostPetRequestDelegate = lostPetRequestDelegate;
    self.delegate = _lostPetRequestDelegate;
}

- (void)sendRequestForLostPetWithLostPetFilters:(LostPetFilters *)lostPetFilters {
    NSString *filterContent = [lostPetFilters filterContent];
    
    NSString *filterString = [NSString stringWithFormat:@"%@=%@",kLostPetFiltersKey,filterContent];
    NSString *urlString = [NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@&%@",kLostPetDomain,kLostPetUnitIDKey,kLostPetUnitIDValue,kLostPetTopKey,@"20",kLostPetSkipKey,@"0",filterString];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    [connection start];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.lostPetRequestDelegate) {
        if ([self.lostPetRequestDelegate respondsToSelector:@selector(lostPetResultBack:)]) {
            NSMutableArray *lostPets = [self parseLostPetResultData:[super appendDataFromDatas:self.receivedDatas]];
            [self.lostPetRequestDelegate lostPetResultBack:lostPets];
        }
    } else {
        [Utilities stopLoading];
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
@end
