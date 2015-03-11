//
//  GoTopButton.m
//  Chinatrust
//
//  Created by Wayne on 6/6/14.
//
//

#import "GoTopButton.h"

@interface GoTopButton() <UITableViewDelegate, UITableViewDataSource>

@end

@implementation GoTopButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setTitleColor:UIColorFromRGB(0x006666) forState:UIControlStateNormal];
        [self setTitle:@"Top↑" forState:UIControlStateNormal];
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3.0;
        self.hidden = NO;
        self.alpha = 0.0;
        self.conditionForShow = 0;
        [self addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = frame;
        self.frame = CGRectMake(0, 0, 60, 30);
        [self setTitleColor:UIColorFromRGB(0x006666) forState:UIControlStateNormal];
        self.center = CGPointMake(rect.size.width/2.0, rect.size.height);
        [self setTitle:@"Top↑" forState:UIControlStateNormal];
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3.0;
        self.hidden = NO;
        self.alpha = 0.0;
        self.conditionForShow = 0;
        [self addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.center = CGPointMake(self.center.x, tableView.frame.origin.y+10);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
}

- (void)buttonClicked {
    if (self.delegate && [self.delegate respondsToSelector:@selector(goTopButtonBeClicked)]) {
        [self.delegate goTopButtonBeClicked];
    }
}

- (void)scrollToTop {
    [self.tableView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.delegate tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showButtonWithNumber:indexPath.row];
    return [self.delegate tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        NSArray *visible = [self.tableView indexPathsForVisibleRows];
        
        NSIndexPath *lastIndexpath = (NSIndexPath*)[visible lastObject];
        NSIndexPath *firstIndexpath = (NSIndexPath*)[visible firstObject];
        [self showButtonWithNumber:firstIndexpath.row];
        [self showButtonWithNumber:lastIndexpath.row];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSArray *visible = [self.tableView indexPathsForVisibleRows];
    
    NSIndexPath *lastIndexpath = (NSIndexPath*)[visible lastObject];
    NSIndexPath *firstIndexpath = (NSIndexPath*)[visible firstObject];
    [self showButtonWithNumber:firstIndexpath.row];    
    [self showButtonWithNumber:lastIndexpath.row];
}

#pragma mark -
- (void)showButtonWithNumber:(NSInteger)number {
    if (number >= self.conditionForShow) {
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 0.0;
        }];
    }
}
@end
