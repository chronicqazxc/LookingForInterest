//
//  AnimalDetailCollectionViewCell.m
//  LookingForInterest
//
//  Created by Wayne on 3/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AnimalDetailCollectionViewCell.h"

#define kVarietyTitle @"品種"
#define kSexTitle @"性別"
#define kIsSterilizationTitle @"是否絕育"
#define kHairTypeTitle @"花色"
#define kAgeTitle @"年齡"
#define kNoteTitle @"介紹"
#define kResettlementTitle @"位置"
#define kPhoneTitle @"聯絡電話"
#define kEmailTitle @"聯絡e-mail"
#define kChildreAnlongTitle @"可否與其他孩童相處"
#define kAnimalAnlongTitle @"可否與其他動物相處"
#define kReasonTitle @"來的原因"
#define kBodyweightTitle @"體重"
#define kPetImageWeigh 300
#define kPetImageHeigh 400

@interface AnimalDetailCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *variety;
@property (weak, nonatomic) IBOutlet UILabel *sex;
@property (weak, nonatomic) IBOutlet UILabel *isSterilization;
@property (weak, nonatomic) IBOutlet UILabel *hairType;
@property (weak, nonatomic) IBOutlet UILabel *age;
@property (weak, nonatomic) IBOutlet UITextView *note;
@property (weak, nonatomic) IBOutlet UILabel *resettlement;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UILabel *childreAnlong;
@property (weak, nonatomic) IBOutlet UILabel *animalAnlong;
@property (weak, nonatomic) IBOutlet UILabel *reason;
@property (weak, nonatomic) IBOutlet UILabel *bodyweight;
@property (strong, nonatomic) UIImage *image;
@end

@implementation AnimalDetailCollectionViewCell

- (void)awakeFromNib {
    self.imageView.frame = CGRectMake(0,0,CGRectGetWidth(self.frame),400);
    [self loadImage];
    [self setLabel:self.variety title:kVarietyTitle andContent:self.pet.variety];
    [self setLabel:self.sex title:kSexTitle andContent:self.pet.sex];
    [self setLabel:self.isSterilization title:kIsSterilizationTitle andContent:self.pet.isSterilization];
    [self setLabel:self.hairType title:kHairTypeTitle andContent:self.pet.hairType];
    [self setLabel:self.age title:kAgeTitle andContent:self.pet.age];
    [self setTextView:self.note title:kNoteTitle andContent:self.pet.note];
    [self setLabel:self.resettlement title:kResettlementTitle andContent:self.pet.resettlement];
    [self setLabel:self.phone title:kPhoneTitle andContent:self.pet.phone];
    [self setLabel:self.email title:kEmailTitle andContent:self.pet.email];
    [self setLabel:self.childreAnlong title:kChildreAnlongTitle andContent:self.pet.childreAnlong];
    [self setLabel:self.animalAnlong title:kAnimalAnlongTitle andContent:self.pet.animalAnlong];
    [self setLabel:self.reason title:kReasonTitle andContent:self.pet.reason];
    [self setLabel:self.bodyweight title:kBodyweightTitle andContent:self.pet.bodyweight];
}

- (void)loadImage {
    dispatch_queue_t myQueue = dispatch_queue_create("Load image queue",NULL);
    dispatch_async(myQueue, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.pet.imageName]];
        self.image = [UIImage imageWithData:imageData];

        if (self.image.size.width != kPetImageWeigh && self.image.size.height != kPetImageHeigh) {
            CGSize itemSize = CGSizeMake(kPetImageWeigh, kPetImageHeigh);
            UIGraphicsBeginImageContext(itemSize);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [self.image drawInRect:imageRect];
            self.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = self.image;
        });
    });
}

- (void)setLabel:(UILabel *)label title:(NSString *)title andContent:(NSString *)content {
    label.text = [NSString stringWithFormat:@"%@：%@", title, content?content:@""];
}

- (void)setTextView:(UITextView *)textView title:(NSString *)title andContent:(NSString *)content {
    textView.text = [NSString stringWithFormat:@"%@：%@", title, content];
}

@end
