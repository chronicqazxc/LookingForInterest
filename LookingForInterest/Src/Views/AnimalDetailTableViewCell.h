//
//  AnimalDetailTableViewCell.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnimalDetailTableViewCell : UITableViewCell
- (void)settingContentsByPet:(Pet *)pet;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@end
