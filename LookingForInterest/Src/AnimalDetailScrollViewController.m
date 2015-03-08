//
//  AnimalDetailScrollViewController.m
//  LookingForInterest
//
//  Created by Wayne on 3/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AnimalDetailScrollViewController.h"
#import "AnimalDetailCollectionViewCell.h"
#import "AnimalDetailScrollLayout.h"

@interface AnimalDetailScrollViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic) BOOL isInit;
@property (nonatomic) NSInteger currentRow;
@property (nonatomic) NSInteger previousRow;
@property (strong, nonatomic) AnimalDetailCollectionViewCell *animalDetailCollectionViewCell;
@end

@implementation AnimalDetailScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.pagingEnabled = YES;
    self.currentRow = 0;
    self.previousRow = 0;
    self.isInit = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    if (!self.isInit) {
        ((AnimalDetailScrollLayout *)self.collectionView.collectionViewLayout).itemSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        
        if (self.selectedIndexPath) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndexPath.row inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
        self.isInit = YES;
    }
//    self.animalDetailCollectionViewCell.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), 1000);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = [self.petResult.pets count];
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UINib *nib = [UINib nibWithNibName:@"AnimalDetailCollectionViewCell" bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:@"AnimalDetailCell"];
    self.animalDetailCollectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AnimalDetailCell" forIndexPath:indexPath];
    if (!self.animalDetailCollectionViewCell) {
        self.animalDetailCollectionViewCell = (AnimalDetailCollectionViewCell *)[Utilities getNibWithName:@"AnimalDetailCollectionViewCell"];
    }
    self.animalDetailCollectionViewCell.pet = [self.petResult.pets objectAtIndex:indexPath.row];
    self.animalDetailCollectionViewCell.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), 1000);
    [self.animalDetailCollectionViewCell awakeFromNib];
    return self.animalDetailCollectionViewCell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    self.navigationItem.title = [[self.petResult.pets objectAtIndex:indexPath.row] name];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cells = [collectionView visibleCells];
    self.navigationItem.title = ((AnimalDetailCollectionViewCell *)cells.firstObject).pet.name;
}

#pragma mark - UICollectionViewDelegateFlowLayout
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
@end
