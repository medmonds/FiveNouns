//
//  FNTVScoreDelegate.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/26/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNTVScoreDelegate.h"
#import "FNBrain.h"
#import "FNTeam.h"
#import "FNScoreCard.h"
#import "FNAppearance.h"
#import "FNScoreCell.h"

@interface FNTVScoreDelegate ()
@property (nonatomic, strong) NSArray *orderedCategories;
@end

@implementation FNTVScoreDelegate

- (NSArray *)orderedCategories
{
    if (!_orderedCategories) {
        _orderedCategories = [self.brain orderOfTeams];
    }
    return _orderedCategories;
}

- (void)orderTeamsByScore
{
    NSMutableArray *teams = [[self.brain orderOfTeams] mutableCopy];
    [teams sortUsingComparator:^NSComparisonResult(FNTeam *team1, FNTeam *team2) {
        if ([self scoreForTeam:team2] > [self scoreForTeam:team1]) {
            return NSOrderedDescending;
        } else if ([self scoreForTeam:team1] > [self scoreForTeam:team2]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    self.orderedCategories = teams;
}

- (BOOL)shouldCollapseOnTitleTap
{
    if (!_shouldCollapseOnTitleTap) {
        return NO;
    }
    return _shouldCollapseOnTitleTap;
}

- (NSArray *)categories
{
    return self.orderedCategories;
}

- (NSString *)title
{
    return @"Score";
}

- (NSArray *)itemsForCategory:(id)category
{
    if ([category isKindOfClass:[FNTeam class]]) {
        NSArray *items = [self.brain scoreCardsForTeam:(FNTeam *)category];
        if (![items count]) {
            FNScoreCard *scorecard = [[FNScoreCard alloc] init];
            scorecard.round = -1;
            items = @[scorecard];
        }
        return items;
    }
    return nil;
}
- (NSString *)cellIdentifierForCategory
{
    return @"scoreCategoryCell";
}

- (NSString *)cellIdentifierForItem
{
    return @"scoreRoundCell";
}

- (NSInteger)scoreForTeam:(FNTeam *)team
{
    NSInteger score = 0;
    NSArray *scoreCardsForTeam = [self.brain scoreCardsForTeam:team];
    for (FNScoreCard *card in scoreCardsForTeam) {
        score += [card.nounsScored count];
    }
    return score;
}

- (CellConfigBlock)titleCellConfigureBlockForController:(FNTVController *)controller
{
    CellConfigBlock block = ^(UITableViewCell *cell, id object) {
        if ([object isKindOfClass:[NSString class]]) {
            cell.textLabel.text = (NSString *)object;
            cell.textLabel.font = [FNAppearance fontWithSize:30];
            cell.textLabel.textColor = [FNAppearance textColorButton];
        }
    };
    return block;
}

- (CellConfigBlock)categoryCellConfigureBlockForController:(FNTVController *)controller
{
    CellConfigBlock block = ^(FNScoreCell *cell, id object) {
        if ([object isKindOfClass:[FNTeam class]]) {
            cell.myTextLabel.text = ((FNTeam *)object).name;
            cell.myTextLabel.textColor = [FNAppearance textColorButton];
            cell.myTextLabel.font = [FNAppearance fontWithSize:26];
            cell.myDetailTextLabel.text = [NSString stringWithFormat:@"%d", [self scoreForTeam:(FNTeam *)object]];
            cell.myTextLabel.font = [FNAppearance fontWithSize:26];
            cell.indentationLevel = 0;
        }
    };
    return block;
}

- (CellConfigBlock)itemCellConfigureBlockForController:(FNTVController *)controller
{
    CellConfigBlock block = ^(FNScoreCell *cell, id object) {
        if ([object isKindOfClass:[FNScoreCard class]]) {
            cell.myTextLabel.textColor = [FNAppearance textColorLabel];
            cell.myTextLabel.font = [FNAppearance fontWithSize:20];
            if (((FNScoreCard *)object).round == -1) {
                cell.myTextLabel.text = @"";
                cell.myDetailTextLabel.text = @"-";
            } else {
                cell.myTextLabel.text = [NSString stringWithFormat:@"Round %d", ((FNScoreCard *)object).round];
                cell.myDetailTextLabel.text = [NSString stringWithFormat:@"%d", [((FNScoreCard *)object).nounsScored count]];
            }
            cell.myDetailTextLabel.font = [FNAppearance fontWithSize:20];
            cell.myDetailTextLabel.font = [FNAppearance fontWithSize:20];
        }
    };
    return block;
}

@end
