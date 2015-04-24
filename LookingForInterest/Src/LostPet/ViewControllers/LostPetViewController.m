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
#import "LostPetStatus.h"
#import "MenuViewController.h"
#import "TableLoadPreviousPage.h"
#import "TableLoadNextPage.h"
#import "GoTopButton.h"
#import "MenuTransition.h"
#import "LostPetTransition.h"
#import "LostPetScrollViewController.h"
#import "LostPetSearchViewController.h"
#import <iAd/iAd.h>

#define kReloadDistance 100
#define kSpringTreshold 130
#define kThreshold 0.30

#define kLostPetListCell @"LostPetListCell"
#define kNoDataCell @"NoDataCell"
#define kToMenuSegueIdentifier @"ToMenuSegueIdentifier"

#define kLoading @"Loading..."
#define kNodate @"查無資料..."

@interface LostPetViewController () <LostPetRequestDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITabBarDelegate, UIPopoverControllerDelegate, LostPetSearchViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *lostPets;
@property (strong, nonatomic) NSMutableArray *requests;
@property (strong, nonatomic) TableLoadPreviousPage *loadPreviousPageView;
@property (strong, nonatomic) TableLoadNextPage *loadNextPageView;
@property (nonatomic) BOOL isStartLoading;
@property (strong, nonatomic) LostPetStatus *lostPetStatus;
@property (weak, nonatomic) IBOutlet GoTopButton *pageIndicator;

@property (strong, nonatomic) UIView *circleView;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *attachment;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;
@property (strong, nonatomic) UIDynamicItemBehavior *circleViewBehavior;
@property (strong, nonatomic) UIAttachmentBehavior *attachmentBehavior;
@property CGPoint currentLocation;

- (IBAction)panInView:(UIPanGestureRecognizer *)recognizer;
@property (strong, nonatomic) MenuTransition *menuTransition;

@property (weak, nonatomic) IBOutlet ADBannerView *adBannerView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic) BOOL isBeenInit;
- (IBAction)clickSearch:(UIBarButtonItem *)sender;
@property (strong, nonatomic) LostPetFilters *lostPetFilters;
@property (strong, nonatomic) NSString *informationOnCell;
@end

@implementation LostPetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.requests = [NSMutableArray array];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.lostPets = @[];
    [self.tableView registerNib:[UINib nibWithNibName:kLostPetListCell bundle:nil] forCellReuseIdentifier:kLostPetListCell];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.isStartLoading = NO;
    
    self.informationOnCell = kLoading;
    
    self.lostPetStatus = [[LostPetStatus alloc] init];
    
    [self initNavigationBar];
    
    [self initLoadingPageView];
    
    self.menuTransition = [[MenuTransition alloc] init];
    
    self.adBannerView.alpha = 0.0;

    self.isBeenInit = NO;
    
//    [self initDynamicAnimation];
}

- (void)initNavigationBar {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"首頁" style:UIBarButtonItemStylePlain target:self action:@selector(goToMenu:)];
    
    NSDictionary *attributeDic2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIColor darkTextColor], NSForegroundColorAttributeName,
                                   [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:15.0], NSFontAttributeName, nil];
    [backButton setTitleTextAttributes:attributeDic2 forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationController.navigationBar.tintColor = [UIColor darkTextColor];
}

- (void)initLoadingPageView {
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

- (void)goToMenu:(UIBarButtonItem *)sender {
    if (sender) {
        self.menuTransition.isInteraction = NO;
    } else {
        self.menuTransition.isInteraction = YES;
    }
    
    UIStoryboard *firstStoryboard = [UIStoryboard storyboardWithName:kFirstStoryboard bundle:nil];
    MenuViewController *controller = (MenuViewController *)[firstStoryboard instantiateViewControllerWithIdentifier:kMenuStoryboardID];
    controller.transitioningDelegate = self.menuTransition;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)initDynamicAnimation {
    
    [self initCircleView];
    
    [self initAnimator];
    
    [self addGravityBehavior];
    
    [self addCollisionBehavior];
    
    [self addCircleViewBehavior];
    
//    [self addAttachmentBehavior];
    
}

- (void)initCircleView {
    self.circleView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2-15, 0, 30, 30)];
    self.circleView.layer.cornerRadius = CGRectGetHeight(self.circleView.frame)/2;
    self.circleView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.circleView];
}

- (void)initAnimator {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}

