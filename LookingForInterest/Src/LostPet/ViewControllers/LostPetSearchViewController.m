//
//  LostPetSearchViewController.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/23/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetSearchViewController.h"
#import "LostPetSearchViewTransition.h"

#define kCellId @"Cell"
#define kSearchAll @"全部"
#define kThreshold 0.30

typedef NS_ENUM(NSInteger, LostPetSearchType) {
    SearchTypeMenu = 0,
    SearchTypeChipNumber,
    SearchTypeLostDate,
    SearchTypeLostLocation,
    SearchTypeVariety
};

@interface LostPetSearchViewController () <UITableViewDataSource, UITableViewDelegate>
- (IBAction)clickCancel:(UIButton *)sender;
@property (strong, nonatomic) LostPetSearchViewTransition <UIViewControllerTransitioningDelegate> *myTransitionDelegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) LostPetSearchType searchType;
@property (strong, nonatomic) UIDatePicker *datePicker;
- (IBAction)panInView:(UIPanGestureRecognizer *)recognizer;
- (IBAction)clickOk:(UIButton *)sender;
@end

@implementation LostPetSearchViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.myTransitionDelegate = [[LostPetSearchViewTransition alloc] init];
        self.transitioningDelegate = self.myTransitionDelegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchType = SearchTypeMenu;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UIVisualEffect *visuallEffect = [[UIVisualEffect alloc] init];
    self.tableView.separatorEffect = visuallEffect;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self initDatePicker];
    
    [self.tableView reloadData];
}

- (void)initDatePicker {
    self.datePicker = [[UIDatePicker alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy/MM/dd";
    if (self.lostPetFilters.lostDate && ![self.lostPetFilters.lostDate isEqualToString:@""]) {
        NSDate *date = [dateFormatter dateFromString:self.lostPetFilters.lostDate];
        self.datePicker.date = date;
    }
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.locale = [NSLocale currentLocale];
    self.datePicker.frame = CGRectMake(0,0,[Utilities getScreenSize].width, 162.0);
    self.datePicker.frame = CGRectOffset(self.datePicker.frame, 0, -(CGRectGetHeight(self.datePicker.frame)/5));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

- (IBAction)clickCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickOk:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(processSearchWithFilters:)]) {
            [self.delegate processSearchWithFilters:self.lostPetFilters];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /*
     SearchTypeMenu = 0,
     SearchTypeChipNumber,
     SearchTypeLostDate,
     SearchTypeLostLocation,
     SearchTypeVariety
     */
    NSInteger numberOfRows = 0;
    switch (self.searchType) {
        case SearchTypeMenu:
            numberOfRows = 4;
            break;
        case SearchTypeChipNumber:
            numberOfRows = 1;
            break;
        case SearchTypeLostDate:
            numberOfRows = 4;
            break;
        case SearchTypeLostLocation:
            numberOfRows = 1;
            break;
        case SearchTypeVariety:
            numberOfRows = 3;
            break;
        default:
            break;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
    switch (self.searchType) {
        case SearchTypeMenu:
            cell = [self processMenuCell:cell indexPath:indexPath];
            break;
        case SearchTypeChipNumber:
            
            break;
        case SearchTypeLostDate:
            
            break;
        case SearchTypeLostLocation:
            
            break;
        case SearchTypeVariety:
            
            break;
        default:
            break;
    }
    return cell;
}

- (UITableViewCell *)processMenuCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    NSString *detailText;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"晶片號碼";
            detailText = self.lostPetFilters.chipNumber?self.lostPetFilters.chipNumber:@"";
            cell.detailTextLabel.text = [detailText isEqualToString:@""]?kSearchAll:self.lostPetFilters.chipNumber;
            break;
        case 1:
            cell.textLabel.text = @"遺失時間";
            detailText = self.lostPetFilters.lostDate?self.lostPetFilters.lostDate:@"";
            cell.detailTextLabel.text = [detailText isEqualToString:@""]?kSearchAll:self.lostPetFilters.lostDate;
            break;
        case 2:
            cell.textLabel.text = @"遺失地點";
            detailText = self.lostPetFilters.lostPlace?self.lostPetFilters.lostPlace:@"";
            cell.detailTextLabel.text = [detailText isEqualToString:@""]?kSearchAll:self.lostPetFilters.lostPlace;
            break;
        case 3:
            cell.textLabel.text = @"品種";
            detailText = self.lostPetFilters.variety?self.lostPetFilters.variety:@"";
            cell.detailTextLabel.text = [detailText isEqualToString:@""]?kSearchAll:self.lostPetFilters.variety;
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /*
     SearchTypeMenu = 0,
     SearchTypeChipNumber,
     SearchTypeLostDate,
     SearchTypeLostLocation,
     SearchTypeVariety
     */
    
    switch (self.searchType) {
        case SearchTypeMenu:
            [self selectedMenuCellAtIndex:indexPath.row];
            break;
        case SearchTypeChipNumber:
            break;
        case SearchTypeLostDate:
            break;
        case SearchTypeLostLocation:
            break;
        case SearchTypeVariety:
            break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"test action" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"test action");
    }];
    rowAction.backgroundColor = [UIColor blueColor];
    rowAction.backgroundEffect = [[UIVisualEffect alloc] init];
    
//    UITableViewRowAction *moreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Button1" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
//        // maybe show an action sheet with more options
//        [tableView setEditing:NO];
//    }];
//    moreAction.backgroundColor = [UIColor blueColor];
//    
//    UITableViewRowAction *moreAction2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Button2" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
//        [tableView setEditing:NO];
//    }];
//    moreAction2.backgroundColor = [UIColor blueColor];
//    
//    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }];
    
    return @[rowAction];
}

