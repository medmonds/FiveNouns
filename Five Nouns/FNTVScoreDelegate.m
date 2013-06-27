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

@implementation FNTVScoreDelegate


- (BOOL)shouldCollapseOnTitleTap
{
    if (!_shouldCollapseOnTitleTap) {
        return NO;
    }
    return _shouldCollapseOnTitleTap;
}

- (NSArray *)categories
{
    return [self.brain teamOrder];
}

- (NSString *)title
{
    return @"Score";
}

- (NSArray *)itemsForCategory:(id)category
{
    if ([category isKindOfClass:[FNTeam class]]) {
        return ((FNTeam *)category).scoreCards;
    }
    return nil;
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
    CellConfigBlock block = ^(UITableViewCell *cell, id object) {
        if ([object isKindOfClass:[FNTeam class]]) {
            cell.textLabel.text = ((FNTeam *)object).name;
            cell.textLabel.textColor = [FNAppearance textColorButton];
            cell.textLabel.font = [FNAppearance fontWithSize:26];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", ((FNTeam *)object).currentScore];
            cell.textLabel.font = [FNAppearance fontWithSize:26];
            cell.indentationLevel = 0;
        }
    };
    return block;
}

- (CellConfigBlock)itemCellConfigureBlockForController:(FNTVController *)controller
{
    CellConfigBlock block = ^(UITableViewCell *cell, id object) {
        if ([object isKindOfClass:[FNScoreCard class]]) {
            cell.textLabel.text = [NSString stringWithFormat:@"Round %d", ((FNScoreCard *)object).round];
            cell.textLabel.textColor = [FNAppearance textColorLabel];
            cell.textLabel.font = [FNAppearance fontWithSize:20];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [((FNScoreCard *)object).nounsScored count]];
            cell.textLabel.font = [FNAppearance fontWithSize:20];
            cell.indentationLevel = 3;

        }
    };
    return block;
}

@end