- (void)addGravityBehavior{
    if (!self.animator) {
        [self initAnimator];
    }

    if (self.gravityBehavior) {
        [self.animator removeBehavior:self.gravityBehavior];
    }
    
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.circleView]];
//    CGVector vector = CGVectorMake(0.0, 1.0);
//    [self.gravityBehavior setGravityDirection:vector];
    [self.animator addBehavior:self.gravityBehavior];

}

- (void)addCollisionBehavior {
    if (!self.animator) {
        [self initAnimator];
    }
    if (self.collisionBehavior) {
        [self.animator removeBehavior:self.collisionBehavior];
    }
    
    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.circleView, self.bottomView]];
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    
    [self.animator addBehavior:self.collisionBehavior];
}

- (void)addCircleViewBehavior {
    if (!self.animator) {
        [self initAnimator];
    }
    
    if (self.circleViewBehavior) {
        [self.animator removeBehavior:self.circleViewBehavior];
    }
    
    self.circleViewBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.circleView]];
    self.circleViewBehavior.elasticity = 0.7;
    self.circleViewBehavior.friction = 1.0;
    self.circleViewBehavior.resistance = 0.0;
    self.circleViewBehavior.angularResistance = 0.0;
    self.circleViewBehavior.allowsRotation = YES;
    
    [self.animator addBehavior:self.circleViewBehavior];
}

- (void)addAttachmentBehavior {
    if (!self.animator) {
        [self initAnimator];
    }
    
    if (self.attachmentBehavior) {
        [self.animator removeBehavior:self.attachmentBehavior];
    }
    
    CGPoint point = CGPointMake(CGRectGetWidth(self.view.frame)/2, 200);
    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.circleView offsetFromCenter:UIOffsetMake(0, 0) attachedToAnchor:point];
    self.attachmentBehavior.length = 20.0;
    self.attachmentBehavior.damping = 0.0;
    
    [self.animator addBehavior:self.attachmentBehavior];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.isBeenInit) {
        LostPetRequest *lostPetRequest = [[LostPetRequest alloc] init];
        lostPetRequest.lostPetRequestDelegate = self;
        self.lostPetFilters = [[LostPetFilters alloc] init];
        self.lostPetFilters.variety = @"";
        self.lostPetFilters.gender = @"";
        [self.requests addObject:lostPetRequest];
        [lostPetRequest sendRequestForLostPetWithLostPetFilters:self.lostPetFilters top:@"20" skip:@"0"];
        
        self.lostPetStatus.loadingPageStatus = LoadingInitPage;
        
        [self startLoadingWithContent:@""];
        
        [UIView animateWithDuration:1.0 animations:^{
            self.adBannerView.alpha = 1.0;
        }];
        
        self.isBeenInit = YES;
    }
    
//    [self initDynamicAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearRequestSenderDelegate];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self clearRequestSenderDelegate];
    [super viewDidDisappear:animated];
}

- (void)clearRequestSenderDelegate {
    for (LostPetRequest *requestSender in self.requests) {
        requestSender.lostPetRequestDelegate = nil;
    }
    self.requests = [NSMutableArray array];
}

#pragma mark - LostPetRequestDelegate
- (void)lostPetResultBack:(NSArray *)lostPets {
    if ([lostPets count]) {
        self.lostPets = [NSArray arrayWithArray:lostPets];
    }
    
    if (self.lostPetStatus.loadingPageStatus == LoadingPreviousPage) {
        self.lostPetStatus.countOfCurrentTotal -= self.lostPetStatus.countOfCurrentPage;
        if (self.lostPetStatus.countOfCurrentTotal <= 20) {
            self.loadPreviousPageView.canLoading = NO;
        }
    } else if (self.lostPetStatus.loadingPageStatus == LoadingNextPage) {
        self.lostPetStatus.countOfCurrentTotal += [lostPets count];
    } else {
        self.lostPetStatus.countOfCurrentTotal += [lostPets count];
    }
    
    if ([lostPets count]) {
        self.lostPetStatus.countOfCurrentPage = [lostPets count];
        
        [self.pageIndicator setTitle:[self.lostPetStatus currentPage] forState:UIControlStateNormal];
        self.loadNextPageView.canLoading = YES;
        [self scrollToTop];
        if (self.lostPetStatus.loadingPageStatus == LoadingNextPage) {
            self.loadPreviousPageView.canLoading = YES;
        }
    } else {
        NSString *message = @"";
        
        if (self.lostPetStatus.loadingPageStatus == LoadingInitPage) {
            
            [self.pageIndicator setTitle:@"第1頁" forState:UIControlStateNormal];
            
            self.informationOnCell = kNodate;
            
            message = kNodate;
            
        } else if (self.lostPetStatus.loadingPageStatus == LoadingNextPage) {
            
            message = @"無下一頁";
            
        } else if (self.lostPetStatus.loadingPageStatus == LoadingPreviousPage) {
            
            message = @"無上一頁";
            self.loadPreviousPageView.canLoading = NO;
            
        }

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        self.loadNextPageView.canLoading = NO;
    }
    
    [self stopRotating:self.loadPreviousPageView.indicator];
    [self stopRotating:self.loadNextPageView.indicator];
    self.loadNextPageView.indicatorLabel.text = @"";
    
    self.isStartLoading = NO;
    
    [Utilities stopLoading];
    
    [self.tableView reloadData];
}