#pragma mark -
- (void)selectedMenuCellAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            [self inputTextViewTitle:@"搜尋條件"
                             message:@"晶片編號"
                        doneSelector:@selector(setChipNumber:)
                              caller:self.lostPetFilters];
            break;
        case 1:
            [self showDatePicker];
            break;
        case 2:
            [self inputTextViewTitle:@"搜尋條件"
                             message:@"走失地點"
                        doneSelector:@selector(setLostPlace:)
                              caller:self.lostPetFilters];
            break;
        case 3:
            [self showVarietyPicker];
            break;
        default:
            break;
    }
}

- (void)inputTextViewTitle:(NSString *)title message:(NSString *)message doneSelector:(SEL)doneSelector caller:(id)caller{
    UIAlertController *inputTextView = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [inputTextView addTextFieldWithConfigurationHandler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textFiled = [inputTextView.textFields firstObject];
        NSString *textFieldValue = textFiled.text;
        if ([caller respondsToSelector:doneSelector]) {
            [caller performSelectorOnMainThread:doneSelector withObject:textFieldValue waitUntilDone:YES];
            NSLog(@"perform with value:%@",textFieldValue);
        } else {
            NSLog(@"can't perform selector");
        }
        [self.tableView reloadData];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [inputTextView dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [inputTextView addAction:okAction];
    [inputTextView addAction:cancelAction];
    
    [self presentViewController:inputTextView animated:YES completion:nil];
}

#pragma mark - Show date picker
- (void)showDatePicker {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"搜尋條件" message:@"走失日期" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self setSelectedDate];
    }];
    UIAlertAction *allDateAction = [UIAlertAction actionWithTitle:@"全部日期" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.lostPetFilters.lostDate = @"";
        [self.tableView reloadData];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:okAction];
    [alertController addAction:allDateAction];
    [alertController addAction:cancelAction];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    
    [viewController.view addSubview:self.datePicker];

    [alertController setValue:viewController forKey:@"contentViewController"];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"搜尋條件"];
    [title addAttribute:NSFontAttributeName
                  value:[UIFont systemFontOfSize:20.0]
                  range:NSMakeRange(0, 4)];
    [alertController setValue:title forKey:@"attributedTitle"];
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:@"走失日期"];
    [title addAttribute:NSFontAttributeName
                  value:[UIFont systemFontOfSize:5.0]
                  range:NSMakeRange(0, 4)];
    [alertController setValue:message forKey:@"attributedMessage"];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setSelectedDate {
    if (self.datePicker) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy/MM/dd";
        NSString *dateString = [dateFormatter stringFromDate:self.datePicker.date];
        
        self.lostPetFilters.lostDate = dateString;
        
        [self.tableView reloadData];
    }
}

#pragma mark - Show variety picker
- (void)showVarietyPicker {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"搜尋條件" message:@"品種" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"自行輸入";
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = [alertController.textFields firstObject];
        NSString *value = textField.text;
        [self.lostPetFilters performSelectorOnMainThread:@selector(setVariety:) withObject:value waitUntilDone:YES];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
    UIAlertAction *dogAction = [UIAlertAction actionWithTitle:@"狗" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.lostPetFilters performSelectorOnMainThread:@selector(setVariety:) withObject:@"狗" waitUntilDone:YES];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
    UIAlertAction *catAction = [UIAlertAction actionWithTitle:@"貓" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.lostPetFilters performSelectorOnMainThread:@selector(setVariety:) withObject:@"貓" waitUntilDone:YES];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:dogAction];
    [alertController addAction:catAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Pan gesture
- (IBAction)panInView:(UIPanGestureRecognizer *)recognizer {
    return;
//    self.myTransitionDelegate.isInteraction = YES;
//    
//    CGFloat percentageY = [recognizer translationInView:self.view.superview].y / self.view.superview.bounds.size.height;
//    NSLog(@"percentageY:%.2f",percentageY);
//    
//    if (percentageY < 0) {
////        self.adBannerView.alpha = 1 + percentageY * 2;
//    } else {
////        self.adBannerView.alpha = self.adBannerView.alpha + percentageY * 2;
//    }
//    
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        if (percentageY > 0){
//            self.myTransitionDelegate.direction = DirectionDown;
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
//    }
//    
//    if (self.myTransitionDelegate.direction == DirectionDown) {
//        CGFloat percentage = percentageY;
//        [self.myTransitionDelegate updateInteractiveTransition:percentage];
//    }
//    
//    if (recognizer.state == UIGestureRecognizerStateEnded ||
//        recognizer.state == UIGestureRecognizerStateCancelled ||
//        recognizer.state == UIGestureRecognizerStateFailed
//        ) {
//        
//        CGFloat velocityY = [recognizer velocityInView:recognizer.view.superview].y;
//        BOOL cancel = YES;
//        CGFloat points;
//        NSTimeInterval duration;
//        
//        if (self.myTransitionDelegate.direction == DirectionDown) {
//            cancel = (percentageY < kThreshold);
//            points = cancel ? recognizer.view.frame.origin.y : self.view.superview.bounds.size.height - recognizer.view.frame.origin.y;
//            duration = points / velocityY;
//        }
//        
//        if (duration < .2) {
//            duration = .2;
//        }else if(duration > .6){
//            duration = .6;
//        }
//        
//        if (recognizer.state == UIGestureRecognizerStateFailed) {
//            [self.myTransitionDelegate cancelInteractiveTransitionWithDuration:.35];
//        } else {
//            cancel?[self.myTransitionDelegate cancelInteractiveTransitionWithDuration:duration]:[self.myTransitionDelegate finishInteractiveTransitionWithDuration:duration];
//        }
//    }
    
}
@end
