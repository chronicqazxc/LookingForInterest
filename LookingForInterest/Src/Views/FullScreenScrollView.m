//
//  FullScreenScrollView.m
//  CTBMobileBank
//
//  Created by Wayne on 11/20/14.
//
//

#import "FullScreenScrollView.h"

@interface FullScreenScrollView()
@property (nonatomic) int page;
@property (nonatomic) CGFloat maxZoomingScale;
@end

@implementation FullScreenScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithImageViews:(NSArray *)imageViews withFrame:(CGRect)rect minzoomingScale:(CGFloat)minScale maxzoomingScale:(CGFloat)maxScale delegate:(id)delegate{
    self = [super init];
    if (self) {
        self.maxZoomingScale = maxScale;
        self.fullScreenScrollDelegate = delegate;
        self.delegate = self;
        self.scrollEnabled = YES;
        self.pagingEnabled = YES;
        self.frame = CGRectMake(rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
        self.contentSize = CGSizeMake(rect.size.width*[imageViews count], rect.size.height);
        for (int i=0; i<[imageViews count]; i++) {
            UIImageView *imageView = [imageViews objectAtIndex:i];
            imageView.frame = CGRectMake(0,0,rect.size.width,rect.size.height);
            UIScrollView *zoomingScrollView = [UIScrollView new];
            if (i==0) {
                zoomingScrollView.frame = CGRectOffset(imageView.frame,0,0);
            } else {
                zoomingScrollView.frame = CGRectOffset(imageView.frame,
                                                       rect.size.width*i,
                                                       0);
            }
            zoomingScrollView.contentSize = CGSizeMake(rect.size.width, rect.size.height);
            zoomingScrollView.delegate = self;
            zoomingScrollView.minimumZoomScale = minScale;
            zoomingScrollView.maximumZoomScale = maxScale;
            [zoomingScrollView addSubview:imageView];
            [self addSubview:zoomingScrollView];
        }
    }
    return self;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIImageView *barcodeView = [scrollView.subviews firstObject];
    return barcodeView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.page = (page == 3)?2:page;
    [self.fullScreenScrollDelegate pageChanged:self.page];
    for (int i=0; i<[self.subviews count]; i++) {
        if (i != self.page && [[self.subviews objectAtIndex:i] isKindOfClass:[UIScrollView class]]) {
            UIScrollView *disapperScrollView = [self.subviews objectAtIndex:i];
            [disapperScrollView setZoomScale:self.maximumZoomScale animated:YES];
        }
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews firstObject];
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

@end
