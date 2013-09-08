//
//  FNTVTeamsDelegate.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 9/7/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNTVTeamsDelegate.h"
#import "FNBrain.h"
#import "FNTeam.h"
#import "FNPlayer.h"
#import "FNAppearance.h"
#import "FNScoreCell.h"

@implementation FNTVTeamsDelegate

- (BOOL)shouldCollapseOnTitleTap
{
    if (!_shouldCollapseOnTitleTap) {
        return NO;
    }
    return _shouldCollapseOnTitleTap;
}

- (NSArray *)categories
{
    return [self.brain orderOfTeams];
}

- (NSString *)title
{
    return @"Teams";
}

- (NSArray *)itemsForCategory:(id)category
{
    if ([category isKindOfClass:[FNTeam class]]) {
        return ((FNTeam *)category).players;
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
            cell.myDetailTextLabel.text = nil;
        }
    };
    return block;
}

- (CellConfigBlock)itemCellConfigureBlockForController:(FNTVController *)controller
{
    CellConfigBlock block = ^(FNScoreCell *cell, id object) {
        if ([object isKindOfClass:[FNPlayer class]]) {
            cell.myTextLabel.text = ((FNPlayer *)object).name;
            cell.myTextLabel.textColor = [FNAppearance textColorLabel];
            cell.myTextLabel.font = [FNAppearance fontWithSize:20];
            cell.myDetailTextLabel.text = nil;
        }
    };
    return block;
}


@end