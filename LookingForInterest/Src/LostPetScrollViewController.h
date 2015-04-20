//
//  LostPetScrollViewController.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/20/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface LostPetScrollViewController : UIViewController
@property (strong, nonatomic) NSMutableArray *lostPets;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end
