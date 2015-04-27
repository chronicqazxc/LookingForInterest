//
//  AdoptAnimalRequest.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/13/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AdoptAnimalRequest.h"
#define kPetThumbNailHeigh 120
#define kPetThumbNailWeigh 120

@interface AdoptAnimalRequest()
@property (strong, nonatomic) PetFilters *petFilters;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSMutableArray *checkFavoriteAnimalsArr;
@property (strong, nonatomic) NSMutableArray *checkFavoriteAnimalsResult;
@end

@implementation AdoptAnimalRequest
- (void)setAdoptAnimalRequestDelegate:(id<AdoptAnimalRequestDelegate>)adoptAnimalRequestDelegate {
    _adoptAnimalRequestDelegate = adoptAnimalRequestDelegate;
    self.delegate = _adoptAnimalRequestDelegate;
}

- (void)sendRequestForAdoptAnimalsWithPetFilters:(PetFilters *)petFilters {
    self.adoptAnimalRequestType = RequestTypeAdoptAnimals;
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:kResourceScope forKey:kResourceScopeKey];
    [dataDic setObject:kResourceID forKey:kResourceIDKey];
    [dataDic setObject:kResourceRID forKey:kResourceRIDKey];
    [dataDic setObject:kLimitValue forKey:kLimitKey];
    if (petFilters && petFilters.offset)
        [dataDic setObject:[NSNumber numberWithInt:[petFilters.offset intValue]] forKey:@"offset"];
    
    NSMutableArray *filters = [NSMutableArray array];
    if (petFilters.acceptNum)
        [filters addObject:petFilters.acceptNum];
    if (petFilters.isSterilization)
        [filters addObject:petFilters.isSterilization];
    if (petFilters.name)
        [filters addObject:petFilters.name];
    if (petFilters.variety)
        [filters addObject:petFilters.variety];
    if (petFilters.age)
        [filters addObject:petFilters.age];
    if (petFilters.childreAnlong)
        [filters addObject:petFilters.childreAnlong];
    if (petFilters.resettlement)
        [filters addObject:petFilters.resettlement];
    if (petFilters.sex)
        [filters addObject:petFilters.sex];
    if (petFilters.note)
        [filters addObject:petFilters.note];
    if (petFilters.phone)
        [filters addObject:petFilters.phone];
    if (petFilters.reason)
        [filters addObject:petFilters.reason];
    if (petFilters.imageName)
        [filters addObject:petFilters.imageName];
    if (petFilters.hairType)
        [filters addObject:petFilters.hairType];
    if (petFilters.build)
        [filters addObject:petFilters.build];
    if (petFilters.chipNum)
        [filters addObject:petFilters.chipNum];
    if (petFilters.petID)
        [filters addObject:petFilters.petID];
    if (petFilters.type)
        [filters addObject:petFilters.type];
    if (petFilters.email)
        [filters addObject:petFilters.email];
    if (petFilters.bodyweight)
        [filters addObject:petFilters.bodyweight];
    
    NSString *urlString = [self composeURL:kAdoptAnimalsInTPCURL withParameters:[self generateParameterByDic:dataDic]andFilters:filters];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    self.petFilters = petFilters;
    
    [connection start];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)checkFavoriteAnimals:(NSArray *)animals {
    self.adoptAnimalRequestType = RequestTypeCheckFavoriteAnimals;
    self.checkFavoriteAnimalsResult = [NSMutableArray array];
    self.checkFavoriteAnimalsArr = [NSMutableArray arrayWithArray:animals];
    for (Pet* pet in animals) {
        PetFilters *petFilters = [[PetFilters alloc] init];
        petFilters.acceptNum = pet.acceptNum;
        
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
        [dataDic setObject:kResourceScope forKey:kResourceScopeKey];
        [dataDic setObject:kResourceID forKey:kResourceIDKey];
        [dataDic setObject:kResourceRID forKey:kResourceRIDKey];
        [dataDic setObject:kLimitValue forKey:kLimitKey];
        
        NSMutableArray *filters = [NSMutableArray array];
        
        if (petFilters.acceptNum)
            [filters addObject:petFilters.acceptNum];
        
        NSString *urlString = [self composeURL:kAdoptAnimalsInTPCURL withParameters:[self generateParameterByDic:dataDic]andFilters:filters];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        [urlRequest setHTTPMethod:@"GET"];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        [connection start];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSMutableDictionary *connectionObj = [NSMutableDictionary dictionary];
        [connectionObj setObject:connection forKey:@"connection"];
        NSMutableArray *dataArr = [NSMutableArray array];
        [connectionObj setObject:dataArr forKeyedSubscript:@"data"];
        [self.connectionsArr addObject:connectionObj];
    }
}

- (NSString *)composeURL:(NSString *)url withParameters:(NSMutableArray *)parameters andFilters:(NSMutableArray *)filters{
    NSMutableString *tempString = [NSMutableString string];
    
    for (NSString *parameter in parameters) {
        if ([parameters indexOfObject:parameter] == 0) {
            [tempString appendString:[NSString stringWithFormat:@"?%@",parameter]];
        } else {
            [tempString appendString:[NSString stringWithFormat:@"&%@",parameter]];
        }
    }
    for (NSString *filter in filters) {
        if ([filters indexOfObject:filter] == 0) {
            [tempString appendString:[NSString stringWithFormat:@"&q=%@",filter]];
        } else {
            [tempString appendString:[NSString stringWithFormat:@",%@",filter]];
        }
    }
    NSString *newUrl = [NSString stringWithFormat:@"%@%@",url,tempString];
    return newUrl;
}

