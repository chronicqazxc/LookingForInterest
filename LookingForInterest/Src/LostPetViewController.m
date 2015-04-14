//
//  LostPetViewController.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/14/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetViewController.h"
#import "LostPetRequest.h"
#import "LostPetListCell.h"
#import "LostPet.h"

#define kLostPetListCell @"LostPetListCell"

@interface LostPetViewController () <LostPetRequestDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *lostPets;
@end

@implementation LostPetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    LostPetRequest *lostPetRequest = [[LostPetRequest alloc] init];
    lostPetRequest.lostPetRequestDelegate = self;
    LostPetFilters *lostPetFilters = [[LostPetFilters alloc] init];
    lostPetFilters.variety = @"";
    lostPetFilters.gender = @"";
    [lostPetRequest sendRequestForLostPetWithLostPetFilters:lostPetFilters];
    self.lostPets = @[];
    [self.tableView registerNib:[UINib nibWithNibName:kLostPetListCell bundle:nil] forCellReuseIdentifier:kLostPetListCell];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - LostPetRequestDelegate
- (void)lostPetResultBack:(NSArray *)lostPets {
    self.lostPets = [NSArray arrayWithArray:lostPets];
    [self.tableView reloadData];
//    
//    LostPetDetailViewController *lostPetDetail = [[LostPetDetailViewController alloc] init];
//    lostPetDetail.lostPets = [NSArray arrayWithArray:lostPets];
//    [self presentViewController:lostPetDetail animated:YES completion:nil];
//    NSLog(@"%@",lostPets);
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.lostPets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LostPetListCell *lostPetListCell = [tableView dequeueReusableCellWithIdentifier:kLostPetListCell];
    LostPet *lostPet = [self.lostPets objectAtIndex:indexPath.row];
    /*
     
     @property (weak, nonatomic) IBOutlet UILabel *chipNumber;
     @property (weak, nonatomic) IBOutlet UILabel *lostTime;
     @property (weak, nonatomic) IBOutlet UILabel *lostPlace;
     @property (weak, nonatomic) IBOutlet UILabel *variety;
     @property (weak, nonatomic) IBOutlet UILabel *hairColor;
     @property (weak, nonatomic) IBOutlet UILabel *looking;
     @property (weak, nonatomic) IBOutlet UITextView *describe;
     */
    lostPetListCell.chipNumber.text = lostPet.chipNumber;
    lostPetListCell.lostDate.text = lostPet.lostDate;
    lostPetListCell.lostPlace.text = lostPet.lostPlace;
    lostPetListCell.variety.text = lostPet.variety;
    lostPetListCell.hairColor.text = lostPet.hairColor;
    lostPetListCell.hairStyle.text = lostPet.hairStyle;
    lostPetListCell.describe.text = lostPet.characterized;
    return lostPetListCell;
}
@end