- (void)scrollToTop {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

#pragma mark - Methods
- (void)startLoadingWithContent:(NSString *)content {
    ((AppDelegate *)[Utilities getAppDelegate]).viewController = self;
    if (content && ![content isEqualToString:@""]) {
        [Utilities startLoadingWithContent:content];
    } else {
        [Utilities startLoading];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.lostPets count]) {
        return [self.lostPets count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ([self.lostPets count]) {
        
        LostPetListCell *lostPetListCell = [tableView dequeueReusableCellWithIdentifier:kLostPetListCell];
        LostPet *lostPet = [self.lostPets objectAtIndex:indexPath.row];
        
        lostPetListCell.chipNumber.text = lostPet.chipNumber;
        lostPetListCell.lostDate.text = lostPet.lostDate;
        lostPetListCell.lostPlace.text = lostPet.lostPlace;
        lostPetListCell.variety.text = lostPet.variety;
        lostPetListCell.hairColor.text = lostPet.hairColor;
        lostPetListCell.hairStyle.text = lostPet.hairStyle;
        lostPetListCell.describe.text = lostPet.characterized;
        cell = lostPetListCell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kNoDataCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNoDataCell];
        }
        NSDictionary *attributeDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor darkTextColor], NSForegroundColorAttributeName,
                                      [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:15.0], NSFontAttributeName, nil];
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.informationOnCell attributes:attributeDic];
        [cell.textLabel setAttributedText:attributeString];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.lostPets count]) {
        LostPetScrollViewController *lostPetScrollViewController = [[LostPetScrollViewController alloc] init];
        lostPetScrollViewController.lostPets = [NSMutableArray arrayWithArray:self.lostPets];
        lostPetScrollViewController.selectedIndexPath = indexPath;
        [self.navigationController pushViewController:lostPetScrollViewController animated:YES];
    }
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
            
            [self.loadPreviousPageView.indicatorLabel setAlpha:(0-offset.y)/100];
            
            CGFloat fontSize = 0.0;
            if (-offset.y > 30) {
                fontSize = (ABS(offset.y+30)/5 > 20)?20:ABS(offset.y+30)/5;
            } else {
                fontSize = 0.0;
            }
            [self.loadPreviousPageView.indicatorLabel setFont:[UIFont systemFontOfSize:fontSize]];
            
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
            
            CGFloat fontSize = ((y-h)/5 > 20)?20:(y-h)/5;
            [self.loadNextPageView.indicatorLabel setFont:[UIFont systemFontOfSize:fontSize]];
            
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
        if (offset.y <= -kReloadDistance-20 && self.loadPreviousPageView.canLoading && self.lostPetStatus.countOfCurrentTotal > 20) {
            
            [self rotateInfinitily:self.loadPreviousPageView.indicator];
            self.isStartLoading = YES;
            [self startLoadingWithContent:@"上一頁"];
            [self getPreviousPage];
            
        } else if (y > h + kReloadDistance && self.loadNextPageView.canLoading) {
            
            [self rotateInfinitily:self.loadNextPageView.indicator];
            self.isStartLoading = YES;
            [self startLoadingWithContent:@"下一頁"];
            [self getNextPage];
            
        }
    }
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

-(void)stopRotating:(UIView *)view{
    [view.layer removeAnimationForKey:@"rotationAnimation"];
}

- (void)getPreviousPage {
    self.lostPetStatus.loadingPageStatus = LoadingPreviousPage;
    LostPetRequest *lostPetRequest = [[LostPetRequest alloc] init];
    lostPetRequest.lostPetRequestDelegate = self;
    NSString *skip = [NSString stringWithFormat:@"%d",(int)(self.lostPetStatus.countOfCurrentTotal - self.lostPetStatus.countOfCurrentPage - self.lostPetStatus.top)];
    [lostPetRequest sendRequestForLostPetWithLostPetFilters:self.lostPetFilters top:@"20" skip:skip];
    [self.requests addObject:lostPetRequest];
}

