//
//  ExpandContractController.h
//  ExpandContractTable
//
//  Created by Wayne on 11/21/14.
//  Copyright (c) 2014 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ExpandContractControllerDelegate;

@interface ExpandContractController : NSObject
/*!step1*/
- (id)initWithDelegate:(id)delegate tableView:(UITableView *)tableView;
/*!step2*/
- (void)setNumberOfSection:(int)number dataArray:(NSMutableArray *)dataArr controlArray:(NSMutableArray *)controlArr;
/*!step3*/
- (void)setNumberOfParent:(int)number andHeigh:(NSString *)heigh section:(int)section dataArray:(NSMutableArray *)dataArr controlArray:(NSMutableArray *)controlArr;
/*!step4*/
- (void)setNumberOfChild:(NSString *)number andHeigh:(NSString *)heigh section:(int)section withParentIndex:(int)parentIndex dataArray:(NSMutableArray *)dataArr controlArray:(NSMutableArray *)controlArr;
@property (strong, nonatomic) id<ExpandContractControllerDelegate> delegate;
- (void)expandOrContractCellByIndexPaht:(NSIndexPath *)indexPath dataArray:(NSMutableArray *)dataArr controlArray:(NSMutableArray *)controlArr tableView:(UITableView *)tableView;
@end

@protocol ExpandContractControllerDelegate <NSObject>

@end