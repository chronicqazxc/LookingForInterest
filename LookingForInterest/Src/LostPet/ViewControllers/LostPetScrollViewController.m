//
//  LostPetScrollViewController.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/20/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetScrollViewController.h"
#import "LostPetCollectionViewCell.h"
#import "LostPetCollectionViewFlowLayout.h"
#import "GoTopButton.h"
#import "LostPet.h"
#import <iAd/iAd.h>

@interface LostPetScrollViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, ADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet GoTopButton *pageIndicator;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) BOOL isInit;
@property (strong, nonatomic) LostPetCollectionViewCell *lostPetCollectionViewCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapPictureSwitch;
- (IBAction)switchMapPicture:(UISegmentedControl *)sender;
@end

@implementation LostPetScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"LostPetCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kLostPetCollectionViewCellIdentifier];
    [self.collectionView reloadData];
    self.isInit = NO;
    
    self.navigationItem.title = @"走失寵物";
}

- (void)viewDidLayoutSubviews {
    if (!self.isInit) {
        if (self.selectedIndexPath) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndexPath.row inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
        self.isInit = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSString *)pageIndicatorTitleByIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [NSString stringWithFormat:@"%d/%d",(int)indexPath.row+1, (int)[self.lostPets count]];
    return title;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.lostPets count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.pageIndicator setTitle:[self pageIndicatorTitleByIndexPath:indexPath] forState:UIControlStateNormal];
    self.lostPetCollectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:kLostPetCollectionViewCellIdentifier forIndexPath:indexPath];
    self.lostPetCollectionViewCell.showType = self.mapPictureSwitch.selectedSegmentIndex;
    self.lostPetCollectionViewCell.lostPet = [self.lostPets objectAtIndex:indexPath.row];
    [self.lostPetCollectionViewCell awakeFromNib];
    return self.lostPetCollectionViewCell;
    
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.pageIndicator setTitle:[self pageIndicatorTitleByIndexPath:indexPath] forState:UIControlStateNormal];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cells = [collectionView visibleCells];
    LostPetCollectionViewCell *visibleCell = (LostPetCollectionViewCell *)cells.firstObject;
    if ([cells count]) {
        
    }
    
    NSIndexPath *visibaleIndexPath = [self.collectionView indexPathForCell:visibleCell];
    [self.pageIndicator setTitle:[self pageIndicatorTitleByIndexPath:visibaleIndexPath] forState:UIControlStateNormal];
    
    self.lostPetCollectionViewCell = (LostPetCollectionViewCell *)[collectionView cellForItemAtIndexPath:visibaleIndexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(collectionView.frame), CGRectGetHeight(collectionView.frame));
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [UIView animateWithDuration:1.0 animations:^{
        self.pageIndicator.alpha = 1.0;
    } completion:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hiddenPageIndicator:) userInfo:nil repeats:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hiddenPageIndicator:) userInfo:nil repeats:NO];
}

- (void)hiddenPageIndicator:(NSTimer *)timer {
    [UIView animateWithDuration:1.0 animations:^{
        self.pageIndicator.alpha = 0.0;
    } completion:nil];
    [timer invalidate];
}
- (IBAction)switchMapPicture:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == LostPetScrollViewShowMap) {
        [self.lostPetCollectionViewCell showMapOrPictureByValue:LostPetScrollViewShowMap];
    } else {
        [self.lostPetCollectionViewCell showMapOrPictureByValue:LostPetScrollViewShowPicture];
    }
}
@end
