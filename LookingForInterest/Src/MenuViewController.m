//
//  MenuViewController.m
//  LookingForInterest
//
//  Created by Wayne on 3/3/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "MenuViewController.h"
#import "DialingButton.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ManulMenuViewController.h"
#import "LostPetViewController.h"
#import <iAd/iAd.h>

#define kAnimationKeyAdoptAnimal @"AdoptAnimal"
#define kAnimationKeyAnimalHospital @"AnimalHospital"
#define kAnimationKeyLostPet @"LostPet"

@interface MenuViewController () <ADBannerViewDelegate, FBLoginViewDelegate, ManulViewControllerDelegate>
@property (nonatomic) BOOL isInitial;
@property (nonatomic) BOOL isViewDidAppear;
@property (weak, nonatomic) IBOutlet DialingButton *adoptButton;
@property (weak, nonatomic) IBOutlet DialingButton *animalHospitalButton;
@property (weak, nonatomic) IBOutlet DialingButton *lostPetButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) ManulMenuViewController *manulMenuViewController;
@property (nonatomic) BOOL hadShowManul;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *effectView;
@property (weak, nonatomic) IBOutlet ADBannerView *adBannerView;
- (IBAction)goToLostPet:(UIButton *)sender;
- (IBAction)panInView:(UIPanGestureRecognizer *)recognizer;
@end

@implementation MenuViewController
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isInitial = NO;
        self.isViewDidAppear = NO;
        self.hadShowManul = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[Utilities getAppDelegate] setViewController:self];
    self.loginView.delegate = self;
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    self.adoptButton.hidden = YES;
    self.animalHospitalButton.hidden = YES;
    self.profilePictureView.hidden = YES;
    self.lostPetButton.hidden = YES;
    
    self.titleLabel.alpha = 0.0;
    self.loginView.alpha = 0.0;
    self.nameLabel.alpha = 0.0;
    self.nameLabel.text = @"";
    self.adBannerView.delegate = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        UIImage *image = [UIImage imageNamed:@"blur_background.JPG"];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            self.backgroundImageView.image = image;
            self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        });
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isViewDidAppear = YES;
    [self viewDidLayoutSubviews];
    
    if (![Utilities getNeverShowManulMenuWithKey:kManulMenuKey]) {
        if (!self.hadShowManul) {
            self.manulMenuViewController = [[ManulMenuViewController alloc] initWithNibName:@"ManulViewController" bundle:nil];
            self.manulMenuViewController.delegate = self;
            [self presentViewController:self.manulMenuViewController animated:YES completion:nil];
        }
    } else {
        if ([[Utilities getAppDelegate] accessToken] == nil) {
            [[Utilities getAppDelegate] setViewController:self];
            [Utilities startLoadingWithContent:@"準備資料中..."];
            [[Utilities getAppDelegate] resendAccessTokenRequest];
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.isViewDidAppear && !self.isInitial) {
        [self initButtons];
        self.isInitial = YES;
    }
}

- (void)initButtons {
    [self initCircleView:self.adoptButton];
    [self initCircleView:self.animalHospitalButton];
    [self initCircleView:self.profilePictureView];
    [self initCircleView:self.lostPetButton];
    
    self.adoptButton.hidden = NO;
    self.animalHospitalButton.hidden = NO;
    self.profilePictureView.hidden = NO;
    self.lostPetButton.hidden = NO;
    
    self.profilePictureView.center = self.view.center;
    self.adoptButton.center = self.view.center;
    self.animalHospitalButton.center = self.view.center;
    self.lostPetButton.center = self.view.center;
    
    self.profilePictureView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.7].CGColor;
    self.profilePictureView.layer.borderWidth = 1.0;
    self.profilePictureView.layer.masksToBounds = YES;
    
    self.titleLabel.alpha = 0.0;
    self.loginView.alpha = 0.0;
    
    [self animation];
}

- (void)initCircleView:(UIView *)view {
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = CGRectGetHeight(view.frame)/2.0;
}

