//
//  FNTVController.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/25/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNTVController.h"
#import "FNAppearance.h"
#import "FNSeparatorCell.h"


@interface FNTVController ()
@property (nonatomic, strong) id expanded;


@end


/*
 why is not calling begin & endUpdates not blowing everything Up? !!!
 
 */


@implementation FNTVController


- (void)setup
{
    self.expanded = nil;
}

- (NSMutableArray *)subCategoriesForCategory:(id)category
{
//    return [((FNTeam *)category).scoreCards mutableCopy];
}

// need to change this to just ask for a block to setup the cell with
- (UITableViewCell *)refreshRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
//        FNSeparatorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"headerCell"];
//        cell.textLabel.text = self.dataSource[indexPath.row];
//        cell.textLabel.font = [FNAppearance fontWithSize:30];
//        cell.textLabel.textColor = [FNAppearance textColorButton];
//        cell.showCellSeparator = [self showCellSeparatorForIndexPath:indexPath];
//        return cell;
//    } else if ([self.dataSource[indexPath.row] isKindOfClass:[FNTeam class]]) {
//        FNSeparatorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
//        FNTeam *team = self.dataSource[indexPath.row];
//        cell.textLabel.text = team.name;
//        cell.textLabel.textColor = [FNAppearance textColorButton];
//        cell.textLabel.font = [FNAppearance fontWithSize:26];
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", team.currentScore];
//        cell.textLabel.font = [FNAppearance fontWithSize:26];
//        cell.indentationLevel = 0;
//        cell.showCellSeparator = [self showCellSeparatorForIndexPath:indexPath];
//        return cell;
//    } else {
//        FNSeparatorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
//        FNScoreCard *card = self.dataSource[indexPath.row];
//        cell.textLabel.text = [NSString stringWithFormat:@"Round %d", card.round];
//        cell.textLabel.textColor = [FNAppearance textColorLabel];
//        cell.textLabel.font = [FNAppearance fontWithSize:20];
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [card.nounsScored count]];
//        cell.textLabel.font = [FNAppearance fontWithSize:20];
//        cell.indentationLevel = 3;
//        cell.showCellSeparator = [self showCellSeparatorForIndexPath:indexPath];
//        return cell;
//    }
}



////////////////////



- (void)collapseExpandedCategory
{
    NSMutableArray *toDelete = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [self.dataSource count]; i++) {
        if ([self.dataSource[i] isKindOfClass:[self.subCategoryType class]]) {
            [self.dataSource removeObjectAtIndex:i];
            [toDelete addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    [self.tvController deleteRowsAtIndexPaths:toDelete forController:self];
}

- (void)expandCategory:(id)toExpand
{
    if (toExpand) {
        NSMutableArray *toInsert = [[NSMutableArray alloc] init];
        NSInteger subCategoryIndex = 1;
        NSInteger categoryIndex = [self.dataSource indexOfObject:toExpand];
        for (id subCategory in [self subCategoriesForCategory:toExpand]) {
            [self.dataSource insertObject:subCategory atIndex:categoryIndex + subCategoryIndex];
            [toInsert addObject:[NSIndexPath indexPathForRow:categoryIndex + subCategoryIndex inSection:0]];
            subCategoryIndex ++;
        }
        self.expanded = toExpand;
        [self.tvController insertRowsAtIndexPaths:toInsert forController:self];
    }
}

- (void)showHideCategories
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
        self.dataSource = [@[self.title] mutableCopy];
        [self.tvController deleteRowsAtIndexPaths:toDelete forController:self];
    }
    self.expanded = nil;
}


#pragma mark - Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row: %@", [self.tableView indexPathForSelectedRow]);
    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
        [self showHideCategories];
        [self.tvController deselectRowAtIndexPath:indexPath forController:self];
    } else if ([self.dataSource[indexPath.row] isKindOfClass:[self.categoryType class]]) {
        id possibleCategoryToExpand;
        if (self.expanded != self.dataSource[indexPath.row]) {
            possibleCategoryToExpand = self.dataSource[indexPath.row];
        }
        if (self.expanded) {
            [self collapseExpandedCategory];
            NSIndexPath *toDeselect = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:self.expanded] inSection:0];
            [self.tvController deselectRowAtIndexPath:toDeselect forController:self];
        }
        [self expandCategory:possibleCategoryToExpand];
        self.expanded = possibleCategoryToExpand;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource[indexPath.row] isKindOfClass:[self.categoryType class]] ||
        [self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setHighlighted:YES animated:YES];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setHighlighted:NO animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
        return 0;
    } else if ([self.dataSource[indexPath.row] isKindOfClass:[self.categoryType class]]) {
        return 0;
    } else {
        return 3;
    }
}

#pragma mark - Data Source

- (BOOL)showCellSeparatorForIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
        return NO;
    } else if ([self.dataSource[indexPath.row] isKindOfClass:[self.categoryType class]]) {
        return indexPath.row != [self.dataSource count] - 1;
    } else {
        if ([self.dataSource count] - 1 > indexPath.row) {
            return [self.dataSource[indexPath.row + 1] isKindOfClass:[self.categoryType class]];
        } else {
            return NO;
        }
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
