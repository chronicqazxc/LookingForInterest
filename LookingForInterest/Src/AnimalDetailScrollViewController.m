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
#import "FacebookController.h"
#import <MessageUI/MessageUI.h>
#import "ManulAdoptDetailViewController.h"
#import <iAd/iAd.h>

@interface AnimalDetailScrollViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ADBannerViewDelegate, AnimalDetailCollectionViewCellDelegate, FacebookControllerDelegate, MFMailComposeViewControllerDelegate, ManulViewControllerDelegate>
@property (nonatomic) BOOL isInit;
@property (nonatomic) NSInteger currentRow;
@property (nonatomic) NSInteger previousRow;
@property (strong, nonatomic) AnimalDetailCollectionViewCell *animalDetailCollectionViewCell;
@property (strong, nonatomic) NSMutableArray *tempPets;
@property (strong, nonatomic) ManulAdoptDetailViewController *manulAdoptDetailViewController;
@property (nonatomic) BOOL hadShowManul;
@property (weak, nonatomic) IBOutlet ADBannerView *adBannerView;
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
    self.adBannerView.delegate = self;
    self.tempPets = [NSMutableArray arrayWithArray:self.petResult.pets];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self generateRightBarButtonByIndexPath:self.selectedIndexPath];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![Utilities getNeverShowManulMenuWithKey:kManulAdoptDetailKey]) {
        if (!self.hadShowManul) {
            self.manulAdoptDetailViewController = [[ManulAdoptDetailViewController alloc] initWithNibName:@"ManulViewController" bundle:nil];
            self.manulAdoptDetailViewController.delegate = self;
            [self presentViewController:self.manulAdoptDetailViewController animated:YES completion:nil];
        }
    }
}

- (void)viewDidLayoutSubviews {
    if (!self.isInit) {
        ((AnimalDetailScrollLayout *)self.collectionView.collectionViewLayout).itemSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        
        if (self.selectedIndexPath) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndexPath.row inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
        self.isInit = YES;
    }
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
    self.animalDetailCollectionViewCell.viewController = self;
    self.animalDetailCollectionViewCell.pet = [self.petResult.pets objectAtIndex:indexPath.row];
    self.animalDetailCollectionViewCell.petResult = self.petResult;
    [self.animalDetailCollectionViewCell awakeFromNib];
    return self.animalDetailCollectionViewCell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    self.navigationItem.title = [[self.petResult.pets objectAtIndex:indexPath.row] name];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cells = [collectionView visibleCells];
    AnimalDetailCollectionViewCell *visibleCell = (AnimalDetailCollectionViewCell *)cells.firstObject;
    if ([cells count]) {
        self.navigationItem.title = visibleCell.pet.name;
    }
    
    NSIndexPath *visibaleIndexPath = [self.collectionView indexPathForCell:visibleCell];
    [self generateRightBarButtonByIndexPath:visibaleIndexPath];
}

- (void)generateRightBarButtonByIndexPath:(NSIndexPath *)indexPath {
    Pet *pet = [self.petResult.pets objectAtIndex:indexPath.row];
    UIBarButtonItem *barButtonItem = nil;
    if ([Utilities isMyFavoriteAnimalByPet:pet]) {
        barButtonItem = [self generateRemoveFavoriteButtonWithTag:indexPath.row];
    } else {
        barButtonItem = [self generateAddFavoriteButtonWithTag:indexPath.row];
    }
    [self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
}

- (UIBarButtonItem *)generateAddFavoriteButtonWithTag:(NSInteger)tag {
    UIImage *image = [UIImage imageNamed:@"add_fav.png"];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(addMyFavoriteAnimal:)];
    barButtonItem.tintColor = [UIColor whiteColor];
    barButtonItem.tag = tag;
    return barButtonItem;
}

- (UIBarButtonItem *)generateRemoveFavoriteButtonWithTag:(NSInteger)tag {
    UIImage *image = [UIImage imageNamed:@"remove_fav.png"];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(removeMyFavoriteAnimal:)];
    barButtonItem.tintColor = [UIColor whiteColor];
    barButtonItem.tag = tag;
    return barButtonItem;
}

- (void)removeMyFavoriteAnimal:(UIBarButtonItem *)buttonItem {
    Pet *pet = [self.tempPets objectAtIndex:buttonItem.tag];
    [Utilities removeFromMyFavoriteAnimal:pet];
    [Utilities addHudViewTo:self withMessage:kRemoveFromFavorite];
    UIBarButtonItem *newButton = [self generateAddFavoriteButtonWithTag:buttonItem.tag];
    [self.navigationItem setRightBarButtonItem:newButton animated:YES];
    if ([self.petFilters.type isEqualToString:kAdoptFilterTypeMyFavorite]) {
        self.petResult.pets = [NSMutableArray arrayWithArray:[Utilities getMyFavoriteAnimalsDecoded]];
    }
}

