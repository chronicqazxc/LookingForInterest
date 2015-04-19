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
#import "LostPetTransition.h"
#import "TableLoadPreviousPage.h"
#import "TableLoadNextPage.h"
#import "GoTopButton.h"

#define kReloadDistance 100
#define kSpringTreshold 130
#define kThreshold 0.30

#define kLostPetListCell @"LostPetListCell"
#define kToMenuSegueIdentifier @"ToMenuSegueIdentifier"

@interface LostPetViewController () <LostPetRequestDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *lostPets;
@property (strong, nonatomic) LostPetTransition *transitionManager;
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
    
    self.lostPetStatus = [[LostPetStatus alloc] init];
    
    [self initNavigationBar];
    
    [self initLoadingPageView];
    
    self.transitionManager = [[LostPetTransition alloc] init];
    
//    [self initDynamicAnimation];
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

- (void)goToMenu {
    UIStoryboard *firstStoryboard = [UIStoryboard storyboardWithName:kFirstStoryboard bundle:nil];
    MenuViewController *controller = (MenuViewController *)[firstStoryboard instantiateViewControllerWithIdentifier:kMenuStoryboardID];
    controller.transitioningDelegate = self.transitionManager;
    [self presentViewController:controller animated:NO completion:nil];
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
    
    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.circleView]];
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
    
    LostPetRequest *lostPetRequest = [[LostPetRequest alloc] init];
    lostPetRequest.lostPetRequestDelegate = self;
    LostPetFilters *lostPetFilters = [[LostPetFilters alloc] init];
    lostPetFilters.variety = @"";
    lostPetFilters.gender = @"";
    [self.requests addObject:lostPetRequest];
    [lostPetRequest sendRequestForLostPetWithLostPetFilters:lostPetFilters top:@"20" skip:@"0"];
    
    self.lostPetStatus.loadingPageStatus = LoadingInitPage;
    
    [self startLoadingWithContent:@""];
    
    [self initDynamicAnimation];
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
    self.lostPets = [NSArray arrayWithArray:lostPets];
    
    if (self.lostPetStatus.loadingPageStatus == LoadingPreviousPage) {
        self.lostPetStatus.countOfCurrentTotal -= self.lostPetStatus.countOfCurrentPage;
        if (self.lostPetStatus.countOfCurrentPage == 20) {
            self.loadPreviousPageView.canLoading = NO;
        }
    } else if (self.lostPetStatus.loadingPageStatus == LoadingNextPage) {
        self.lostPetStatus.countOfCurrentTotal += [self.lostPets count];
    } else {
        self.lostPetStatus.countOfCurrentTotal += [self.lostPets count];
    }
    self.lostPetStatus.countOfCurrentPage = [self.lostPets count];
    
    if ([self.lostPets count]) {
        [self.pageIndicator setTitle:[self.lostPetStatus currentPage] forState:UIControlStateNormal];
        self.loadNextPageView.canLoading = YES;
        [self.tableView reloadData];
        [self scrollToTop];
        if (self.lostPetStatus.loadingPageStatus == LoadingNextPage) {
            self.loadPreviousPageView.canLoading = YES;
        }
    } else {
        NSString *message = @"";
        if (self.lostPetStatus.loadingPageStatus == LoadingNextPage) {
            message = @"無下一頁";
            [self.pageIndicator setTitle:@"第1頁" forState:UIControlStateNormal];
            self.loadNextPageView.canLoading = NO;
        } else if (self.lostPetStatus.loadingPageStatus == LoadingPreviousPage) {
            message = @"無上一頁";
            self.loadPreviousPageView.canLoading = NO;
        } else {
            message = @"查無資料";
        }

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:cancelAction];
        
        self.loadNextPageView.canLoading = NO;
    }
    
    [self stopRotating:self.loadPreviousPageView.indicator];
    [self stopRotating:self.loadNextPageView.indicator];
    self.loadNextPageView.indicatorLabel.text = @"";
    
    self.isStartLoading = NO;
    
    [Utilities stopLoading];
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
    LostPetFilters *lostPetFilters = [[LostPetFilters alloc] init];
    NSString *skip = [NSString stringWithFormat:@"%d",(int)(self.lostPetStatus.countOfCurrentTotal - self.lostPetStatus.countOfCurrentPage - self.lostPetStatus.top)];
    [lostPetRequest sendRequestForLostPetWithLostPetFilters:lostPetFilters top:@"20" skip:skip];
    [self.requests addObject:lostPetRequest];
}

- (void)getNextPage {
    self.lostPetStatus.loadingPageStatus = LoadingNextPage;
    LostPetRequest *lostPetRequest = [[LostPetRequest alloc] init];
    lostPetRequest.lostPetRequestDelegate = self;
    LostPetFilters *lostPetFilters = [[LostPetFilters alloc] init];
    NSString *skip = [NSString stringWithFormat:@"%d",(int)self.lostPetStatus.countOfCurrentTotal];
    [lostPetRequest sendRequestForLostPetWithLostPetFilters:lostPetFilters top:@"20" skip:skip];
    [self.requests addObject:lostPetRequest];
}

- (IBAction)panInView:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint point = [recognizer locationInView:self.view];
    self.currentLocation = [recognizer translationInView:self.view];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
//        UIOffset offset = UIOffsetMake(0, 0);
//        self.attachment = [[UIAttachmentBehavior alloc] initWithItem:self.circleView offsetFromCenter:offset attachedToAnchor:self.currentLocation];
//        
//        [self.animator addBehavior:self.attachmqent];
        
        [self.animator removeAllBehaviors];
    }
    if (CGRectContainsPoint(self.circleView.frame, point)) {
        self.circleView.center = point;
        NSLog(@"x:%.2f, y:%.2f",self.circleView.frame.origin.x, self.circleView.frame.origin.y);
    } else {
        NSLog(@"x:%.2f, y:%.2f",self.circleView.frame.origin.x, self.circleView.frame.origin.y);
        NSLog(@"current x:%.2f, y:%.2f",point.x, point.y);
    }
//    self.attachment.anchorPoint = self.currentLocation;
    
    
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled ||
        recognizer.state == UIGestureRecognizerStateFailed
        ) {
        [self addGravityBehavior];
        [self addCollisionBehavior];
        [self addCircleViewBehavior];
    }
}
@end
