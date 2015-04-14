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

@interface MenuViewController () <ADBannerViewDelegate, FBLoginViewDelegate, ManulViewControllerDelegate>
@property (nonatomic) BOOL isInitial;
@property (nonatomic) BOOL isViewDidAppear;
@property (weak, nonatomic) IBOutlet DialingButton *adoptButton;
@property (weak, nonatomic) IBOutlet DialingButton *animalHospitalButton;
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
    self.profilePictureView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.7].CGColor;
    self.profilePictureView.layer.borderWidth = 1.0;
    self.profilePictureView.layer.masksToBounds = YES;
    
    self.titleLabel.alpha = 0.0;
    self.loginView.alpha = 0.0;
    
    self.adoptButton.hidden = NO;
    self.animalHospitalButton.hidden = NO;
    self.profilePictureView.hidden = NO;
    
    self.profilePictureView.center = self.view.center;
    self.adoptButton.center = self.view.center;
    self.animalHospitalButton.center = self.view.center;
    
    [UIView animateWithDuration:1.0 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.adoptButton.frame = CGRectOffset(self.adoptButton.frame, -100, 10);
        self.animalHospitalButton.frame = CGRectOffset(self.animalHospitalButton.frame, 100, 10);
        self.profilePictureView.frame = CGRectOffset(self.profilePictureView.frame, 0, -100);
    } completion:^(BOOL finished) {
        self.titleLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame),
                                           CGRectGetMinY(self.profilePictureView.frame)-50,
                                           CGRectGetWidth(self.titleLabel.frame),
                                           CGRectGetHeight(self.titleLabel.frame));
        [UIView animateWithDuration:1.0 animations:^{
            self.titleLabel.alpha = 1.0;
            self.loginView.alpha = 1.0;
            self.nameLabel.alpha = 1.0;
            self.nameLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame),
                                              CGRectGetMaxY(self.profilePictureView.frame)+5,
                                              CGRectGetWidth(self.nameLabel.frame),
                                              CGRectGetHeight(self.nameLabel.frame));
        }];
    }];
}

- (void)initCircleView:(UIView *)view {
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = CGRectGetHeight(view.frame)/2.0;
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
- (IBAction)goToLostPet:(UIButton *)sender {
    UIStoryboard *secondStoryboard = [UIStoryboard storyboardWithName:kSecondStoryboard bundle:nil];
    LostPetViewController *lostPetViewController = (LostPetViewController *)[secondStoryboard instantiateViewControllerWithIdentifier:kLostPetStoryboardID];
    [self presentViewController:lostPetViewController animated:YES completion:nil];
    
    
}
@end
