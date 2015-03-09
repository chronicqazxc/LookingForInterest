//
//  AnimalDetailCollectionViewCell.h
//  LookingForInterest
//
//  Created by Wayne on 3/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AnimalDetailCollectionViewCellDelegate;

@interface AnimalDetailCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) Pet *pet;
@property (strong, nonatomic) UIViewController <AnimalDetailCollectionViewCellDelegate> *viewController;
@end

@protocol AnimalDetailCollectionViewCellDelegate

- (void)callPhoneNumber:(NSString *)phoneNumber;
- (void)publishToFacebook:(Pet *)pet;
- (void)publishToLine:(Pet *)pet;
- (void)sendEmail:(NSString *)emailAddress;

@end