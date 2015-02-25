//
//  FullScreenScrollView.h
//  CTBMobileBank
//
//  Created by Wayne on 11/20/14.
//
//

#import <UIKit/UIKit.h>

@protocol FullScreenScrollViewDelegate;

@interface FullScreenScrollView : UIScrollView <UIScrollViewDelegate>
- (id)initWithImageViews:(NSArray *)imageViews withFrame:(CGRect)rect minzoomingScale:(CGFloat)minScale maxzoomingScale:(CGFloat)maxScale delegate:(id)delegate;
@property(nonatomic,assign) id<FullScreenScrollViewDelegate, UIScrollViewDelegate> fullScreenScrollDelegate;
@end

@protocol FullScreenScrollViewDelegate <NSObject>
/*!換頁時會被呼叫*/
- (void)pageChanged:(int)currentPage;

@end
