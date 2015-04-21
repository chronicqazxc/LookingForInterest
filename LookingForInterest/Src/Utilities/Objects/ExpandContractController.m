//
//  ExpandContractController.m
//  ExpandContractTable
//
//  Created by Wayne on 11/21/14.
//  Copyright (c) 2014 Wayne. All rights reserved.
//

#import "ExpandContractController.h"

#define ParentIndexKey @"ParentIndex"
#define SelfIndexkey @"SelfIndex"
#define TitleKey @"Title"
#define ExpandableKey @"Expandable"
#define IsExpandKey @"IsExpand"
#define CountOfChildrenKey @"CountOfChildren"
#define SelfHeightKey @"SelfHeight"
#define LevelTwoKey @"Level2"

@interface ExpandContractController()
@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic) NSMutableArray *controlArr;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSDictionary *dataStructureDic;
@end

@implementation ExpandContractController
- (id)initWithDelegate:(id)delegate tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.tableView = tableView;
    }
    return self;
}

- (void)setNumberOfSection:(int)number dataArray:(NSMutableArray *)dataArr controlArray:(NSMutableArray *)controlArr{
    for (int i=0; i<number; i++) {
        [controlArr addObject:[NSMutableArray array]];
        [dataArr addObject:[NSMutableArray array]];
    }
}

- (void)setNumberOfParent:(int)number andHeigh:(NSString *)heigh section:(int)section dataArray:(NSMutableArray *)dataArr controlArray:(NSMutableArray *)controlArr{
    for (int i=0; i<number; i++) {
        [dataArr[section] addObject:[NSMutableDictionary dictionary]];
        dataArr = [self generateDataInSection:section row:i heigh:heigh dataArray:dataArr];
        
        [controlArr[section] addObject:[NSMutableDictionary dictionary]];
        controlArr = [self generateDataInSection:section row:i heigh:heigh dataArray:controlArr];
    }
}

- (void)setNumberOfChild:(NSString *)number andHeigh:(NSString *)heigh section:(int)section withParentIndex:(int)parentIndex dataArray:(NSMutableArray *)dataArr controlArray:(NSMutableArray *)controlArr{
    
    NSMutableDictionary *controlContentDic = controlArr[section][parentIndex];
    NSMutableDictionary *dataContentDic = dataArr[section][parentIndex];
    
    [controlContentDic setObject:number forKey:CountOfChildrenKey];
    [dataContentDic setObject:number forKey:CountOfChildrenKey];
    
    NSMutableArray *controlLevelTwoArray = [NSMutableArray array];
    NSMutableArray *dataLevelTwoArray = [NSMutableArray array];
    
    for (int i=0; i<[number intValue]; i++) {
        NSMutableDictionary *controlChildDic = [self addChildenDataInParent:parentIndex row:i heigh:heigh];
        NSMutableDictionary *dataChildDic = [self addChildenDataInParent:parentIndex row:i heigh:heigh];
        
        [controlLevelTwoArray addObject:controlChildDic];
        [dataLevelTwoArray addObject:dataChildDic];
    }
    [controlContentDic setObject:controlLevelTwoArray forKey:LevelTwoKey];
    [dataContentDic setObject:dataLevelTwoArray forKey:LevelTwoKey];
}

- (NSMutableArray *)generateDataInSection:(int)section row:(int)row heigh:(NSString *)heigh dataArray:(NSMutableArray *)controlArr{
    NSMutableDictionary *contentDic = controlArr[section][row];
    [contentDic setObject:@"-1" forKey:ParentIndexKey];
    [contentDic setObject:[NSString stringWithFormat:@"%d",row] forKey:SelfIndexkey];
    [contentDic setObject:@"LevelOne" forKey:TitleKey];
    [contentDic setObject:@"1" forKey:ExpandableKey];
    [contentDic setObject:@"0" forKey:IsExpandKey];
    [contentDic setObject:heigh forKey:SelfHeightKey];
    return controlArr;
}

- (NSMutableDictionary *)addChildenDataInParent:(int)parentIndex row:(int)row heigh:(NSString *)heigh{
    NSMutableDictionary *levelTwoDic = [NSMutableDictionary dictionary];
    [levelTwoDic setObject:[NSString stringWithFormat:@"%d",parentIndex] forKey:ParentIndexKey];
    [levelTwoDic setObject:[NSString stringWithFormat:@"%d",row] forKey:SelfIndexkey];
    [levelTwoDic setObject:@"LevelTwo" forKey:TitleKey];
    [levelTwoDic setObject:@"0" forKey:ExpandableKey];
    [levelTwoDic setObject:@"0" forKey:IsExpandKey];
    [levelTwoDic setObject:@"0" forKey:CountOfChildrenKey];
    [levelTwoDic setObject:heigh forKey:SelfHeightKey];
    return levelTwoDic;
}

