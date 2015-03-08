//
//  AnimalDetailScrollViewController.h
//  LookingForInterest
//
//  Created by Wayne on 3/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnimalDetailScrollViewController : UIViewController
@property (strong, nonatomic) PetResult *petResult;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end
