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
#import "ManulAdoptListViewController.h"
#import <iAd/iAd.h>
#import "TableLoadNextPage.h"
#import "TableLoadPreviousPage.h"

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
#define kReloadDistance 120
#define kSpringTreshold 150
#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@interface AdoptAnimalViewController () <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, ADBannerViewDelegate, RequestSenderDelegate, AdoptAnimalFilterControllerDelegate, MGSwipeTableCellDelegate, ManulViewControllerDelegate>
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
@property (strong, nonatomic) ManulAdoptListViewController *manulAdoptListViewController;
@property (nonatomic) BOOL hadShowManul;
@property (nonatomic) BOOL hadShowDataSource;
@property (weak, nonatomic) IBOutlet ADBannerView *adBannerView;
@property (strong, nonatomic) TableLoadPreviousPage *loadPreviousPageView;
@property (strong, nonatomic) TableLoadNextPage *loadNextPageView;
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
    self.hadShowManul = NO;
    self.hadShowDataSource = NO;
    self.petFilters = [[PetFilters alloc] init];
//    [self composeFilters];
    [self initProperties];
    self.adBannerView.delegate = self;
    
    self.navigationItem.leftBarButtonItem.title = @"首頁";
    NSDictionary *attributeDic2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIColor whiteColor], NSForegroundColorAttributeName,
                                   [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:15.0], NSFontAttributeName, nil];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:attributeDic2 forState:UIControlStateNormal];
    self.loadPreviousPageView = (TableLoadPreviousPage *)[Utilities getNibWithName:@"TableLoadPreviousPage"];
    self.loadPreviousPageView.frame = CGRectZero;
    self.loadPreviousPageView.canLoading = NO;
    self.loadPreviousPageView.indicatorLabel.text = @"";
    [self.tableView addSubview:self.loadPreviousPageView];
    [self.tableView sendSubviewToBack:self.loadPreviousPageView];
    
    self.loadNextPageView = (TableLoadNextPage *)[Utilities getNibWithName:@"TableLoadNextPage"];
    self.loadNextPageView.frame = CGRectZero;
    self.loadNextPageView.canLoading = NO;
    self.loadNextPageView.indicatorLabel.text = @"";
    [self.tableView addSubview:self.loadNextPageView];
    [self.tableView sendSubviewToBack:self.loadNextPageView];
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
        self.navigationItem.title = kAdoptAnimalTitle(kAdoptFilterTypeDog);
        //        self.navigationController.navigationBar.topItem.title = kAdoptAnimalTitle(kAdoptFilterTypeDog);
    } else if ([self.petFilters.type isEqualToString:kAdoptFilterTypeCat]) {
        self.navigationItem.title = kAdoptAnimalTitle(kAdoptFilterTypeCat);
        //        self.navigationController.navigationBar.topItem.title = kAdoptAnimalTitle(kAdoptFilterTypeCat);
    } else if ([self.petFilters.type isEqualToString:kAdoptFilterTypeOther]) {
        self.navigationItem.title = kAdoptAnimalTitle(kAdoptFilterTypeOther);
        //        self.navigationController.navigationBar.topItem.title = kAdoptAnimalTitle(kAdoptFilterTypeOther);
    } else if ([self.petFilters.type isEqualToString:kAdoptFilterTypeMyFavorite]) {
        self.navigationItem.title = kAdoptAnimalTitle(kAdoptFilterTypeMyFavorite);
        //        self.navigationController.navigationBar.topItem.title = kAdoptAnimalTitle(kAdoptFilterTypeMyFavorite);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![Utilities getNeverShowManulMenuWithKey:kManulAdoptListKey]) {
        if (!self.hadShowManul) {
            self.manulAdoptListViewController = [[ManulAdoptListViewController alloc] initWithNibName:@"ManulViewController" bundle:nil];
            self.manulAdoptListViewController.delegate = self;
            [self presentViewController:self.manulAdoptListViewController animated:YES completion:nil];
        } else if (!self.isSendInitRequest && ![self.petResult.pets count]) {
            if (!self.hadShowDataSource) {
                [self showDataSource];
            }
            [self startLoadingWithContent:nil];
            [self sendInitRequest];
            self.isSendInitRequest = YES;
        } else {
            [self.tableView reloadData];
        }
    } else if (!self.isSendInitRequest && ![self.petResult.pets count]) {
        if (!self.hadShowDataSource) {
            [self showDataSource];
        }
        [self startLoadingWithContent:nil];
        [self sendInitRequest];
        self.isSendInitRequest = YES;
    } else {
        [self.tableView reloadData];
    }
}

