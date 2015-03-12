//
//  AnimalDetailCollectionViewCell.m
//  LookingForInterest
//
//  Created by Wayne on 3/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AnimalDetailCollectionViewCell.h"
#import "GoTopButton.h"

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
#define kPetImageWeigh CGRectGetWidth(self.frame)
#define kPetImageHeigh 400

@interface AnimalDetailCollectionViewCell() <UIScrollViewDelegate>
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
@property (weak, nonatomic) IBOutlet GoTopButton *pageIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageVerticalConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttomVerticalConstraints;
- (IBAction)facebookShare:(UIBarButtonItem *)sender;
- (IBAction)lineShare:(UIBarButtonItem *)sender;
- (IBAction)callOut:(UIBarButtonItem *)sender;
- (IBAction)sendEmail:(UIBarButtonItem *)sender;
@end

@implementation AnimalDetailCollectionViewCell

- (void)awakeFromNib {
    self.imageHeightConstraints.constant = CGRectGetHeight(self.frame)-44;
    /*
320 x 568	375 x 667	414 x 736	1024x768	1024x768
     */
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (screenRect.size.height < 568) {
        self.imageVerticalConstraints.constant = 50.0;
        self.buttomVerticalConstraints.constant = 50.0;
    } else if (screenRect.size.height >= 568 && screenRect.size.height < 667) {
        self.imageVerticalConstraints.constant = 50.0;
        self.buttomVerticalConstraints.constant = 60.0;
    } else if (screenRect.size.height >= 667 && screenRect.size.height < 768) {
        self.imageVerticalConstraints.constant = 50.0;
        self.buttomVerticalConstraints.constant = 100.0;
    } else if (screenRect.size.height > 768) {
        self.imageVerticalConstraints.constant = 90.0;
        self.buttomVerticalConstraints.constant = 200.0;
    }
    [self updateConstraints];
    self.imageView.image = [UIImage imageNamed:@"Loading300x400.png"];
    [self loadImage];
    [self setLabel:self.variety title:@"" andContent:self.pet.variety];
    [self setLabel:self.sex title:@"" andContent:self.pet.sex];
    [self setLabel:self.isSterilization title:@"" andContent:self.pet.isSterilization];
    [self setLabel:self.hairType title:@"" andContent:self.pet.hairType];
    [self setLabel:self.age title:@"" andContent:self.pet.age];
    [self setTextView:self.note title:kNoteTitle andContent:self.pet.note];
    [self setLabel:self.resettlement title:@"" andContent:self.pet.resettlement];
    [self setLabel:self.phone title:@"" andContent:self.pet.phone];
    [self setLabel:self.email title:@"" andContent:self.pet.email];
    [self setLabel:self.childreAnlong title:@"" andContent:self.pet.childreAnlong];
    [self setLabel:self.animalAnlong title:@"" andContent:self.pet.animalAnlong];
    [self setLabel:self.reason title:@"" andContent:self.pet.reason];
    [self setLabel:self.bodyweight title:@"" andContent:self.pet.bodyweight];
    
    [self setPageIndicatorTitleByResult:self.petResult];
    self.pageIndicator.alpha = 0.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.pageIndicator.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hidePageIndicator:) userInfo:nil repeats:NO];
        }
    }];
    [self.scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 10.0;
    self.note.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.note.layer.borderWidth = 1.0;
    self.note.layer.cornerRadius = 5.0;
}

- (void)setPageIndicatorTitleByResult:(PetResult *)petResult {
    NSString *totalPage = @"";
    NSString *currentPage = @"";
    totalPage = [NSString stringWithFormat:@"%d",(int)[petResult.pets count]];
    NSInteger index = 0;
    for (Pet *pet in petResult.pets) {
        if ([self.pet.petID isEqualToNumber:pet.petID]) {
            break;
        }
        index++;
    }
    currentPage = [NSString stringWithFormat:@"%d",(int)++index];
    [self.pageIndicator setTitle:[NSString stringWithFormat:@"%@/%@",currentPage,totalPage] forState:UIControlStateNormal];
}

- (void)hidePageIndicator:(NSTimer *)timer {
    [UIView animateWithDuration:0.5 animations:^{
        self.pageIndicator.alpha = 0.0;
    }];
    [timer invalidate];
}

- (void)loadImage {
    dispatch_queue_t myQueue = dispatch_queue_create("Load image queue",NULL);
    dispatch_async(myQueue, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.pet.imageName]];
        self.image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.alpha = 0.0;
            self.imageView.image = self.image;
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.imageView.autoresizingMask =
            ( UIViewAutoresizingFlexibleBottomMargin
             | UIViewAutoresizingFlexibleHeight
             | UIViewAutoresizingFlexibleLeftMargin
             | UIViewAutoresizingFlexibleRightMargin
             | UIViewAutoresizingFlexibleTopMargin
             | UIViewAutoresizingFlexibleWidth );
            [UIView animateWithDuration:1.0f animations:^{
                self.imageView.alpha = 1.0;
            } completion:^(BOOL finished) {

            }];
        });
    });
}

- (void)setLabel:(UILabel *)label title:(NSString *)title andContent:(NSString *)content {
    label.text = [NSString stringWithFormat:@"%@%@", title, content?content:@""];
}

- (void)setTextView:(UITextView *)textView title:(NSString *)title andContent:(NSString *)content {
    textView.text = [NSString stringWithFormat:@"%@：%@", title, content];
}

- (IBAction)facebookShare:(UIBarButtonItem *)sender {
    if (self.viewController && [self.viewController respondsToSelector:@selector(publishToFacebook:)]) {
        [self.viewController publishToFacebook:self.pet];
    }
}

- (IBAction)lineShare:(UIBarButtonItem *)sender {
    if (self.viewController && [self.viewController respondsToSelector:@selector(publishToLine:)]) {
        [self.viewController publishToLine:self.pet];
    }
}

- (IBAction)callOut:(UIBarButtonItem *)sender {
    if (self.viewController && [self.viewController respondsToSelector:@selector(callPhoneNumber:)]) {
        [self.viewController callPhoneNumber:self.pet];
    }
}

- (IBAction)sendEmail:(UIBarButtonItem *)sender {
    if (self.viewController && [self.viewController respondsToSelector:@selector(sendEmail:)]) {
        [self.viewController sendEmail:self.pet];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}
@end
