//
//  AdoptAnimalViewController.m
//  LookingForInterest
//
//  Created by Wayne on 3/5/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "AdoptAnimalViewController.h"
#import "PetListCell.h"
#import "RequestSender.h"

@interface AdoptAnimalViewController () <UITableViewDataSource, UITableViewDelegate, RequestSenderDelegate>
@property (strong, nonatomic) PetResult *petResult;
@property (strong, nonatomic) NSMutableArray *requests;
@property (strong, nonatomic) PetFilters *petFilters;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic) BOOL isSendInitRequest;
@property (strong, nonatomic) NSMutableArray *thumbNails;
@property (strong, nonatomic) NSString *nextPage;
@property (strong, nonatomic) NSString *previousPage;
@property (nonatomic) BOOL isStartLoading;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation AdoptAnimalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;    
    self.isSendInitRequest = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self initProperties];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initProperties {
    self.requests = [NSMutableArray array];
    self.petFilters = [[PetFilters alloc] init];
    self.thumbNails = [[NSMutableArray array] init];
    self.appDelegate = [Utilities getAppDelegate];
    self.isStartLoading = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isSendInitRequest) {
        [self startLoading];
        [self sendInitRequest];
        self.isSendInitRequest = YES;
    }
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
    [self startLoading];
    PetFilters *petFilters = [[PetFilters alloc] init];
    petFilters.offset = self.nextPage;
    [self sendRequestWithFilters:petFilters];
}

- (void)getPreviousPage {
    [self startLoading];
    PetFilters *petFilters = [[PetFilters alloc] init];
    petFilters.offset = self.previousPage;
    [self sendRequestWithFilters:petFilters];
}

- (void)sendRequestWithFilters:(PetFilters *)petFilters {
    RequestSender *requestSender = [[RequestSender alloc] init];
    requestSender.delegate = self;
    [requestSender sendRequestForAdoptAnimalsWithPetFilters:petFilters];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearRequestSenderDelegate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self clearRequestSenderDelegate];
}

- (void)clearRequestSenderDelegate {
    for (RequestSender *requestSender in self.requests) {
        requestSender.delegate = nil;
    }
    [self initProperties];
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
    return 90.0;
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
    PetListCell *petCell = [tableView dequeueReusableCellWithIdentifier:kPetListCellIdentifier];
    if (!petCell) {
//        [tableView registerClass:[PetListCell class] forCellReuseIdentifier:kPetListCellIdentifier];
        petCell = (PetListCell *)[Utilities getNibWithName:@"PetListCell"];
    }
    Pet *pet = [self.petResult.pets objectAtIndex:indexPath.row];
    petCell.imageView.image = [self.thumbNails objectAtIndex:indexPath.row];
    petCell.name.text = [NSString stringWithFormat:@"名字：%@",pet.name];
    petCell.age.text = [NSString stringWithFormat:@"年齡：%@",pet.age];
    petCell.gender.text = pet.sex;
    petCell.body.text = [NSString stringWithFormat:@"體型：%@",pet.build];
    return petCell;
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
            if (self.petResult.next && ![self.petResult.next isEqualToString:@""]) {
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
    self.thumbNails = [self parseThumbNailsByPetResult:petResult];
    self.nextPage = petResult.next;
    self.previousPage = petResult.previous;
    [self.tableView reloadData];
    [Utilities stopLoading];
}

#pragma mark - methods
- (NSMutableArray *)parseThumbNailsByPetResult:(PetResult *)petResult {
    NSMutableArray *thumbNails = [NSMutableArray array];
    for (Pet *pet in petResult.pets) {
        NSURL *thumbNailURL = [NSURL URLWithString:pet.imageName];
        NSData *thumbNailData = [NSData dataWithContentsOfURL:thumbNailURL];
        UIImage *thumbNailImage = [UIImage imageWithData:thumbNailData];
        [thumbNails addObject:thumbNailImage];
    }
    return thumbNails;
}
@end