- (void)showDataSource {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"臺北市開放認養動物" message:@"資料來源:臺北市政府資料開放平台" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
    self.hadShowDataSource = YES;
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
            if ([pet.type isEqualToString:kAdoptFilterTypeDog]) {
                petCell.thumbNail.image = [UIImage imageNamed:@"dog_icon.png"];
            } else if ([pet.type isEqualToString:kAdoptFilterTypeCat]) {
                petCell.thumbNail.image = [UIImage imageNamed:@"cat_icon.png"];
            } else if ([pet.type isEqualToString:kAdoptFilterTypeOther]) {
                petCell.thumbNail.image = [UIImage imageNamed:@"rabbit_icon.png"];
            } else {
                petCell.thumbNail.image = [UIImage imageNamed:@"Loading100x100.png"];
            }
            
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

-(CGFloat)shiftInPercents{
    return (kReloadDistance / 100) * -self.tableView.contentOffset.y;
}

-(void)scaleItem:(UIView *)item{
    CGFloat shiftInPercents = [self shiftInPercents];
    CGFloat buildigsScaleRatio = shiftInPercents / 100;
    [item setTransform:CGAffineTransformMakeScale(buildigsScaleRatio,buildigsScaleRatio)];

}

- (void)rotateInfinitily:(UIView *)view {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 2.0);
    CGFloat SunRotationAnimationDuration = 0.9f;
    rotationAnimation.duration = SunRotationAnimationDuration;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)stopSunRotating:(UIView *)view{
    [view.layer removeAnimationForKey:@"rotationAnimation"];
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
    
    if (self.isStartLoading == NO) {
        if (offset.y <= 0) {
//            [self scaleItem:nil];
            [self.loadPreviousPageView.indicatorLabel setAlpha:(0-offset.y)/100];
            if (offset.y <= -kReloadDistance-20 && self.loadPreviousPageView.canLoading) {
                self.loadPreviousPageView.indicatorLabel.text = @"換上一頁！";
            } else if (self.loadPreviousPageView.canLoading) {
                self.loadPreviousPageView.indicatorLabel.text = @"再拉再拉！";
            } else {
                self.loadPreviousPageView.indicatorLabel.text = @"沒上一頁！";
            }
            if (offset.y <= -kSpringTreshold-50) {
                [self.tableView setContentOffset:CGPointMake(0.f, -kSpringTreshold-50)];
            }
            self.loadPreviousPageView.frame = CGRectMake(0.f, 0.f, self.tableView.frame.size.width, offset.y);
        } else if (y > h) {
            [self.loadNextPageView.indicatorLabel setAlpha:(y-h)/100];
//            [self scaleItem:nil];
            if (self.loadNextPageView.canLoading) {
                if (y > h + kReloadDistance) {
                    self.loadNextPageView.indicatorLabel.text = @"換下一頁！";
                    [self.tableView setContentOffset:CGPointMake(0.f, h+kSpringTreshold-CGRectGetHeight(bounds))];
                } else {
                    self.loadNextPageView.indicatorLabel.text = @"再拉再拉！";
                }
                self.loadNextPageView.frame = CGRectMake(0.f, h, self.tableView.frame.size.width, y-h);
            } else {
                self.loadNextPageView.indicatorLabel.text = @"";
            }
        }
    }
    
    if (self.isStartLoading == NO) {
        if (offset.y <= -kReloadDistance-20 && self.loadPreviousPageView.canLoading) {
            if ((self.petResult.previous && ![self.petResult.previous isEqualToString:@""]) ||
                [self.petResult.next isEqualToString:@"40"]) {
                [self rotateInfinitily:self.loadPreviousPageView.indicator];
                self.isStartLoading = YES;
                [self getPreviousPage];
            }
        } else if (y > h + kReloadDistance && self.loadNextPageView.canLoading) {
            if (self.petResult.next && ![self.petResult.next isEqualToString:@""] && [self.petResult.next intValue] < [self.petResult.total intValue]) {
                [self rotateInfinitily:self.loadNextPageView.indicator];
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
    [self stopSunRotating:self.loadPreviousPageView.indicator];
    [self stopSunRotating:self.loadNextPageView.indicator];
    [self setPageIndicatorTitleByResult:petResult];
    self.loadNextPageView.indicatorLabel.text = @"";
    
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
//        self.previousPageView.hidden = YES;
//        self.nextPageView.hidden = YES;
        self.loadPreviousPageView.canLoading = NO;
        self.loadNextPageView.canLoading = NO;
    } else if ([currentPage isEqualToString:@"1"] && ![currentPage isEqualToString:totalPage]) {
//        self.previousPageView.hidden = YES;
//        self.nextPageView.hidden = NO;
        self.loadPreviousPageView.canLoading = NO;
        self.loadNextPageView.canLoading = YES;
    } else if (![currentPage isEqualToString:@"1"] && [currentPage isEqualToString:totalPage]) {
//        self.previousPageView.hidden = NO;
//        self.nextPageView.hidden = YES;
        self.loadPreviousPageView.canLoading = YES;
        self.loadNextPageView.canLoading = NO;
    } else {
//        self.previousPageView.hidden = NO;
//        self.nextPageView.hidden = NO;
        self.loadPreviousPageView.canLoading = YES;
        self.loadNextPageView.canLoading = YES;
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
            [self setNavTitleAndTabBarColor:UIColorFromRGB(kNavigationColorDogFirst) secondColor:UIColorFromRGB(kNavigationColorDogSecond)];
            [self sendDogRequest];
            [self changeNavTitle];
            self.checkButton.enabled = NO;
            break;
        case 1:
            [self setNavTitleAndTabBarColor:UIColorFromRGB(kNavigationColorCatFirst) secondColor:UIColorFromRGB(kNavigationColorCatSecond)];
            [self sendCatRequest];
            [self changeNavTitle];
            self.checkButton.enabled = NO;
            break;
        case 2:
            [self setNavTitleAndTabBarColor:UIColorFromRGB(kNavigationColorOtherFirst) secondColor:UIColorFromRGB(kNavigationColorOtherSecond)];
            [self sendOtherRequest];
            [self changeNavTitle];
            self.checkButton.enabled = NO;
            break;
        case 3:
            [self setNavTitleAndTabBarColor:UIColorFromRGB(kNavigationColorMyFavoriteFirst) secondColor:UIColorFromRGB(kNavigationColorMyFavoriteSecond)];
            [self sendMyFavoriteRequest];
            [self changeNavTitle];
            if ([self.petResult.pets count]) {
                self.checkButton.enabled = YES;
            } else {
                self.checkButton.enabled = NO;
            }
            break;
        case 4:
            [self setNavTitleAndTabBarColor:UIColorFromRGB(kNavigationColorFilterFirst) secondColor:UIColorFromRGB(kNavigationColorFilterSecond)];
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
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
        shadow.shadowOffset = CGSizeMake(0, 1);
        NSDictionary *attributeDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                      shadow, NSShadowAttributeName,
                                      [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil];
        [self.navigationController.navigationBar setTitleTextAttributes:attributeDic];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        NSDictionary *attributeDic2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                      [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:15.0], NSFontAttributeName, nil];
        [self.navigationController.navigationBar setTitleTextAttributes:attributeDic];
        [backButton setTitleTextAttributes:attributeDic2 forState:UIControlStateNormal];
        self.navigationItem.backBarButtonItem = backButton;
    } else {
        self.gradientLayer.colors = colors;
        UIImage *img = [Utilities imageWithView:self.navigationBackgroundView];
        [self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)sendDogRequest {
    [self clearRequestSenderDelegate];
    [self startLoadingWithContent:@"讀取汪星人"];
    self.petFilters = [[PetFilters alloc] init];
    self.petFilters.type = kAdoptFilterTypeDog;
    self.petFilters.offset = nil;
    [self sendRequestWithFilters:self.petFilters];
}

- (void)sendCatRequest {
    [self clearRequestSenderDelegate];
    [self startLoadingWithContent:@"讀取喵星人"];
    self.petFilters = [[PetFilters alloc] init];
    self.petFilters.type = kAdoptFilterTypeCat;
    self.petFilters.offset = nil;
    [self sendRequestWithFilters:self.petFilters];
}

- (void)sendOtherRequest {
    [self clearRequestSenderDelegate];
    [self startLoadingWithContent:@"讀取其他動物"];
    self.petFilters = [[PetFilters alloc] init];
    self.petFilters.type = kAdoptFilterTypeOther;
    self.petFilters.offset = nil;
    [self sendRequestWithFilters:self.petFilters];
}

- (void)sendMyFavoriteRequest {
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

- (NSArray*)swipeTableCell:(MGSwipeTableCell*)cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings*)swipeSettings expansionSettings:(MGSwipeExpansionSettings*)expansionSettings {

    swipeSettings.transition = MGSwipeTransitionBorder;
    expansionSettings.buttonIndex = 0;
    expansionSettings.fillOnTrigger = YES;
    expansionSettings.threshold = 3.0;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *buttons = [self createButtonsWithIndexPath:indexPath direction:direction];

    return buttons;
}

- (NSArray *)createButtonsWithIndexPath:(NSIndexPath *)indexPath direction:(MGSwipeDirection)direction{
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

#pragma mark - ManulViewControllerDelegate
- (void)manulConfirmClicked {
    [self.manulAdoptListViewController dismissViewControllerAnimated:YES completion:nil];
    self.hadShowManul = YES;
    if (self.manulAdoptListViewController.neverShowSwitch.on) {
        [Utilities setNeverShowManulMenuWithKey:kManulAdoptListKey];
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
