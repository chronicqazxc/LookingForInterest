//
//  AnimalDetailCollectionViewCell.m
//  LookingForInterest
//
//  Created by Wayne on 3/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AnimalDetailCollectionViewCell.h"
#import "GoTopButton.h"
#import "AnimalDetailTableViewCell.h"
#import "TableLoadPreviousPage.h"

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
#define kPetImageWidth CGRectGetWidth([[UIScreen mainScreen] bounds])
#define kPetImageHeigh 300
#define kDetailTableCellIdentifier @"AnimalDetailTableViewCell"

@interface AnimalDetailCollectionViewCell() <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *detailTableView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *view;
@end

@implementation AnimalDetailCollectionViewCell

- (void)awakeFromNib {
    [self.detailTableView registerNib:[UINib nibWithNibName:@"AnimalDetailTableViewCell" bundle:nil] forCellReuseIdentifier:kDetailTableCellIdentifier];
    self.detailTableView.dataSource = self;
    self.detailTableView.delegate = self;
    [self.detailTableView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
    [self.detailTableView reloadData];
    
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kPetImageWidth, kPetImageHeigh)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.imageView];
    }

    
    if (!self.pet.petBigPic) {
        self.imageView.image = [UIImage imageNamed:@"background_img.png"];
        
        if (self.pet && ![self.pet.imageName isEqualToString:@""]) {
            [self loadImage];
        }
    } else {
        self.imageView.image = self.pet.petBigPic;
    }
    

}

- (void)loadImage {
    dispatch_queue_t myQueue = dispatch_queue_create("Load image queue",NULL);
    dispatch_async(myQueue, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.pet.imageName]];
        self.image = [UIImage imageWithData:imageData];
        self.pet.petBigPic = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.alpha = 0.0;
            self.imageView.image = self.image;
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    if (offset.y <= 0) {
        [self scaleItem:self.imageView];
        if (offset.y <= -50) {
            [self.detailTableView setContentOffset:CGPointMake(0, -50)];
        }
    } else if (y > h) {
        self.imageView.frame = CGRectMake(0, (h-y)*1.0, kPetImageWidth, kPetImageHeigh);
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AnimalDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailTableCellIdentifier];
    if (!cell) {
        cell = (AnimalDetailTableViewCell *)[Utilities getNibWithName:@"AnimalDetailTableViewCell"];
    }
    cell.backgroundColor = [UIColor clearColor];
    [cell settingContentsByPet:self.pet];
    return cell;
}

- (void)scaleItem:(UIView *)item{
    CGFloat shiftInPercents = [self shiftInPercents];
    CGFloat buildigsScaleRatio = shiftInPercents;
    [item setTransform:CGAffineTransformMakeScale(buildigsScaleRatio,buildigsScaleRatio)];
}

-(CGFloat)shiftInPercents{
    return (-self.detailTableView.contentOffset.y/80)+1;
}
@end