- (void)addMyFavoriteAnimal:(UIBarButtonItem *)buttonItem {
    Pet *pet = [self.tempPets objectAtIndex:buttonItem.tag];
    [Utilities addToMyFavoriteAnimal:pet];
    [Utilities addHudViewTo:self withMessage:kAddToFavorite];
    UIBarButtonItem *newButton = [self generateRemoveFavoriteButtonWithTag:buttonItem.tag];
    [self.navigationItem setRightBarButtonItem:newButton animated:YES];
    if ([self.petFilters.type isEqualToString:kAdoptFilterTypeMyFavorite]) {
        self.petResult.pets = [NSMutableArray arrayWithArray:[Utilities getMyFavoriteAnimalsDecoded]];
    }
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

#pragma mark - AnimalDetailCollectionViewCellDelegate
- (void)callPhoneNumber:(Pet *)pet {
    NSString *message = pet.phone;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:pet.resettlement message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *callOutAction = [UIAlertAction actionWithTitle:@"撥打" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [Utilities callPhoneNumber:pet.phone];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:callOutAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)publishToFacebook:(Pet *)pet {
    FacebookController *fbController = [[FacebookController alloc] init];
    NSString *name = [NSString stringWithFormat:@"臺北市開放認養動物：%@",pet.name];
    NSString *caption = [NSString stringWithFormat:@"%@/%@/%@",pet.age,pet.sex,pet.resettlement];
    NSString *description = [NSString stringWithFormat:@"%@/%@",pet.phone,pet.email];
    fbController.delegate = self;
    [fbController shareWithLink:kAdoptAnimalsFacebookShareURL name:name caption:caption description:description picture:pet.imageName message:pet.note];
    
}

- (void)publishToLine:(Pet *)pet {
    UIAlertController *shareAlertController = [UIAlertController alertControllerWithTitle:@"分享至Line" message:@"選擇分享類別" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *shareImage = [UIAlertAction actionWithTitle:@"照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [Utilities startLoading];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:pet.imageName]];
        UIImage *image = [UIImage imageWithData:imageData];
        [Utilities stopLoading];
        [Utilities shareToLineWithImage:image];
    }];
    UIAlertAction *shareContent = [UIAlertAction actionWithTitle:@"介紹" style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
        [Utilities shareToLineWithContent:[self composeLineContent:pet] url:kAdoptAnimalsFacebookShareURL];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [shareAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [shareAlertController addAction:shareImage];
    [shareAlertController addAction:shareContent];
    [shareAlertController addAction:cancelAction];
    
    [self presentViewController:shareAlertController animated:YES completion:nil];
}

- (NSString *)composeLineContent:(Pet *)pet {
    NSString *content = [NSString stringWithFormat:@"照片:%@\n名字:%@(%@)\n年齡:%@\n位置:%@\nPhone:%@\nEmail:%@\n介紹:%@",pet.imageName,pet.name,pet.sex,pet.age,pet.resettlement,pet.phone,pet.email,pet.note];
    return content;
}

- (void)sendEmail:(Pet *)pet {
    [self showEmailWithTitle:@"" messageBody:@"" recipients: [NSArray arrayWithObject:pet.email]];
}

#pragma mark - FacebookControllerDelegate
- (void)showErrorMessage:(NSString *)errorMessage withTitle:(NSString *)errorTitle {
    [Utilities addHudViewTo:self withMessage:@"發布失敗"];
}

- (void)publishSuccess:(NSString *)postID {
    [Utilities addHudViewTo:self withMessage:@"發布成功"];
}

#pragma mark - MFMailComposeViewController
- (void)showEmailWithTitle:(NSString *)title messageBody:(NSString *)message recipients:(NSArray *)recipients {
    NSString *emailTitle = title;
    NSString *messageBody = message;
    NSArray *toRecipents = recipients;
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    [self presentViewController:mc animated:YES completion:NULL];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *message = @"";
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            message = @"取消寄信";
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            message = @"已儲存";
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            message = @"已寄出";
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            message = @"寄出失敗";
            break;
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:^{
        [Utilities addHudViewTo:self withMessage:message];
    }];
    
}

#pragma mark - ManulViewControllerDelegate
- (void)manulConfirmClicked {
    [self.manulAdoptDetailViewController dismissViewControllerAnimated:YES completion:nil];
    self.hadShowManul = YES;
    if (self.manulAdoptDetailViewController.neverShowSwitch.on) {
        [Utilities setNeverShowManulMenuWithKey:kManulAdoptDetailKey];
    }
}

- (BOOL)allowActionToRun {
    return YES;
}

#pragma mark - ADBannerViewDelegate
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    NSLog(@"Banner view is beginning an ad action");
    BOOL shouldExecuteAction = [self allowActionToRun];
    if (!willLeave && shouldExecuteAction) {
        // insert code here to suspend any services that might conflict with the advertisement
    }
    return shouldExecuteAction;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [self layoutAnimated:YES];
}

- (void)layoutAnimated:(BOOL)animated {
    CGRect contentFrame = self.view.bounds;
    CGRect bannerFrame = self.adBannerView.frame;
    if (self.adBannerView.bannerLoaded) {
        contentFrame.size.height -= self.adBannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        self.adBannerView.frame = contentFrame;
        [self.adBannerView layoutIfNeeded];
        self.adBannerView.frame = bannerFrame;
    }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self layoutAnimated:YES];
}
@end