- (void)animation {
    
    [self.view bringSubviewToFront:self.profilePictureView];
    
    [self.adoptButton setTitle:@"" forState:UIControlStateNormal];
    [self.animalHospitalButton setTitle:@"" forState:UIControlStateNormal];
    [self.lostPetButton setTitle:@"" forState:UIControlStateNormal];
    
    CAKeyframeAnimation *adoptButtonAnimation = [self generateCAKeyframeAnimationWithPath:[self generateUIBezierPathWithStartPoint:self.adoptButton.center endDegress:540 radius:5].CGPath];
    [self.adoptButton.layer addAnimation:adoptButtonAnimation forKey:kAnimationKeyAdoptAnimal];
    
    CAKeyframeAnimation *animalHospitalAnimation = [self generateCAKeyframeAnimationWithPath:[self generateUIBezierPathWithStartPoint:self.animalHospitalButton.center endDegress:360 radius:3.3].CGPath];
    [self.animalHospitalButton.layer addAnimation:animalHospitalAnimation forKey:kAnimationKeyAnimalHospital];
    
    CAKeyframeAnimation *lostPetAnimation = [self generateCAKeyframeAnimationWithPath:[self generateUIBezierPathWithStartPoint:self.lostPetButton.center endDegress:270 radius:2.5].CGPath];
    [self.lostPetButton.layer addAnimation:lostPetAnimation forKey:kAnimationKeyLostPet];
}

- (UIBezierPath *)generateUIBezierPathWithStartPoint:(CGPoint)startPoint endDegress:(CGFloat)end radius:(CGFloat)radius{
    UIBezierPath *trackPath = [UIBezierPath bezierPath];
    [trackPath moveToPoint:startPoint];
    for (int i=0; i<end; i++) {
        [trackPath addArcWithCenter:self.view.center radius:i/radius startAngle:degreesToRadians(i) endAngle:degreesToRadians(i) clockwise:NO];
    }
    return trackPath;
}

- (CAKeyframeAnimation *)generateCAKeyframeAnimationWithPath:(CGPathRef)trackPath {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    anim.path = trackPath;
    anim.rotationMode = kCAAnimationRotateAuto;
    anim.repeatCount = 0;//HUGE_VALF;
    anim.duration = 3.0;
    anim.delegate = self;
    anim.removedOnCompletion = NO;
    return anim;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    CGPoint point = CGPathGetCurrentPoint(((CAKeyframeAnimation *)anim).path);
    
    CAKeyframeAnimation *adoptAnimalAnimation = (CAKeyframeAnimation *)[self.adoptButton.layer animationForKey:kAnimationKeyAdoptAnimal];
    CAKeyframeAnimation *animalHospitalAnimation = (CAKeyframeAnimation *)[self.animalHospitalButton.layer animationForKey:kAnimationKeyAnimalHospital];
    CAKeyframeAnimation *lostPetAnimation = (CAKeyframeAnimation *)[self.lostPetButton.layer animationForKey:kAnimationKeyLostPet];
    
    if (anim == adoptAnimalAnimation) {
        self.adoptButton.center = point;
        [self.adoptButton.layer removeAllAnimations];
    } else if (anim == animalHospitalAnimation) {
        self.animalHospitalButton.center = point;
        [self.animalHospitalButton.layer removeAllAnimations];
    } else if (anim == lostPetAnimation) {
        self.lostPetButton.center = point;
        [self.lostPetButton.layer removeAllAnimations];
    }
 
    if ([self.adoptButton.layer animationKeys] == nil &&
        [self.animalHospitalButton.layer animationKeys] == nil &&
        [self.lostPetButton.layer animationKeys] == nil &&
        [self.loginView.layer animationKeys] == nil) {
        
        self.loginView.frame = CGRectMake(CGRectGetMinX(self.loginView.frame),
                                          self.view.center.y,
                                          CGRectGetWidth(self.loginView.frame),
                                          CGRectGetHeight(self.loginView.frame));
        
        [UIView animateWithDuration:1.0 animations:^{
            self.titleLabel.alpha = 1.0;
            self.loginView.alpha = 1.0;
            self.nameLabel.alpha = 1.0;
            self.nameLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame),
                                              CGRectGetMaxY(self.profilePictureView.frame)+5,
                                              CGRectGetWidth(self.nameLabel.frame),
                                              CGRectGetHeight(self.nameLabel.frame));
            
            self.titleLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame),
                                               CGRectGetMinY(self.lostPetButton.frame)-50,
                                               CGRectGetWidth(self.titleLabel.frame),
                                               CGRectGetHeight(self.titleLabel.frame));
            
            self.loginView.frame = CGRectMake(CGRectGetMinX(self.loginView.frame),
                                              CGRectGetMaxY(self.adoptButton.frame)+50,
                                              CGRectGetWidth(self.loginView.frame),
                                              CGRectGetHeight(self.loginView.frame));
            
            [self.adoptButton setTitle:@"我要領養" forState:UIControlStateNormal];
            [self.animalHospitalButton setTitle:@"找醫院" forState:UIControlStateNormal];
            [self.lostPetButton setTitle:@"走失寵物" forState:UIControlStateNormal];
        }];
    }
}

