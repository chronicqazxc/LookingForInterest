//
//  LostPetCollectionViewCell.h
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/20/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#define kLostPetCollectionViewCellIdentifier @"LostPetCollectionViewCell"

@interface LostPetCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *webViewContainer;
@property (strong, nonatomic) WKWebView *webView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webContainerTrailingSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webContainerLeadingSpaceConstraint;
@end
