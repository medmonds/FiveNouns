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
#import "FNScoreCell.h"

@implementation FNTVDirectionsDelegate

- (BOOL)shouldCollapseOnTitleTap
{
    if (!_shouldCollapseOnTitleTap) {
        _shouldCollapseOnTitleTap = NO;
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

- (NSString *)cellIdentifierForCategory
{
    return @"scoreCategoryCell";
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
    // only need to resize the cell for the long directions string
    if (![item isKindOfClass:[NSString class]] || [[self title] isEqual:item]) {
        return 44;
    }
    CGFloat width = CGRectGetWidth(cell.frame);
    CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
    CGSize height = [(NSString *)item sizeWithFont:[FNAppearance fontWithSize:20]
                                 constrainedToSize:constraint
                                     lineBreakMode:NSLineBreakByWordWrapping];
    return height.height + 34; // padding
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
        if ([object isKindOfClass:[FNGameDirections class]]) {
            cell.myTextLabel.text = ((FNGameDirections *)object).title;
            cell.myTextLabel.textColor = [FNAppearance textColorButton];
            cell.myTextLabel.font = [FNAppearance fontWithSize:26];
            cell.myDetailTextLabel.text = nil;
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
            cell.indentationLevel = 3;
        }
    };
    return block;
}

@end