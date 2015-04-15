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
#import "MenuViewController.h"

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
    
    [self initNavigationBar];
    
}

- (void)initNavigationBar {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"首頁" style:UIBarButtonItemStylePlain target:self action:@selector(goToMenu)];
    
    NSDictionary *attributeDic2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIColor darkTextColor], NSForegroundColorAttributeName,
                                   [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:15.0], NSFontAttributeName, nil];
    [backButton setTitleTextAttributes:attributeDic2 forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationController.navigationBar.tintColor = [UIColor darkTextColor];
}

- (void)goToMenu {
    UIStoryboard *firstStoryboard = [UIStoryboard storyboardWithName:kFirstStoryboard bundle:nil];
    MenuViewController *controller = (MenuViewController *)[firstStoryboard instantiateViewControllerWithIdentifier:kMenuStoryboardID];

    [self presentViewController:controller animated:NO completion:nil];
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
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.lostPets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LostPetListCell *lostPetListCell = [tableView dequeueReusableCellWithIdentifier:kLostPetListCell];
    LostPet *lostPet = [self.lostPets objectAtIndex:indexPath.row];
    
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