- (void)getNextPage {
    self.lostPetStatus.loadingPageStatus = LoadingNextPage;
    LostPetRequest *lostPetRequest = [[LostPetRequest alloc] init];
    lostPetRequest.lostPetRequestDelegate = self;
    NSString *skip = [NSString stringWithFormat:@"%d",(int)self.lostPetStatus.countOfCurrentTotal];
    [lostPetRequest sendRequestForLostPetWithLostPetFilters:self.lostPetFilters top:@"20" skip:skip];
    [self.requests addObject:lostPetRequest];
}

- (IBAction)panInView:(UIPanGestureRecognizer *)recognizer {
    self.menuTransition.isInteraction = YES;
    
    CGFloat percentageY = [recognizer translationInView:self.view.superview].y / self.view.superview.bounds.size.height;
    NSLog(@"percentageY:%.2f",[recognizer velocityInView:recognizer.view.superview].y);
    
    if (percentageY < 0) {
        self.adBannerView.alpha = 1 + percentageY * 2;
    } else {
        self.adBannerView.alpha = self.adBannerView.alpha + percentageY * 2;
    }
    
    self.currentLocation = [recognizer translationInView:self.view];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (percentageY < 0){
            self.menuTransition.direction = DirectionUp;
            [self goToMenu:nil];
        }
        
//        [self.animator removeAllBehaviors];
    }
    
    if (self.menuTransition.direction == DirectionUp) {
        CGFloat percentage = -percentageY;
        [self.menuTransition updateInteractiveTransition:percentage];
    }
    
//    CGPoint point = [recognizer locationInView:self.view];
//    if (CGRectContainsPoint(self.circleView.frame, point)) {
//        self.circleView.center = point;
//        NSLog(@"x:%.2f, y:%.2f",self.circleView.frame.origin.x, self.circleView.frame.origin.y);
//    }
//    self.attachment.anchorPoint = self.currentLocation;
    
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled ||
        recognizer.state == UIGestureRecognizerStateFailed
        ) {
        
        CGFloat velocityY = [recognizer velocityInView:recognizer.view.superview].y;
        BOOL cancel = YES;
        CGFloat points;
        NSTimeInterval duration;

        if (self.menuTransition.direction == DirectionUp) {
            cancel = (percentageY > -kThreshold) || (velocityY > 0);
            points = cancel ? recognizer.view.frame.origin.y : self.view.superview.bounds.size.height - recognizer.view.frame.origin.y;
            duration = points / velocityY;
        }
        
        if (duration < .2) {
            duration = .2;
        }else if(duration > .6){
            duration = .6;
        }
        
        if (recognizer.state == UIGestureRecognizerStateFailed) {
            [self.menuTransition cancelInteractiveTransitionWithDuration:.35];
        } else {
            cancel?[self.menuTransition cancelInteractiveTransitionWithDuration:duration]:[self.menuTransition finishInteractiveTransitionWithDuration:duration];
        }
        
//        [self addGravityBehavior];
//        [self addCollisionBehavior];
//        [self addCircleViewBehavior];
        
        self.adBannerView.alpha = cancel ? 1 : 0;
    }
    
//    NSLog(@"self.adBannerView.alpha:%.2f",self.adBannerView.alpha);
}

- (IBAction)clickSearch:(UIBarButtonItem *)sender {
    LostPetSearchViewController *searchViewController = [[LostPetSearchViewController alloc] initWithNibName:@"LostPetSearchViewController" bundle:nil];
    searchViewController.lostPetFilters = [[LostPetFilters alloc] initWithLostPetFilters:self.lostPetFilters];
    searchViewController.delegate = self;
    [self presentViewController:searchViewController animated:YES completion:nil];
}

#pragma mark - LostPetSearchViewControllerDelegate
- (void)processSearchWithFilters:(LostPetFilters *)lostPetFilters {
    self.lostPets = [NSMutableArray array];
    self.informationOnCell = kLoading;
    [self.tableView reloadData];
    
    self.lostPetFilters = [[LostPetFilters alloc] initWithLostPetFilters:lostPetFilters];
    LostPetRequest *lostPetRequest = [[LostPetRequest alloc] init];
    lostPetRequest.lostPetRequestDelegate = self;
    [self.requests addObject:lostPetRequest];
    [lostPetRequest sendRequestForLostPetWithLostPetFilters:self.lostPetFilters top:@"20" skip:@"0"];
    
    self.lostPetStatus = [[LostPetStatus alloc] init];
    
    self.lostPetStatus.loadingPageStatus = LoadingInitPage;
    
    [self startLoadingWithContent:@""];
}
@end
