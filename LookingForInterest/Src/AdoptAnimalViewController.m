//
//  AdoptAnimalViewController.m
//  LookingForInterest
//
//  Created by Wayne on 3/5/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AdoptAnimalViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MGSwipeTableCell/MGSwipeButton.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import "RequestSender.h"
#import "AdoptAnimalFilterController.h"
#import "AnimalDetailScrollViewController.h"
#import "AnimalListTableViewCell.h"
#import "GoTopButton.h"

#define kAdoptAnimalTitle(type) [NSString stringWithFormat:@"觀看%@",type]
#define kNavigationColorDogFirst 0xb2b2ff
#define kNavigationColorDogSecond 0x0000ff
#define kNavigationColorCatFirst 0xffe4b2
#define kNavigationColorCatSecond 0xe57300
#define kNavigationColorOtherFirst 0x9eccb5
#define kNavigationColorOtherSecond 0x0e8146
#define kNavigationColorMyFavoriteFirst 0xffb2b2
#define kNavigationColorMyFavoriteSecond 0xff0000
#define kNavigationColorFilterFirst 0xcc99ff
#define kNavigationColorFilterSecond 0x690099

@interface AdoptAnimalViewController () <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, RequestSenderDelegate, AdoptAnimalFilterControllerDelegate, MGSwipeTableCellDelegate>
@property (strong, nonatomic) PetResult *petResult;
@property (strong, nonatomic) NSMutableArray *requests;
@property (strong, nonatomic) PetFilters *petFilters;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic) BOOL isSendInitRequest;
@property (strong, nonatomic) NSString *nextPage;
@property (strong, nonatomic) NSString *previousPage;
@property (nonatomic) BOOL isStartLoading;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *previousPageIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *nextPageIndicator;
@property (weak, nonatomic) IBOutlet GoTopButton *pageIndicator;
@property (weak, nonatomic) IBOutlet UIView *previousPageView;
@property (weak, nonatomic) IBOutlet UIView *nextPageView;
@property (strong, nonatomic) UIView *navigationBackgroundView;
@property (strong, nonatomic) CAGradientLayer *gradientLayer;
@property (strong, nonatomic) UIColor *currentFirstColor;
@property (strong, nonatomic) UIColor *currentSecondColor;
@end

@implementation AdoptAnimalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;   
    self.isSendInitRequest = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tabBar.delegate = self;
    self.checkButton.enabled = NO;
    self.previousPageView.hidden = YES;
    self.nextPageView.hidden = YES;
    self.petFilters = [[PetFilters alloc] init];
//    [self composeFilters];
    [self initProperties];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initProperties {
    self.requests = [NSMutableArray array];
    self.appDelegate = [Utilities getAppDelegate];
    self.isStartLoading = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self changeNavTitle];
    
    if (!self.currentFirstColor && !self.currentSecondColor) {
        [self setNavTitleAndTabBarColor:UIColorFromRGB(kNavigationColorFilterFirst) secondColor:UIColorFromRGB(kNavigationColorFilterSecond)];
    } else {
        [self setNavTitleAndTabBarColor:self.currentFirstColor secondColor:self.currentSecondColor];
    }
    
    [self.tableView reloadData];
}

- (void)changeNavTitle {
    if ([self.petFilters.type isEqualToString:kAdoptFilterAll] || !self.petFilters.type || [self.petFilters.type isEqualToString:@""]) {
        self.navigationItem.title = kAdoptAnimalTitle(@"全部");
    } else if ([self.petFilters.type isEqualToString:kAdoptFilterTypeDog]) {
//        self.navigationItem.title = AdoptAnimalTitle(kAdoptFilterTypeDog);
        self.navigationController.navigationBar.topItem.title = kAdoptAnimalTitle(kAdoptFilterTypeDog);
    } else if ([self.petFilters.type isEqualToString:kAdoptFilterTypeCat]) {
        //        self.navigationItem.title = AdoptAnimalTitle(kAdoptFilterTypeCat);
        self.navigationController.navigationBar.topItem.title = kAdoptAnimalTitle(kAdoptFilterTypeCat);
    } else if ([self.petFilters.type isEqualToString:kAdoptFilterTypeOther]) {
        //        self.navigationItem.title = AdoptAnimalTitle(kAdoptFilterTypeOther);
        self.navigationController.navigationBar.topItem.title = kAdoptAnimalTitle(kAdoptFilterTypeOther);
    } else if ([self.petFilters.type isEqualToString:kAdoptFilterTypeMyFavorite]) {
        //        self.navigationItem.title = AdoptAnimalTitle(kAdoptFilterTypeMyFavorite);
        self.navigationController.navigationBar.topItem.title = kAdoptAnimalTitle(kAdoptFilterTypeMyFavorite);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isSendInitRequest && ![self.petResult.pets count]) {
        [self startLoadingWithContent:nil];
        [self sendInitRequest];
        self.isSendInitRequest = YES;
    }
}

