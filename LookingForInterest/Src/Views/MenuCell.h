//
//  MenuCell.h
//  LookingForInterest
//
//  Created by Wayne on 2/10/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
