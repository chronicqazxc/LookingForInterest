//
//  EndlessScrollGenerator.m
//  ScrollAndZoomingView
//
//  Created by Wayne on 1/21/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "EndlessScrollGenerator.h"

#define kIntervalOfMovieRotator 1
#define kNumberForStartRotate 3

@interface EndlessScrollGenerator() <UIScrollViewDelegate>
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIViewController <UIScrollViewDelegate, EndlessScrollGeneratorDelegate> *viewController;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (nonatomic) NSUInteger selectionDataIndex;
@property (nonatomic) float pageSize;
@property (strong, nonatomic) NSTimer *movieRotatorTimer;
@property (strong, nonatomic) NSTimer *startRotateTimer;
@property (nonatomic) NSUInteger countDownForStartRotate; //!@#
@end

@implementation EndlessScrollGenerator
- (id)initWithScrollViewContainer:(UIViewController <UIScrollViewDelegate, EndlessScrollGeneratorDelegate> *)viewController {
    self = [super init];
    if (self) {
        self.viewController = viewController;
        self.dataArray = [NSMutableArray array];
        self.movieRotatorTimer = [NSTimer scheduledTimerWithTimeInterval:kIntervalOfMovieRotator target:self selector:@selector(rotateMovie:) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)setUpScrollView:(UIScrollView *)scrollView {
    self.scrollView = scrollView;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.pageSize = self.scrollView.frame.size.width;
    [self scrollToPage:1 withAnimation:NO];
}

- (NSMutableArray *)setUpData:(NSMutableArray *)originalArray {
    self.dataArray = [NSMutableArray arrayWithArray:originalArray];
    id firstItem = [[UIImageView alloc]initWithImage:[self.dataArray[0] image]];
    id lastItem = [[UIImageView alloc] initWithImage:[[self.dataArray lastObject] image]];
    
    NSMutableArray *workingArray = [NSMutableArray arrayWithArray:self.dataArray];
    [workingArray insertObject:lastItem atIndex:0];
    [workingArray addObject:firstItem];
    self.dataArray = [NSMutableArray arrayWithArray:workingArray];
    NSMutableArray *returnData = [NSMutableArray arrayWithArray:self.dataArray];
    return returnData;
}

- (void)startPaging {
    self.selectionDataIndex = 1;
    self.startRotateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countForStartRotate:) userInfo:nil repeats:YES];
//    [self determinePageWhetherIsManulSwipe:NO];
}

- (void)rotateMovie:(NSTimer *)timer {
    if (self.countDownForStartRotate == kNumberForStartRotate) {
        [self determinePageWhetherIsManulSwipe:NO];
    }
}

- (void)countForStartRotate:(NSTimer *)timer {
    self.countDownForStartRotate = (self.countDownForStartRotate >= kNumberForStartRotate)?kNumberForStartRotate:self.countDownForStartRotate+1;
}

- (void)determinePageWhetherIsManulSwipe:(BOOL)isManualSwipe {
    float contentOffsetWhenFullyScrolledRight = self.scrollView.frame.size.width * ([self.dataArray count] -1);
    
    if (self.scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight) {
        self.selectionDataIndex = 1;
        [self scrollToPage:self.selectionDataIndex withAnimation:NO];
        
    } else if (self.scrollView.contentOffset.x == 0)  {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.dataArray count] -2) inSection:0];
        self.selectionDataIndex = newIndexPath.row;
        [self scrollToPage:newIndexPath.row withAnimation:NO];
    } else if (!isManualSwipe) {
        self.selectionDataIndex++;
        [self nextPageNotify];
    }
}

- (void)nextPageNotify
{
    if ([self.viewController respondsToSelector:@selector(nextPageNotify)]) {
        [self.viewController nextPageNotify];
    }
    if (self.selectionDataIndex > [self.dataArray count]-1) {
        self.selectionDataIndex = 1;
        [self scrollToPage:self.selectionDataIndex withAnimation:NO];
    } else {
        [self scrollToPage:self.selectionDataIndex withAnimation:YES];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollview {
    [self stopPaging];
    [self.viewController scrollViewDidEndDecelerating:self.scrollView];
    [self determinePageWhetherIsManulSwipe:YES];
    self.startRotateTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(startPaging) userInfo:nil repeats:NO];
    
}

- (void)stopPaging {
    [self.startRotateTimer invalidate];
    self.countDownForStartRotate = 0;
}

- (void)scrollToPage:(NSUInteger)pageNumber withAnimation:(BOOL)animation{
    if (pageNumber <= [self.dataArray count]-1) {
        [self.scrollView setContentOffset:CGPointMake(self.pageSize * pageNumber, 0) animated:animation];
    }
}
@end
