//
//  FNScoreController.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/20/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNScoreController.h"
#import "FNBrain.h"
#import "FNScoreCard.h"
#import "FNPlayer.h"
#import "FNAppearance.h"

@interface FNScoreController ()

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) FNTeam *expandedTeam;
@property (nonatomic, strong) NSArray *teams;
@end

//typedef NS_ENUM(NSInteger, FNScoreCellType) {
//    FNScoreCellTypeTeam,
//    FNScoreCellTypeTurn
//};

/*
 why is not calling begin & endUpdates not blowing everything Up? !!!
 
*/


@implementation FNScoreController

- (void)setup
{
    self.teams = [NSMutableArray arrayWithArray:[self.brain teamOrder]];
    self.dataSource = [self.teams mutableCopy];
    [self.dataSource insertObject:@"Score" atIndex:0];
    self.expandedTeam = nil;
}

- (void)collapseExpandedTeam
{
    NSMutableArray *toDelete = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [self.dataSource count]; i++) {
        if ([self.dataSource[i] isKindOfClass:[FNScoreCard class]]) {
            [self.dataSource removeObjectAtIndex:i];
            [toDelete addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    [self.tvController deleteRowsAtIndexPaths:toDelete forController:self];
}

- (void)expandTeam:(FNTeam *)team
{
    if (team) {
        NSMutableArray *toInsert = [[NSMutableArray alloc] init];
        NSInteger cardIndex = 1;
        NSInteger teamIndex = [self.dataSource indexOfObject:team];
        for (FNScoreCard *card in team.scoreCards) {
            [self.dataSource insertObject:card atIndex:teamIndex + cardIndex];
            [toInsert addObject:[NSIndexPath indexPathForRow:teamIndex + cardIndex inSection:0]];
            cardIndex ++;
        }
        self.expandedTeam = team;
        [self.tvController insertRowsAtIndexPaths:toInsert forController:self];
    }
}

- (void)showHideScores
{
    if ([self.dataSource count] == 1) {
        [self setup];
        NSMutableArray *toInsert = [[NSMutableArray alloc] initWithCapacity:[self.dataSource count] - 1];
        NSInteger count = [self.dataSource count];
        for (NSInteger i = 1; i < count; i++) {
            [toInsert addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [self.tvController insertRowsAtIndexPaths:toInsert forController:self];
    } else {
        NSMutableArray *toDelete = [[NSMutableArray alloc] initWithCapacity:[self.dataSource count] - 1];
        NSInteger count = [self.dataSource count];
        for (NSInteger i = 1; i < count; i++) {
            [toDelete addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        self.dataSource = [@[@"Scores"] mutableCopy];
        [self.tvController deleteRowsAtIndexPaths:toDelete forController:self];
    }
    self.expandedTeam = nil;
}


#pragma mark - Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row: %@", [self.tableView indexPathForSelectedRow]);
    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
        [self showHideScores];
        [self.tvController deselectRowAtIndexPath:indexPath forController:self];
    } else if ([self.dataSource[indexPath.row] isKindOfClass:[FNTeam class]]) {
        FNTeam *possibleTeamToExpand;
        if (self.expandedTeam != self.dataSource[indexPath.row]) {
            possibleTeamToExpand = self.dataSource[indexPath.row];
        }
        if (self.expandedTeam) {
            [self collapseExpandedTeam];
            NSIndexPath *toDeselect = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:self.expandedTeam] inSection:0];
            [self.tvController deselectRowAtIndexPath:toDeselect forController:self];
        }
        [self expandTeam:possibleTeamToExpand];
        self.expandedTeam = possibleTeamToExpand;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource[indexPath.row] isKindOfClass:[FNTeam class]] ||
        [self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    // this should really be done in custom cell subclasses    
    [UIView animateWithDuration:.3 animations:^(void){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor = [FNAppearance textColorButton];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
        return 0;
    } else if ([self.dataSource[indexPath.row] isKindOfClass:[FNTeam class]]) {
        return 0;
    } else {
        return 3;
    }
}

#pragma mark - Data Source
//
//- (FNScoreCellType)cellTypeForIndexPath
//{
//    
//}

- (UITableViewCell *)refreshRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"headerCell"];
        cell.textLabel.text = self.dataSource[indexPath.row];
        cell.textLabel.font = [FNAppearance fontWithSize:30];
        cell.textLabel.textColor = [FNAppearance textColorButton];
        return cell;
    } else if ([self.dataSource[indexPath.row] isKindOfClass:[FNTeam class]]) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
        FNTeam *team = self.dataSource[indexPath.row];
        cell.textLabel.text = team.name;
        cell.textLabel.textColor = [FNAppearance textColorButton];
        cell.textLabel.font = [FNAppearance fontWithSize:26];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", team.currentScore];
        cell.textLabel.font = [FNAppearance fontWithSize:26];
        cell.indentationLevel = 0;
        NSLog(@"%@", team.name);
        return cell;
    } else {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
        FNScoreCard *card = self.dataSource[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"Round %d", card.round];
        cell.textLabel.textColor = [FNAppearance textColorLabel];
        cell.textLabel.font = [FNAppearance fontWithSize:20];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [card.nounsScored count]];
        cell.textLabel.font = [FNAppearance fontWithSize:20];
        cell.indentationLevel = 3;
        return cell;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self refreshRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = [self.dataSource count];
    return rows;
}

@end