- (void)rotateView:(UIView *)view {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 2.0);
    CGFloat SunRotationAnimationDuration = 0.9f;
    rotationAnimation.duration = SunRotationAnimationDuration;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - FBLoginViewDelegate
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    self.profilePictureView.profileID = user.objectID;
    self.nameLabel.text = user.name;
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.profilePictureView.profileID = nil;
    self.nameLabel.text = @"";
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user performs an action outside of you app to recover,
    // the SDK provides a message, you just need to surface it.
    // This handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpted error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - ManulViewControllerDelegate
- (void)manulConfirmClicked {
    [self.manulMenuViewController dismissViewControllerAnimated:YES completion:nil];
    self.hadShowManul = YES;
    if (self.manulMenuViewController.neverShowSwitch.on) {
        [Utilities setNeverShowManulMenuWithKey:kManulMenuKey];
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

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self layoutAnimated:YES];
}

- (void)layoutAnimated:(BOOL)animated
{
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


- (void)bannerViewWillLoadAd:(ADBannerView *)banner {
    
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self layoutAnimated:YES];
}

- (void)checkSystemVersion {
    if ([[Utilities appdelegate] systemVersion] && ![[[Utilities appdelegate] systemVersion] isEqualToString:@""]) {
        NSString *latestVersion = [[Utilities appdelegate] systemVersion];
       
        NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
        NSString *version = infoDictionary[@"CFBundleShortVersionString"];
        
        if ([version compare:latestVersion] == NSOrderedAscending) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"新版本%@通知",((AppDelegate *)[Utilities appdelegate]).systemVersion] message:((AppDelegate *)[Utilities appdelegate]).versionNote preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"馬上下載" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *appURL = @"http://appstore.com/關心毛小孩";
                appURL = [appURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL]];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"暫時不用" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertController addAction:action];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

#pragma mark -
- (IBAction)goToLostPet:(UIButton *)sender {
    UIStoryboard *secondStoryboard = [UIStoryboard storyboardWithName:kSecondStoryboard bundle:nil];
    UINavigationController *controller = (UINavigationController *)[secondStoryboard instantiateViewControllerWithIdentifier:kLostPetNavigationControllerStoryboardID];
    [self presentViewController:controller animated:YES completion:nil];
    
    
}

#pragma mark - Animation
- (IBAction)panInView:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    if (CGRectContainsPoint(self.adoptButton.frame, location)) {
        [self swipAnimationWithView:self.adoptButton value:velocity.x/100];
    }
    if (CGRectContainsPoint(self.animalHospitalButton.frame, location)) {
        [self swipAnimationWithView:self.animalHospitalButton value:velocity.x/100];
    }
    if (CGRectContainsPoint(self.lostPetButton.frame, location)) {
        [self swipAnimationWithView:self.lostPetButton value:velocity.x/100];
    }
}

- (void)swipAnimationWithView:(UIView *)view value:(CGFloat)value{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotationAnimation.toValue = @((M_PI * 2.0)*value);
    CGFloat SunRotationAnimationDuration = 1.0f;
    rotationAnimation.duration = SunRotationAnimationDuration;
    rotationAnimation.autoreverses = YES;
    rotationAnimation.repeatCount = 0;//HUGE_VALF;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
@end
