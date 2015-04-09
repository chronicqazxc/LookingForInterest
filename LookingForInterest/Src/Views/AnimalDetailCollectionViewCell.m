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
@property (weak, nonatomic) IBOutlet GoTopButton *pageIndicator;
- (IBAction)facebookShare:(UIBarButtonItem *)sender;
- (IBAction)lineShare:(UIBarButtonItem *)sender;
- (IBAction)callOut:(UIBarButtonItem *)sender;
- (IBAction)sendEmail:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *facebookButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lineButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *callButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mailButton;
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
    self.imageView.image = [UIImage imageNamed:@"background_img.png"];
    
    if (self.pet && ![self.pet.imageName isEqualToString:@""]) {
        [self loadImage];
    }
    
    [self setPageIndicatorTitleByResult:self.petResult];
    self.pageIndicator.alpha = 0.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.pageIndicator.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hidePageIndicator:) userInfo:nil repeats:NO];
        }
    }];
    
    self.facebookButton.tintColor = UIColorFromRGB(0x3b5998);
    self.lineButton.tintColor = UIColorFromRGB(0x19BD03);
    self.callButton.tintColor = [UIColor blackColor];
    self.mailButton.tintColor = [UIColor redColor];
}

- (void)setPageIndicatorTitleByResult:(PetResult *)petResult {
    NSString *totalPage = @"";
    NSString *currentPage = @"";
    totalPage = [NSString stringWithFormat:@"%d",(int)[petResult.pets count]];
    NSInteger index = 0;
    for (Pet *pet in petResult.pets) {
        if ([self.pet.petID isEqualToString:pet.petID]) {
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
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
//    NSLog(@"offset.y:%.2f, y:%.2f, h:%.2f",offset.y,y,h);
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
