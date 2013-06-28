//
//  FNTVDirectionsDelegate.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/27/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNTVDirectionsDelegate.h"
#import "FNGameDirections.h"
#import "FNAppearance.h"

@implementation FNTVDirectionsDelegate

- (BOOL)shouldCollapseOnTitleTap
{
    if (!_shouldCollapseOnTitleTap) {
        return NO;
    }
    return _shouldCollapseOnTitleTap;
}

- (NSArray *)categories
{
    return [FNGameDirections allDirectionsForGame];
}

- (NSString *)title
{
    return @"Directions";
}

- (NSArray *)itemsForCategory:(id)category
{
    if ([category isKindOfClass:[FNGameDirections class]]) {
        return @[((FNGameDirections *)category).directions];
    }
    return nil;
}

- (CGFloat)heightForCell:(UITableViewCell *)cell withItem:(id)item
{
    // change this !!!
    return 44;
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
        if ([object isKindOfClass:[FNGameDirections class]]) {
            cell.textLabel.text = ((FNGameDirections *)object).title;
            cell.textLabel.textColor = [FNAppearance textColorButton];
            cell.textLabel.font = [FNAppearance fontWithSize:26];
            cell.detailTextLabel.text = nil;
            cell.indentationLevel = 0;
        }
    };
    return block;
}

- (CellConfigBlock)itemCellConfigureBlockForController:(FNTVController *)controller
{
    CellConfigBlock block = ^(UITableViewCell *cell, id object) {
        if ([object isKindOfClass:[NSString class]]) {
            cell.textLabel.text = (NSString *)object;
            cell.textLabel.textColor = [FNAppearance textColorLabel];
            cell.textLabel.font = [FNAppearance fontWithSize:20];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.numberOfLines = 0;
            cell.detailTextLabel.text = nil;
            cell.textLabel.font = [FNAppearance fontWithSize:20];
            cell.indentationLevel = 3;
        }
    };
    return block;
}

@end