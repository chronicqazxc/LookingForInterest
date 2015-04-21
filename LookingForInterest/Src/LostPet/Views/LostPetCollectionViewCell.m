//
//  LostPetCollectionViewCell.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/20/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetCollectionViewCell.h"
#import <WebKit/WebKit.h>

@implementation LostPetCollectionViewCell

- (void)awakeFromNib {
    
    CGFloat leadingSpace = self.webContainerLeadingSpaceConstraint.constant;
    CGFloat trailingSpace = self.webContainerTrailingSpaceConstraint.constant;
    CGFloat height = self.webViewContainerHeightConstraint.constant;
    CGSize size = CGSizeMake([Utilities getScreenSize].width-leadingSpace-trailingSpace, height);
    size = CGSizeMake([Utilities getScreenSize].width-20, 200);
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,0,size.width,size.height)];
    [self.webViewContainer addSubview:self.webView];
}

@end
