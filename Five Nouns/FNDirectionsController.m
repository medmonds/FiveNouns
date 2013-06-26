//
//  FNDirectionsController.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/25/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNDirectionsController.h"
#import "FNGameDirections.h"

@interface FNDirectionsController ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) FNGameDirections *expandedDirection;
@property (nonatomic, strong) NSArray *allDirections;
@end

@implementation FNDirectionsController


//- (void)setup
//{
//    self.allDirections = [FNGameDirections allDirectionsForGame];
//    self.dataSource = [self.allDirections mutableCopy];
//    [self.dataSource insertObject:@"Directions" atIndex:0];
//    self.expandedDirection = nil;
//}
//
//- (void)collapseExpandedDirection
//{
//    NSMutableArray *toDelete = [[NSMutableArray alloc] init];
//    for (NSInteger i = 0; i < [self.dataSource count]; i++) {
//        if ([self.dataSource[i] isKindOfClass:[FNScoreCard class]]) {
//            [self.dataSource removeObjectAtIndex:i];
//            [toDelete addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//        }
//    }
//    [self.tvController deleteRowsAtIndexPaths:toDelete forController:self];
//}
//
//- (void)expandTeam:(FNTeam *)team
//{
//    if (team) {
//        NSMutableArray *toInsert = [[NSMutableArray alloc] init];
//        NSInteger cardIndex = 1;
//        NSInteger teamIndex = [self.dataSource indexOfObject:team];
//        for (FNScoreCard *card in team.scoreCards) {
//            [self.dataSource insertObject:card atIndex:teamIndex + cardIndex];
//            [toInsert addObject:[NSIndexPath indexPathForRow:teamIndex + cardIndex inSection:0]];
//            cardIndex ++;
//        }
//        self.expandedTeam = team;
//        [self.tvController insertRowsAtIndexPaths:toInsert forController:self];
//    }
//}
//
//
//
//
//- (void)showHideScores
//{
//    if ([self.dataSource count] == 1) {
//        [self setup];
//        NSMutableArray *toInsert = [[NSMutableArray alloc] initWithCapacity:[self.dataSource count] - 1];
//        NSInteger count = [self.dataSource count];
//        for (NSInteger i = 1; i < count; i++) {
//            [toInsert addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//        }
//        [self.tvController insertRowsAtIndexPaths:toInsert forController:self];
//    } else {
//        NSMutableArray *toDelete = [[NSMutableArray alloc] initWithCapacity:[self.dataSource count] - 1];
//        NSInteger count = [self.dataSource count];
//        for (NSInteger i = 1; i < count; i++) {
//            [toDelete addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//        }
//        self.dataSource = [@[@"Scores"] mutableCopy];
//        [self.tvController deleteRowsAtIndexPaths:toDelete forController:self];
//    }
//    self.expandedTeam = nil;
//}
//
//
//
//
//
//
//
//#pragma mark - Delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"Selected row: %@", [self.tableView indexPathForSelectedRow]);
//    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
//        [self showHideScores];
//        [self.tvController deselectRowAtIndexPath:indexPath forController:self];
//    } else if ([self.dataSource[indexPath.row] isKindOfClass:[FNTeam class]]) {
//        FNTeam *possibleTeamToExpand;
//        if (self.expandedTeam != self.dataSource[indexPath.row]) {
//            possibleTeamToExpand = self.dataSource[indexPath.row];
//        }
//        if (self.expandedTeam) {
//            [self collapseExpandedTeam];
//            NSIndexPath *toDeselect = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:self.expandedTeam] inSection:0];
//            [self.tvController deselectRowAtIndexPath:toDeselect forController:self];
//        }
//        [self expandTeam:possibleTeamToExpand];
//        self.expandedTeam = possibleTeamToExpand;
//    }
//}
//
//- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([self.dataSource[indexPath.row] isKindOfClass:[FNTeam class]] ||
//        [self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
//        return YES;
//    }
//    return NO;
//}
//
//- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    [cell setHighlighted:YES animated:YES];
//}
//
//- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    [cell setHighlighted:NO animated:YES];
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 44;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
//        return 0;
//    } else {
//        return ;
//    }
//}
//
//#pragma mark - Data Source
//
//- (BOOL)showCellSeparatorForIndexPath:(NSIndexPath *)indexPath
//{
//    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
//        return NO;
//    } else {
//        return indexPath.row != [self.dataSource count] - 1;
//    }
//}
//
//- (UITableViewCell *)refreshRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
//        FNSeparatorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"headerCell"];
//        return cell;
//    } else {
//        FNSeparatorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
//        return cell;
//    }
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [self refreshRowAtIndexPath:indexPath];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    NSInteger rows = [self.dataSource count];
//    return rows;
//}
//
//
@end







