//
//  LostPetCollectionViewFlowLayout.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/20/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetCollectionViewFlowLayout.h"

@implementation LostPetCollectionViewFlowLayout
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}
@end
