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

@interface FNScoreController ()

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) FNTeam *expandedTeam;
@property (nonatomic, strong) NSArray *teams;
@end

//typedef NS_ENUM(NSInteger, FNScoreCellType) {
//    FNScoreCellTypeTeam,
//    FNScoreCellTypeTurn
//};


@implementation FNScoreController

- (void)setup
{
    self.teams = [self.brain teamOrder];
    self.dataSource = [self.teams mutableCopy];
    self.expandedTeam = nil;
}

- (void)collapseExpandedTeam
{
    NSInteger items = [self.dataSource count];
    for (NSInteger i = 0; i > items; i++) {
        if ([self.dataSource[i] isKindOfClass:[FNScoreCard class]]) {
            [self.dataSource removeObjectAtIndex:i];
        }
    }
    self.expandedTeam = nil;
}

- (void)expandTeam:(FNTeam *)team
{
    if (team) {
        NSInteger cardIndex = 1;
        NSInteger teamIndex = [self.dataSource indexOfObject:team];
        for (FNScoreCard *card in team.scoreCards) {
            [self.dataSource insertObject:card atIndex:teamIndex + cardIndex];
            cardIndex ++;
        }
        self.expandedTeam = team;
    }
}



#pragma mark - Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource[indexPath.row] isKindOfClass:[FNTeam class]]) {
        FNTeam *possibleTeamToExpand;
        if (self.expandedTeam != self.dataSource[indexPath.row]) {
            possibleTeamToExpand = self.dataSource[indexPath.row];
        }
        if (self.expandedTeam) {
            [self collapseExpandedTeam];
        }
        [self expandTeam:possibleTeamToExpand];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource[indexPath.row] isKindOfClass:[FNTeam class]]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

//- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

#pragma mark - Data Source
//
//- (FNScoreCellType)cellTypeForIndexPath
//{
//    
//}

- (UITableViewCell *)refreshRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource[indexPath.row] isKindOfClass:[FNTeam class]]) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
        FNTeam *team = self.dataSource[indexPath.row];
        cell.textLabel.text = team.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", team.currentScore];
        cell.indentationLevel = 0;
        NSLog(@"%@", team.name);
        return cell;
    } else {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
        FNScoreCard *card = self.dataSource[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"Round %d", card.round];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [card.nounsScored count]];
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












