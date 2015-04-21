//
//  TableLoadPreviousPage.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/6/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableLoadPreviousPage : UIView
@property (nonatomic) BOOL canLoading;
@property (weak, nonatomic) IBOutlet UIImageView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *indicatorLabel;
@end