- (void)composeFilters {
    self.petFilters.age = nil;
    self.petFilters.type = nil;
    self.petFilters.sex = nil;
    self.petFilters.build = nil;
}

- (void)startLoadingWithContent:(NSString *)content {
    self.appDelegate.viewController = self;
    if (content) {
        [Utilities startLoadingWithContent:content];
    } else {
        [Utilities startLoading];
    }
}

- (void)sendInitRequest {
    RequestSender *requestSender = [[RequestSender alloc] init];
    requestSender.delegate = self;
    [requestSender sendRequestForAdoptAnimalsWithPetFilters:self.petFilters];
}

- (void)getNextPage {
    [self.nextPageIndicator startAnimating];
    [self clearRequestSenderDelegate];
    [self startLoadingWithContent:@"下一頁"];
    self.petFilters.offset = self.nextPage;
    self.petResult.filters = self.petFilters;
    [self sendRequestWithFilters:self.petFilters];
}

- (void)getPreviousPage {
    [self.previousPageIndicator startAnimating];
    [self clearRequestSenderDelegate];
    [self startLoadingWithContent:@"上一頁"];
//    PetFilters *petFilters = [[PetFilters alloc] init];
//    petFilters.offset = self.previousPage;
    self.petFilters.offset = self.previousPage;
    self.petResult.filters = self.petFilters;    
    [self sendRequestWithFilters:self.petFilters];
}

- (void)sendRequestWithFilters:(PetFilters *)petFilters {
    RequestSender *requestSender = [[RequestSender alloc] init];
    requestSender.delegate = self;
    [requestSender sendRequestForAdoptAnimalsWithPetFilters:petFilters];
    [self.requests addObject:requestSender];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearRequestSenderDelegate];
    [self initProperties];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self clearRequestSenderDelegate];
    [self initProperties];
}

- (void)clearRequestSenderDelegate {
    for (RequestSender *requestSender in self.requests) {
        requestSender.delegate = nil;
    }
    self.requests = [NSMutableArray array];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 103.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    NSInteger petsCount = [self.petResult.pets count];
    if (petsCount) {
        numberOfRows = petsCount;
    } else {
        numberOfRows = 1;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UINib *petCellNib = [UINib nibWithNibName:@"AnimalListTableViewCell" bundle:nil];
    [tableView registerNib:petCellNib forCellReuseIdentifier:kPetListCellIdentifier];
    AnimalListTableViewCell *petCell = [tableView dequeueReusableCellWithIdentifier:kPetListCellIdentifier];
    if (!petCell) {
        petCell = (AnimalListTableViewCell *)[Utilities getNibWithName:kPetListCellIdentifier];
    }

    if ([self.petResult.pets count]) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        Pet *pet = [self.petResult.pets objectAtIndex:indexPath.row];
        petCell.name.text = [NSString stringWithFormat:@"%@",pet.name];
        petCell.variety.text = [NSString stringWithFormat:@"品種：%@（%@）",pet.variety ,pet.type];
        petCell.age.text = [NSString stringWithFormat:@"年齡：%@",pet.age];
        petCell.gender.text = [NSString stringWithFormat:@"性別：%@",pet.sex];
        petCell.body.text = [NSString stringWithFormat:@"體型：%@",pet.build];
        
        if (!pet.thumbNail && !self.isStartLoading) {
            petCell.thumbNail.image = [UIImage imageNamed:@"Loading100x100.png"];
            [self startThumbNailDownload:pet forIndexPath:indexPath];
            petCell.thumbNail.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.3].CGColor;
        } else {
            petCell.thumbNail.image = pet.thumbNail;
            petCell.thumbNail.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        }
        
        petCell.delegate = self;
    } else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        cell.textLabel.text = @"查無資料...";
        return cell;
    }
    return petCell;
}

