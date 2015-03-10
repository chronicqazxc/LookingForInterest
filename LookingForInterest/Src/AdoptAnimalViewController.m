//
//  AdoptAnimalViewController.m
//  LookingForInterest
//
//  Created by Wayne on 3/5/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AdoptAnimalViewController.h"
#import "RequestSender.h"
#import "AdoptAnimalFilterController.h"
#import <MGSwipeTableCell/MGSwipeButton.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import "AnimalDetailScrollViewController.h"
#import "AnimalListTableViewCell.h"

#define AdoptAnimalTitle(type) [NSString stringWithFormat:@"領養%@",type]

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
    [self initProperties];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initProperties {
    self.requests = [NSMutableArray array];
    self.petFilters = [[PetFilters alloc] init];
    [self composeFilters];
    self.appDelegate = [Utilities getAppDelegate];
    self.isStartLoading = NO;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self changeNavTitle];
}

- (void)changeNavTitle {
    if ([self.petFilters.type isEqualToString:kAdoptFilterAll] || !self.petFilters.type || [self.petFilters.type isEqualToString:@""]) {
        self.navigationItem.title = AdoptAnimalTitle(@"全部");
    } else if ([self.petFilters.type isEqualToString:kAdoptFilterTypeDog]) {
        self.navigationItem.title = AdoptAnimalTitle(kAdoptFilterTypeDog);
    } else if ([self.petFilters.type isEqualToString:kAdoptFilterTypeCat]) {
        self.navigationItem.title = AdoptAnimalTitle(kAdoptFilterTypeCat);
    } else if ([self.petFilters.type isEqualToString:kAdoptFilterTypeOther]) {
        self.navigationItem.title = AdoptAnimalTitle(kAdoptFilterTypeOther);
    } else if ([self.petFilters.type isEqualToString:kAdoptFilterTypeMyFavorite]) {
        self.navigationItem.title = AdoptAnimalTitle(kAdoptFilterTypeMyFavorite);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isSendInitRequest && ![self.petResult.pets count]) {
        [self startLoading];
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

- (void)startLoading {
    self.appDelegate.viewController = self;
    [Utilities startLoading];
}

- (void)sendInitRequest {
    RequestSender *requestSender = [[RequestSender alloc] init];
    requestSender.delegate = self;
    [requestSender sendRequestForAdoptAnimalsWithPetFilters:self.petFilters];
}

- (void)getNextPage {
    [self clearRequestSenderDelegate];
    [self startLoading];
//    PetFilters *petFilters = [[PetFilters alloc] init];
//    petFilters.offset = self.nextPage;
    self.petFilters.offset = self.nextPage;
    self.petResult.filters = self.petFilters;
    [self sendRequestWithFilters:self.petFilters];
}

- (void)getPreviousPage {
    [self clearRequestSenderDelegate];
    [self startLoading];
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
    return 113.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    NSInteger petsCount = [self.petResult.pets count];
    if (petsCount) {
        numberOfRows = petsCount;
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
    Pet *pet = [self.petResult.pets objectAtIndex:indexPath.row];

    petCell.name.text = [NSString stringWithFormat:@"名字：%@（%@）",pet.name ,pet.type];
    petCell.variety.text = [NSString stringWithFormat:@"品種：%@",pet.variety];
    petCell.age.text = [NSString stringWithFormat:@"年齡：%@",pet.age];
    petCell.gender.text = [NSString stringWithFormat:@"性別：%@",pet.sex];
    petCell.body.text = [NSString stringWithFormat:@"體型：%@",pet.build];
    
    petCell.thumbNail.layer.masksToBounds = YES;
    petCell.thumbNail.layer.borderWidth = 1.0;
    petCell.thumbNail.layer.cornerRadius = CGRectGetHeight(petCell.thumbNail.frame)/2.0;
    if (!pet.thumbNail && !self.isStartLoading) {
        petCell.thumbNail.image = [UIImage imageNamed:@"Loading100x100.png"];
        [self startThumbNailDownload:pet forIndexPath:indexPath];
        petCell.thumbNail.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.3].CGColor;
    } else {
        petCell.thumbNail.image = pet.thumbNail;
        petCell.thumbNail.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    }
    
    petCell.delegate = self;
    return petCell;
}

- (BOOL)isMyFavoriteAnimalByIndex:(NSInteger)index {
    NSArray *animals = [Utilities getMyFavoriteAnimalsDecoded];
    Pet *selectedAnimal = [self.petResult.pets objectAtIndex:index];
    BOOL isMyFavorite = NO;
    for (Pet *pet in animals) {
        if ([pet.acceptNum isEqualToString:selectedAnimal.acceptNum]) {
            isMyFavorite = YES;
            break;
        }
    }
    return isMyFavorite;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];    
    AnimalDetailScrollViewController *animalDetailScrollViewController = [[AnimalDetailScrollViewController alloc] initWithNibName:@"AnimalDetailScrollViewController" bundle:nil];
    animalDetailScrollViewController.petResult = self.petResult;
    animalDetailScrollViewController.selectedIndexPath = indexPath;
    [self.navigationController pushViewController:animalDetailScrollViewController animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
        CGPoint offset = aScrollView.contentOffset;
        CGRect bounds = aScrollView.bounds;
        CGSize size = aScrollView.contentSize;
        UIEdgeInsets inset = aScrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        float reloadDistance = 90;
    
    if (self.isStartLoading == NO) {
        if(y > h + reloadDistance) {
            if (self.petResult.next && ![self.petResult.next isEqualToString:@""] && [self.petResult.next intValue] < [self.petResult.total intValue]) {
                self.isStartLoading = YES;
                [self getNextPage];
            }
        } else if (offset.y <= -90) {
            if (self.petResult.previous && ![self.petResult.previous isEqualToString:@""]) {
                self.isStartLoading = YES;
                [self getPreviousPage];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate && !self.isStartLoading) {
        [self loadThumbNailForOnScreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!self.isStartLoading) {
        [self loadThumbNailForOnScreenRows];
    }
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
- (void)requestFaildWithMessage:(NSString *)message {
    [Utilities stopLoading];
    self.isStartLoading = NO;
    UIAlertController *alertController = [Utilities normalAlertWithTitle:@"錯誤" message:message withObj:nil andSEL:nil byCaller:self];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)petResultBack:(PetResult *)petResult {
    self.isStartLoading = NO;
    self.petResult = petResult;
    self.nextPage = petResult.next;
    self.previousPage = petResult.previous;
    [self.tableView reloadData];
    if ([self.petResult.pets count]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [Utilities stopLoading];
}

- (void)thumbNailBack:(UIImage *)image indexPath:(NSIndexPath *)indexPath {
    if (self.petResult && [self.petResult.pets count]) {
        Pet *pet = [self.petResult.pets objectAtIndex:indexPath.row];
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
            self.checkButton.enabled = YES;
            break;
        case 4:
            [self showFilter];
            self.checkButton.enabled = NO;
            break;
        default:
            break;
    }
}

- (void)sendDogRequest {
    [self clearRequestSenderDelegate];
    [self startLoading];
    self.petFilters.type = kAdoptFilterTypeDog;
    self.petFilters.offset = nil;
    [self sendRequestWithFilters:self.petFilters];
}

- (void)sendCatRequest {
    [self clearRequestSenderDelegate];
    [self startLoading];
    self.petFilters.type = kAdoptFilterTypeCat;
    self.petFilters.offset = nil;
    [self sendRequestWithFilters:self.petFilters];
}

- (void)sendOtherRequest {
    [self clearRequestSenderDelegate];
    [self startLoading];
    self.petFilters.type = kAdoptFilterTypeOther;
    self.petFilters.offset = nil;
    [self sendRequestWithFilters:self.petFilters];
}

- (void)sendMyFavoriteRequest {
    [self clearRequestSenderDelegate];
    self.petFilters.type = kAdoptFilterTypeMyFavorite;
    self.petResult.pets = [NSMutableArray arrayWithArray:[Utilities getMyFavoriteAnimalsDecoded]];
    [self.tableView reloadData];
}

- (void)showFilter {
    AdoptAnimalFilterController *adoptAnimalFilterViewController = [[AdoptAnimalFilterController alloc] initWithPetFilters:self.petFilters andDelegate:self andFrame:self.view.frame];
    adoptAnimalFilterViewController.petFilters = self.petFilters;
    [adoptAnimalFilterViewController showPickerView];
}

#pragma mark - AdoptAnimalFilterControllerDelegate
- (void)clickSearchWithPetFilters:(PetFilters *)petFilters {
    [self startLoading];
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
    NSMutableArray * result = [NSMutableArray array];
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
    
}
@end