//- (void)appendData {
//    int totalCount = [[self.dataArr objectAtIndex:1] count];
//    for (int i = 0; i < [self.dataArr count]; i++) {
//        [self.controlArr addObject:[NSMutableDictionary dictionary]];
//        [self.controlArr[i] setObject:@"-1" forKey:ParentIndexKey];
//        [self.controlArr[i] setObject:[NSString stringWithFormat:@"%d",i+totalCount] forKey:SelfIndexkey];
//        [self.controlArr[i] setObject:@"LevelOne" forKey:TitleKey];
//        [self.controlArr[i] setObject:@"1" forKey:ExpandableKey];
//        [self.controlArr[i] setObject:@"0" forKey:IsExpandKey];
//        NSString *numberOfChild = [[self.dataArr objectAtIndex:i] objectForKey:CountOfChildrenKey];
//        [self.controlArr[i] setObject:numberOfChild forKey:CountOfChildrenKey];
//        NSMutableArray *levelTwoArray = [NSMutableArray array];
//        for (int j = 0; j < [numberOfChild integerValue]; j++) {
//            NSMutableDictionary *levelTwoDic = [NSMutableDictionary dictionary];
//            [levelTwoDic setObject:[NSString stringWithFormat:@"%d",i+totalCount] forKey:ParentIndexKey];
//            [levelTwoDic setObject:[NSString stringWithFormat:@"%d",j] forKey:SelfIndexkey];
//            [levelTwoDic setObject:@"LevelTwo" forKey:TitleKey];
//            [levelTwoDic setObject:@"0" forKey:ExpandableKey];
//            [levelTwoDic setObject:@"0" forKey:IsExpandKey];
//            [levelTwoDic setObject:@"0" forKey:CountOfChildrenKey];
//            [levelTwoDic setObject:@"110.0" forKey:SelfHeightKey];
//            [levelTwoArray addObject:levelTwoDic];
//        }
//        [self.controlArr[i] setObject:@"88.0" forKey:SelfHeightKey];
//        [self.controlArr[i] setObject:levelTwoArray forKey:LevelTwoKey];
//    }
//}

- (int)getSelfIndexFrom:(NSArray *)controlArr indexPath:(NSIndexPath *)indexPath {
    int selfIndex = [[controlArr[indexPath.section][indexPath.row] objectForKey:SelfIndexkey] intValue];
    return selfIndex;
}

- (int)getParentIndexFrom:(NSArray *)controlArr indexPath:(NSIndexPath *)indexPath {
    int parentIndex = [[controlArr[indexPath.section][indexPath.row] objectForKey:ParentIndexKey] intValue];
    return parentIndex;
}

- (BOOL)isExpandFor:(NSArray *)controlArr indexPath:(NSIndexPath *)indexPath {
    return [[controlArr[indexPath.section][indexPath.row] objectForKey:IsExpandKey] intValue]?YES:NO;
}

- (void)expandOrContractCellByIndexPaht:(NSIndexPath *)indexPath dataArray:(NSMutableArray *)dataArr controlArray:(NSMutableArray *)controlArr tableView:(UITableView *)tableView {
    int parentIndex = [self getParentIndexFrom:controlArr indexPath:indexPath];
    if ( parentIndex == -1) {
        BOOL isExpand = [self isExpandFor:controlArr indexPath:indexPath];
        if (isExpand) {
            [self contractCellWithIndexPath:indexPath dataArray:dataArr controlArray:controlArr tableView:tableView];
        } else {
            [self expandCellWithIndexPath:indexPath dataArray:dataArr controlArray:controlArr tableView:tableView];
        }
    }
}

- (void)expandCellWithIndexPath:(NSIndexPath *)indexPath dataArray:(NSMutableArray *)dataArr controlArray:(NSMutableArray *)controlArr tableView:(UITableView *)tableView{
    [tableView beginUpdates];
    int selfIndex = [self getSelfIndexFrom:controlArr indexPath:indexPath];
    int numberForInsert = [[dataArr[indexPath.section][selfIndex] objectForKey:CountOfChildrenKey] intValue];
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (int i = 1; i <= numberForInsert; i++) {
        NSIndexPath *indexPathForInsert = [NSIndexPath indexPathForRow:indexPath.row+i inSection:indexPath.section];
        [indexPathArray addObject:indexPathForInsert];
    }
    
    NSArray *children = [dataArr[indexPath.section][selfIndex] objectForKey:LevelTwoKey];
    for (int i = 1; i <= [children count]; i++) {
        [controlArr[indexPath.section] insertObject:children[i-1] atIndex:indexPath.row+1];
    }
    
    [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationMiddle];
    [controlArr[indexPath.section][indexPath.row] setObject:@"1" forKey:IsExpandKey];
    
    [tableView endUpdates];
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+numberForInsert inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)contractCellWithIndexPath:(NSIndexPath *)indexPath dataArray:(NSMutableArray *)dataArr controlArray:(NSMutableArray *)controlArr tableView:(UITableView *)tableView {
    [tableView beginUpdates];
    int selfIndex = [self getSelfIndexFrom:controlArr indexPath:indexPath];
    int numberForRemove = [[dataArr[indexPath.section][selfIndex] objectForKey:CountOfChildrenKey] intValue];
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (int i = 1; i <= numberForRemove; i++) {
        NSIndexPath *indexPathForRemove = [NSIndexPath indexPathForRow:indexPath.row+i inSection:indexPath.section];
        [indexPathArray addObject:indexPathForRemove];
    }
    
    NSIndexSet *indexSetForRemove = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row+1, numberForRemove)];
    [controlArr[indexPath.section] removeObjectsAtIndexes:indexSetForRemove];

    [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationMiddle];
    [controlArr[indexPath.section][indexPath.row] setObject:@"0" forKey:IsExpandKey];
    [tableView endUpdates];
}
@end