- (BOOL)isMyFavoriteAnimalByIndex:(NSInteger)index {
    NSArray *animals = [Utilities getMyFavoriteAnimalsDecoded];
    Pet *selectedAnimal = [self.petResult.pets objectAtIndex:index];
    BOOL isMyFavorite = NO;
    for (Pet *pet in animals) {
        if ([pet.petID isEqualToNumber:selectedAnimal.petID]) {
            isMyFavorite = YES;
            break;
        }
    }
    return isMyFavorite;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (![self.petResult.pets count]) return;
    AnimalDetailScrollViewController *animalDetailScrollViewController = [[AnimalDetailScrollViewController alloc] initWithNibName:@"AnimalDetailScrollViewController" bundle:nil];
    animalDetailScrollViewController.petResult = self.petResult;
    animalDetailScrollViewController.selectedIndexPath = indexPath;
    animalDetailScrollViewController.petFilters = self.petFilters;
    [self.navigationController pushViewController:animalDetailScrollViewController animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    [UIView animateWithDuration:1.0 animations:^{
        self.pageIndicator.alpha = 1.0;
    } completion:nil];
    
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reloadDistance = 50;
    
    if (self.isStartLoading == NO) {
        if (offset.y <= -50) {
            if ((self.petResult.previous && ![self.petResult.previous isEqualToString:@""]) ||
                [self.petResult.next isEqualToString:@"40"]) {
                self.isStartLoading = YES;
                [self getPreviousPage];
            }
        } else if (y > h + reloadDistance) {
            if (self.petResult.next && ![self.petResult.next isEqualToString:@""] && [self.petResult.next intValue] < [self.petResult.total intValue]) {
                self.isStartLoading = YES;
                [self getNextPage];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate && !self.isStartLoading) {
        [self loadThumbNailForOnScreenRows];
    }
    if (!decelerate) {
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hiddenPageIndicator:) userInfo:nil repeats:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
   [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hiddenPageIndicator:) userInfo:nil repeats:NO];
    if (!self.isStartLoading) {
        [self loadThumbNailForOnScreenRows];
    }
}

- (void)hiddenPageIndicator:(NSTimer *)timer {
    [UIView animateWithDuration:1.0 animations:^{
        self.pageIndicator.alpha = 0.0;
    } completion:nil];
    [timer invalidate];
}

- (void)loadThumbNailForOnScreenRows {
    if([self.petResult.pets count] >0){
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for(NSIndexPath *indexPath in visiblePaths){
            Pet *pet = [self.petResult.pets objectAtIndex:indexPath.row];
            if (!pet.thumbNail)
                [self startThumbNailDownload:pet forIndexPath:indexPath];
        }
    }
}

#pragma mark - lazy loading
- (void)startThumbNailDownload:(Pet *)pet forIndexPath:(NSIndexPath *)indexPath {
    RequestSender *request = [[RequestSender alloc] init];
    request.delegate = self;
    [request sendRequestForPetThumbNail:pet indexPath:indexPath];
    [self.requests addObject:request];
}

#pragma mark - RequestSenderDelegate
- (void)requestFaildWithMessage:(NSString *)message connection:(NSURLConnection *)connection{
    self.appDelegate.viewController = self;
    [Utilities stopLoading];
    [self.nextPageIndicator stopAnimating];
    [self.previousPageIndicator stopAnimating];
    self.isStartLoading = NO;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"錯誤" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *reConnectAction = [UIAlertAction actionWithTitle:@"重新連線" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        RequestSender *requestSender = [[RequestSender alloc] init];
        requestSender.delegate = self;
        [requestSender reconnect:connection];
        [self.requests addObject:requestSender];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:reConnectAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)petResultBack:(PetResult *)petResult {
    [self.nextPageIndicator stopAnimating];
    [self setPageIndicatorTitleByResult:petResult];
    
    [self.previousPageIndicator stopAnimating];
    self.isStartLoading = NO;
    self.petResult = petResult;
    self.nextPage = petResult.next;
    self.previousPage = petResult.previous;
    
    [self.tableView reloadData];
    
    if ([self.petResult.pets count]) {
        [self scrollToTop];
    }
    
    self.appDelegate.viewController = self;
    [Utilities stopLoading];

}

- (void)scrollToTop {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)setPageIndicatorTitleByResult:(PetResult *)petResult {
    NSString *totalPage = @"";
    if ([petResult.total intValue]%[petResult.limit integerValue]) {
        NSInteger total = [petResult.total intValue]/[petResult.limit integerValue]+1;
        totalPage = [NSString stringWithFormat:@"%d",(int)total];
    } else {
        NSInteger total = [petResult.total intValue]/[petResult.limit integerValue];
        if (total == 0) {
            totalPage = @"1";
        } else {
            totalPage = [NSString stringWithFormat:@"%d",(int)total];
        }
    }
    NSString *currentPage = @"";
    NSString *offset = [NSString stringWithFormat:@"%@",petResult.offset];
    if ([offset isEqualToString:@""]) {
        currentPage = @"1";
    } else {
        currentPage = [NSString stringWithFormat:@"%d",[offset intValue]/20+1];
    }

    [self.pageIndicator setTitle:[NSString stringWithFormat:@"%@/%@頁",currentPage,totalPage] forState:UIControlStateNormal];
    
    if ([currentPage isEqualToString:@"1"] && [currentPage isEqualToString:totalPage]) {
        self.previousPageView.hidden = YES;
        self.nextPageView.hidden = YES;
    } else if ([currentPage isEqualToString:@"1"] && ![currentPage isEqualToString:totalPage]) {
        self.previousPageView.hidden = YES;
        self.nextPageView.hidden = NO;
    } else if (![currentPage isEqualToString:@"1"] && [currentPage isEqualToString:totalPage]) {
        self.previousPageView.hidden = NO;
        self.nextPageView.hidden = YES;
    } else {
        self.previousPageView.hidden = NO;
        self.nextPageView.hidden = NO;
    }
}

- (void)thumbNailBack:(UIImage *)image indexPath:(NSIndexPath *)indexPath {
    if (self.petResult && [self.petResult.pets count]) {
        Pet *pet = [self.petResult.pets objectAtIndex:indexPath.row];
        if (!pet.thumbNail) {
            pet.thumbNail = image;
            AnimalListTableViewCell *cell = (AnimalListTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.thumbNail.image = image;
            cell.thumbNail.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
            cell.thumbNail.alpha = 0.0;
            [UIView animateWithDuration:1.0f animations:^{
                cell.thumbNail.alpha = 1.0;
            } completion:^(BOOL finished) {
                nil;
            }];
        }
    }
}

- (void)checkFavoriteAnimalsResultBack:(NSMutableArray *)results {
    for (Pet *favoritePet in [Utilities getMyFavoriteAnimalsDecoded]) {
        BOOL isFound = NO;
        for (Pet *resultPet in results) {
            if ([favoritePet.petID isEqualToNumber:resultPet.petID]) {
                isFound = YES;
            }
        }
        if (!isFound) {
            [Utilities removeFromMyFavoriteAnimal:favoritePet];
        }
    }
    self.appDelegate.viewController = self;
    [Utilities stopLoading];
}

#pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch (item.tag) {
        case 0:
            [self sendDogRequest];
            
            [self changeNavTitle];
            self.checkButton.enabled = NO;
            break;
        case 1:
            [self sendCatRequest];
            [self changeNavTitle];
            self.checkButton.enabled = NO;
            break;
        case 2:
            [self sendOtherRequest];
            [self changeNavTitle];
            self.checkButton.enabled = NO;
            break;
        case 3:
            [self sendMyFavoriteRequest];
            [self changeNavTitle];
            if ([self.petResult.pets count]) {
                self.checkButton.enabled = YES;
            } else {
                self.checkButton.enabled = NO;
            }
            break;
        case 4:
            [self showFilter];
            self.checkButton.enabled = NO;
            break;
        default:
            break;
    }
}

- (void)setNavTitleAndTabBarColor:(UIColor *)firstColor secondColor:(UIColor *)secondColor{
    self.tabBar.tintColor = secondColor;
    self.currentFirstColor = firstColor;
    self.currentSecondColor = secondColor;
    
    NSArray *colors = [NSArray arrayWithObjects:(id)firstColor.CGColor, (id)secondColor.CGColor, nil];
    
    if (self.gradientLayer == nil && self.navigationBackgroundView == nil) {
        
        self.navigationController.navigationBar.translucent = NO;
        
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.opacity = self.navigationController.navigationBar.translucent ? 0.5 : 1.0;
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        self.gradientLayer.frame = CGRectMake(0, 0 - statusBarHeight, CGRectGetWidth(self.navigationController.navigationBar.bounds), CGRectGetHeight(self.navigationController.navigationBar.bounds) + statusBarHeight*2);
        
        self.gradientLayer.colors = colors;
        
        self.navigationBackgroundView = [[UIView alloc] initWithFrame:self.gradientLayer.frame];
        [self.navigationBackgroundView.layer addSublayer:self.gradientLayer];
        
        UIImage *img = [Utilities imageWithView:self.navigationBackgroundView];
        [self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
        
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    } else {
        self.gradientLayer.colors = colors;
        UIImage *img = [Utilities imageWithView:self.navigationBackgroundView];
        [self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)sendDogRequest {
    [self setNavTitleAndTabBarColor:UIColorFromRGB(kNavigationColorDogFirst) secondColor:UIColorFromRGB(kNavigationColorDogSecond)];

    [self clearRequestSenderDelegate];
    [self startLoadingWithContent:@"讀取汪星人"];
    self.petFilters = [[PetFilters alloc] init];
    self.petFilters.type = kAdoptFilterTypeDog;
    self.petFilters.offset = nil;
    [self sendRequestWithFilters:self.petFilters];
}

- (void)sendCatRequest {
    [self setNavTitleAndTabBarColor:UIColorFromRGB(kNavigationColorCatFirst) secondColor:UIColorFromRGB(kNavigationColorCatSecond)];

    [self clearRequestSenderDelegate];
    [self startLoadingWithContent:@"讀取喵星人"];
    self.petFilters = [[PetFilters alloc] init];
    self.petFilters.type = kAdoptFilterTypeCat;
    self.petFilters.offset = nil;
    [self sendRequestWithFilters:self.petFilters];
}

- (void)sendOtherRequest {
    [self setNavTitleAndTabBarColor:UIColorFromRGB(kNavigationColorOtherFirst) secondColor:UIColorFromRGB(kNavigationColorOtherSecond)];

    [self clearRequestSenderDelegate];
    [self startLoadingWithContent:@"讀取其他動物"];
    self.petFilters = [[PetFilters alloc] init];
    self.petFilters.type = kAdoptFilterTypeOther;
    self.petFilters.offset = nil;
    [self sendRequestWithFilters:self.petFilters];
}

- (void)sendMyFavoriteRequest {
    [self setNavTitleAndTabBarColor:UIColorFromRGB(kNavigationColorMyFavoriteFirst) secondColor:UIColorFromRGB(kNavigationColorMyFavoriteSecond)];

    [self clearRequestSenderDelegate];
    self.petFilters = [[PetFilters alloc] init];
    self.petFilters.type = kAdoptFilterTypeMyFavorite;
    self.petResult.pets = [NSMutableArray arrayWithArray:[Utilities getMyFavoriteAnimalsDecoded]];
    NSInteger limitNumber = [self.petResult.pets count]?[self.petResult.pets count]:1;
    self.petResult.limit = [NSNumber numberWithInt:(int)limitNumber];
    self.petResult.total = [NSNumber numberWithInt:(int)[self.petResult.pets count]];
    self.petResult.offset = @"";
    [self setPageIndicatorTitleByResult:self.petResult];
    [self.tableView reloadData];
}

- (void)showFilter {
    [self setNavTitleAndTabBarColor:UIColorFromRGB(kNavigationColorFilterFirst) secondColor:UIColorFromRGB(kNavigationColorFilterSecond)];

    AdoptAnimalFilterController *adoptAnimalFilterViewController = [[AdoptAnimalFilterController alloc] initWithPetFilters:self.petFilters andDelegate:self andFrame:self.view.frame];
    adoptAnimalFilterViewController.petFilters = self.petFilters;
    [adoptAnimalFilterViewController showPickerView];
}

#pragma mark - AdoptAnimalFilterControllerDelegate
- (void)clickSearchWithPetFilters:(PetFilters *)petFilters {
    [self startLoadingWithContent:@"讀取篩選資料"];
    [self changeNavTitle];
    [self clearRequestSenderDelegate];
    self.petFilters.age = [self.petFilters.age isEqualToString:kAdoptFilterAll]?nil:self.petFilters.age;
    self.petFilters.type = [self.petFilters.type isEqualToString:kAdoptFilterAll]?nil:self.petFilters.type;
    self.petFilters.sex = [self.petFilters.sex isEqualToString:kAdoptFilterAll]?nil:self.petFilters.sex;
    self.petFilters.build = [self.petFilters.build isEqualToString:kAdoptFilterAll]?nil:self.petFilters.build;
    self.petFilters.offset = nil;
    self.petResult.filters = self.petFilters;
    [self clearRequestSenderDelegate];
    [self sendRequestWithFilters:self.petFilters];
}

#pragma mark - MGSwipeTableCellDelegate
- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell canSwipe:(MGSwipeDirection)direction {
    return YES;
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Pet *pet = [self.petResult.pets objectAtIndex:indexPath.row];
    if ([self isMyFavoriteAnimalByIndex:indexPath.row]) {
        [Utilities removeFromMyFavoriteAnimal:pet];
        [Utilities addHudViewTo:self withMessage:kRemoveFromFavorite];
    } else {
        [Utilities addToMyFavoriteAnimal:pet];
        [Utilities addHudViewTo:self withMessage:kAddToFavorite];
    }
    if ([self.petFilters.type isEqualToString:kAdoptFilterTypeMyFavorite]) {
        [self sendMyFavoriteRequest];
    } else {
        [self.tableView reloadData];
    }
    return NO;
}

-(NSArray*)swipeTableCell:(MGSwipeTableCell*)cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings*)swipeSettings expansionSettings:(MGSwipeExpansionSettings*)expansionSettings {

    swipeSettings.transition = MGSwipeTransitionBorder;
    expansionSettings.buttonIndex = 0;
    expansionSettings.fillOnTrigger = YES;
    expansionSettings.threshold = 3.0;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *buttons = [self createButtonsWithIndexPath:indexPath direction:direction];

    return buttons;
}

-(NSArray *)createButtonsWithIndexPath:(NSIndexPath *)indexPath direction:(MGSwipeDirection)direction{
    NSMutableArray *result = [NSMutableArray array];
    UIColor *backgroundColor;
    if ([self isMyFavoriteAnimalByIndex:indexPath.row]) {
        backgroundColor = kColorIsFavoriteStore;
    } else {
        backgroundColor = kColorNotFavoriteStore;
    }
    
    MGSwipeButton *button = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"fav.png"] backgroundColor:backgroundColor padding:10];
    
    [result addObject:button];
    
    return result;
}

- (IBAction)clickCheck:(UIBarButtonItem *)sender {
    RequestSender *requestSender = [[RequestSender alloc] init];
    requestSender.delegate = self;
    [requestSender checkFavoriteAnimals:[Utilities getMyFavoriteAnimalsDecoded]];
    [self.requests addObject:requestSender];
    [Utilities startLoadingWithContent:@"更新我的最愛"];
}
@end