- (NSMutableArray *)generateParameterByDic:(NSMutableDictionary *)dic {
    NSMutableArray *parameters = [NSMutableArray array];
    NSArray *keys = [dic allKeys];
    for (NSString *key in keys) {
        NSString *value = [dic objectForKey:key];
        NSString *parameter = [NSString stringWithFormat:@"%@=%@",key,value];
        [parameters addObject:parameter];
    }
    return parameters;
}

- (void)combineFavoriteAnimals:(NSData *)data connection:(NSURLConnection *)connection{
    NSError *error = nil;
    NSDictionary *encodeStrings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error == nil) {
        NSDictionary *result = [encodeStrings objectForKey:@"result"];
        NSArray *results = [result objectForKey:@"results"];
        for (NSDictionary *result in results) {
            [self.checkFavoriteAnimalsResult addObject:[self parseRecord:result]];
        }
        if ([self.checkFavoriteAnimalsResult count] == [self.checkFavoriteAnimalsArr count]) {
            if (self.adoptAnimalRequestDelegate && [self.adoptAnimalRequestDelegate respondsToSelector:@selector(checkFavoriteAnimalsResultBack:)]) {
                [self.adoptAnimalRequestDelegate checkFavoriteAnimalsResultBack:self.checkFavoriteAnimalsResult];
            }
        }
    } else {
        NSURL *url = connection.originalRequest.URL;
        NSString *urlString = url.absoluteString;
        NSArray * arr = [urlString componentsSeparatedByString:@"&q="];
        NSString *acceptNum = [arr lastObject];
        for (Pet *pet in self.checkFavoriteAnimalsArr) {
            if ([pet.acceptNum isEqualToString:acceptNum]) {
                [Utilities removeFromMyFavoriteAnimal:pet];
                [self.checkFavoriteAnimalsArr removeObject:pet];
                break;
            }
        }
    }
}

- (void)parsePetResultData:(NSData *)data withConnection:(NSURLConnection *)connection{
    NSError *error = nil;
    NSDictionary *encodeStrings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:[encodeStrings objectForKey:@"result"]];
    
    PetResult *petResult = [self parseResult:result];
    
    NSArray *results = [result objectForKey:@"results"];
    NSMutableArray *pets = [NSMutableArray array];
    for (NSDictionary *result in results) {
        [pets addObject:[self parseRecord:result]];
    }
    petResult.pets = pets;
    
    petResult.filters = self.petFilters;
    
    if (self.adoptAnimalRequestDelegate && [self.adoptAnimalRequestDelegate respondsToSelector:@selector(petResultBack:)]) {
        [self.adoptAnimalRequestDelegate petResultBack:petResult];
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

- (PetFilters *)parseFilters:(NSDictionary *)filters {
    PetFilters *petFilters = [[PetFilters alloc] initWithFilters:filters];
    return petFilters;
}

- (void)sendRequestForPetThumbNail:(Pet *)pet indexPath:(NSIndexPath *)indexPath {
    self.adoptAnimalRequestType = RequestTypePetThumbNail;
    self.indexPath = indexPath;
    NSURL *url = [NSURL URLWithString:pet.imageName];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)parseThumbNailData:(NSData *)data {
    UIImage *image = [UIImage imageWithData:data];
    if (image.size.width != kPetThumbNailWeigh && image.size.height != kPetThumbNailHeigh) {
        CGSize itemSize = CGSizeMake(kPetThumbNailWeigh, kPetThumbNailHeigh);
        UIGraphicsBeginImageContext(itemSize);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [image drawInRect:imageRect];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    [self.adoptAnimalRequestDelegate thumbNailBack:image indexPath:self.indexPath];
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *error = nil;
    if (error == nil) {
        if (self.adoptAnimalRequestType != RequestTypeCheckFavoriteAnimals) {
            [self.receivedDatas addObject:data];
        } else {
            for (NSMutableDictionary *connectionDic in self.connectionsArr) {
                NSURLConnection *connectionObj = [connectionDic objectForKey:@"connection"];
                if (connectionObj == connection) {
                    NSMutableArray *dataArr = [connectionDic objectForKey:@"data"];
                    [dataArr addObject:data];
                    break;
                }
            }
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.delegate) {
        switch (self.adoptAnimalRequestType) {
            case RequestTypeAdoptAnimals:
                if (self.statusCode == 200) {
                    if ([self.adoptAnimalRequestDelegate respondsToSelector:@selector(petResultBack:)]) {
                        [self parsePetResultData:[self appendDataFromDatas:self.receivedDatas] withConnection:connection];
                    }
                } else {
                    if ([self.adoptAnimalRequestDelegate respondsToSelector:@selector(faildResultWithHTMLContent:)]) {
                        NSData *data = [self appendDataFromDatas:self.receivedDatas];
                        NSString *htmlString = [NSString stringWithUTF8String:[data bytes]];
                        [self.adoptAnimalRequestDelegate faildResultWithHTMLContent:htmlString];
                    }
                }
                break;
            case RequestTypePetThumbNail:
                if ([self.adoptAnimalRequestDelegate respondsToSelector:@selector(thumbNailBack:indexPath:)]) {
                    [self parseThumbNailData:[self appendDataFromDatas:self.receivedDatas]];
                }
                break;
            case RequestTypeCheckFavoriteAnimals:
                for (NSMutableDictionary *connectionDic in self.connectionsArr) {
                    NSURLConnection *connectionObj = [connectionDic objectForKey:@"connection"];
                    if (connectionObj == connection) {
                        NSMutableArray *dataArr = [connectionDic objectForKey:@"data"];
                        [self combineFavoriteAnimals:[self appendDataFromDatas:dataArr] connection:connection];
                        break;
                    }
                }
                
            default:
                break;
        }
    } else {
        [Utilities stopLoading];
    }
    [super connectionDidFinishLoading:connection];
}
@end
