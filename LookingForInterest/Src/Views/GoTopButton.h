//
//  GoTopButton.h
//  Chinatrust
//
//  Created by Wayne on 6/6/14.
//
//

#import <UIKit/UIKit.h>

@protocol GoTopButtonDelegate;

@interface GoTopButton : UIButton
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) id <GoTopButtonDelegate, UITableViewDelegate, UITableViewDataSource> delegate;
@property (nonatomic) NSInteger conditionForShow;
- (void)scrollToTop;
@end

@protocol GoTopButtonDelegate <NSObject>
- (void)goTopButtonBeClicked;
@end

