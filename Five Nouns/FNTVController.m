//
//  FNTVController.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/25/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNTVController.h"
#import "FNSeparatorCell.h"

@interface FNTVController ()
@property (nonatomic, strong) id expanded;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableSet *itemsInDataSource;
@property (nonatomic, strong) NSMutableSet *categoriesInDataSource;
@property (nonatomic, strong) NSString *titleInDataSource;
@end

/*
 why is not calling begin & endUpdates not blowing everything Up? !!!
 
 */

@implementation FNTVController

//- (void)setDelegate:(id<FNTVControllerDelegate>)delegate
//{
//    _delegate = delegate;
//    [self setup];
//}

- (void)setup
{
    self.expanded = nil;
    self.titleInDataSource = [self.delegate title];
    self.dataSource = [@[self.titleInDataSource] mutableCopy];
    if (!self.delegate.shouldCollapseOnTitleTap) {
        [self addCategoriesToDataSource];
    }
}

- (NSMutableSet *)itemsInDataSource
{
    if (!_itemsInDataSource) {
        _itemsInDataSource = [[NSMutableSet alloc] init];
    }
    return _itemsInDataSource;
}

- (void)addCategoriesToDataSource
{
    NSArray *categoriesFromDelegate = [self.delegate categories];
    [self.dataSource addObjectsFromArray:categoriesFromDelegate];
    self.categoriesInDataSource = [NSMutableSet setWithArray:categoriesFromDelegate];
}


- (void)configureTitleCell:(FNSeparatorCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    id item = self.dataSource[indexPath.row];
    CellConfigBlock block = [self.delegate titleCellConfigureBlockForController:self];
    block(cell, item);
    cell.showCellSeparator = [self showCellSeparatorForIndexPath:indexPath];
}

- (void)configureCategoryCell:(FNSeparatorCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    id item = self.dataSource[indexPath.row];
    CellConfigBlock block = [self.delegate categoryCellConfigureBlockForController:self];
    block(cell, item);
    cell.showCellSeparator = [self showCellSeparatorForIndexPath:indexPath];
}

- (void)configureItemCell:(FNSeparatorCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    id item = self.dataSource[indexPath.row];
    CellConfigBlock block = [self.delegate itemCellConfigureBlockForController:self];
    block(cell, item);
    cell.showCellSeparator = [self showCellSeparatorForIndexPath:indexPath];
}

- (UITableViewCell *)refreshRowAtIndexPath:(NSIndexPath *)indexPath
{
    // is this the best way to check the title !!!
    if (self.titleInDataSource == self.dataSource[indexPath.row]) {
        FNSeparatorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"headerCell"];
        [self configureTitleCell:cell forIndexPath:indexPath];
        return cell;
    } else if ([self.categoriesInDataSource containsObject:self.dataSource[indexPath.row]]) {
        FNSeparatorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
        [self configureCategoryCell:cell forIndexPath:indexPath];
        return cell;
    } else if ([self.itemsInDataSource containsObject:self.dataSource[indexPath.row]]){
        FNSeparatorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
        [self configureItemCell:cell forIndexPath:indexPath];
        return cell;
    } else {
        return [[UITableViewCell alloc] init];
    }
}

- (void)collapseExpandedCategory
{
    NSMutableArray *toDelete = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [self.dataSource count]; i++) {
        if ([self.itemsInDataSource containsObject:self.dataSource[i]]) {
            [self.dataSource removeObjectAtIndex:i];
            [toDelete addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    [self.itemsInDataSource removeAllObjects];
    [self.tvController deleteRowsAtIndexPaths:toDelete forController:self];
}

- (void)expandCategory:(id)toExpand
{
    if (toExpand) {
        NSArray *itemsForCategory = [self.delegate itemsForCategory:toExpand];
        NSMutableArray *toInsert = [[NSMutableArray alloc] init];
        NSInteger itemIndex = 1;
        NSInteger categoryIndex = [self.dataSource indexOfObject:toExpand];
        for (id item in itemsForCategory) {
            [self.dataSource insertObject:item atIndex:categoryIndex + itemIndex];
            [self.itemsInDataSource addObject:item];
            [toInsert addObject:[NSIndexPath indexPathForRow:categoryIndex + itemIndex inSection:0]];
            itemIndex ++;
        }
        self.expanded = toExpand;
        [self.tvController insertRowsAtIndexPaths:toInsert forController:self];
    }
}

- (void)showHideCategories
{
    if ([self.delegate shouldCollapseOnTitleTap]) {
        if ([self.dataSource count] == 1) {
            [self addCategoriesToDataSource];
            NSMutableArray *toInsert = [[NSMutableArray alloc] initWithCapacity:[self.dataSource count]];
            NSInteger count = [[self.delegate categories] count];
            for (NSInteger i = 0; i < count; i++) {
                [toInsert addObject:[NSIndexPath indexPathForRow:i + 1 inSection:0]];
            }
            [self.tvController insertRowsAtIndexPaths:toInsert forController:self];
        } else {
            NSMutableArray *toDelete = [[NSMutableArray alloc] initWithCapacity:[self.dataSource count] - 1];
            NSInteger count = [self.dataSource count];
            for (NSInteger i = 1; i < count; i++) {
                [toDelete addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            self.dataSource = [@[[self.delegate title]] mutableCopy];
            [self.tvController deleteRowsAtIndexPaths:toDelete forController:self];
        }
        self.expanded = nil;
    }
}


#pragma mark - Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row: %@", [self.tableView indexPathForSelectedRow]); // !!!
    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
        [self showHideCategories];
        [self.tvController deselectRowAtIndexPath:indexPath forController:self];
    } else if ([self.categoriesInDataSource containsObject:self.dataSource[indexPath.row]]) {
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
    if ([self.categoriesInDataSource containsObject:self.dataSource[indexPath.row]] ||
        self.titleInDataSource == self.dataSource[indexPath.row]) {
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
    if ([self.delegate respondsToSelector:@selector(heightForCell:withItem:)]) {
        UITableViewCell *cell = [self refreshRowAtIndexPath:indexPath];
        return [self.delegate heightForCell:cell withItem:self.dataSource[indexPath.row]];
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.titleInDataSource == self.dataSource[indexPath.row] ||
         [self.categoriesInDataSource containsObject:self.dataSource[indexPath.row]]) {
        return 0;
    } else {
        return 3;
    }
}

#pragma mark - Data Source

- (BOOL)showCellSeparatorForIndexPath:(NSIndexPath *)indexPath
{
    if (self.titleInDataSource == self.dataSource[indexPath.row]) {
        return NO;  // no separator under the title
    } else if ([self.categoriesInDataSource containsObject:self.dataSource[indexPath.row]]) {
        return indexPath.row != [self.dataSource count] - 1;  // no separator under the last cell
    } else {
        if ([self.dataSource count] - 1 > indexPath.row) {
            // separator for the last item cell and there is another category below it
            return [self.categoriesInDataSource containsObject:self.dataSource[indexPath.row + 1]];
        } else {
            return NO;  // no separator under middle item cells
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self refreshRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

// this is only used if this is the only thing in the tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
