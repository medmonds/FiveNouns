//
//  FNTVAddPlayerDelegate.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/6/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNTVAddPlayerDelegate.h"
#import "FNAppearance.h"
#import "FNPlayer.h"
#import "FNBrain.h"
#import "FNSelectableCell.h"
#import "FNEditableCell.h"
#import "FNTeam.h"

@interface FNTVAddPlayerDelegate () <UITextFieldDelegate>
@property (nonatomic, strong) FNPlayer *player;
@end

@implementation FNTVAddPlayerDelegate

- (FNPlayer *)player
{
    if (!_player) {
        _player = [[FNPlayer alloc] init];
    }
    return _player;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.player.name = textField.text;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO; // otherwise enters a return
}


- (void)playerAssignmentIndicatorPressed:(UIButton *)sender
{
    // figure out the current state then cycle it accordingly & set the properties & image
    FNSelectableCell *cell = ((FNSelectableCell *)sender.superview.superview);
    FNTeam *team = cell.objectForCell;
    if ([team.players containsObject:self.player]) {
        // remove player from team
        self.player.team = nil;
        [team removePlayer:self.player];
        [cell.button setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    } else {
        // add player to team
        self.player.team = team;
        for (FNTeam *team in self.brain.allTeams) {
            [team removePlayer:self.player];
        }
        [team addPlayer:self.player];
        [cell.button setImage:[FNAppearance checkmarkWithStyle:FNCheckmarkStyleUser] forState:UIControlStateNormal];
    }
}

- (NSString *)cellIdentifierForCategory
{
    return @"textField";
}

- (NSString *)cellIdentifierForItem
{
    return @"selectable";
}

- (BOOL)shouldCollapseOnTitleTap
{
    if ([self.player.name length] > 0 && self.player.team) {
        [self.brain addPlayer:self.player];
        self.player = nil;
        return YES;
    } else if ([self.player.name length] == 0 && !self.player.team) {
        self.player = nil;
        return YES;
    }
    return NO;
}

- (NSArray *)categories
{
    return @[self.player];
}

- (NSString *)title
{
    return @"Add Player";
}

- (NSArray *)itemsForCategory:(id)category
{
    return [self.brain teamOrder];
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
        if ([object isKindOfClass:[FNPlayer class]] && [cell isKindOfClass:[FNEditableCell class]]) {
            ((FNEditableCell *)cell).mainTextLabel.text = @"name:";
            ((FNEditableCell *)cell).detailTextField.text = self.player.name;
            ((FNEditableCell *)cell).detailTextField.textColor = [FNAppearance textColorButton];
            ((FNEditableCell *)cell).textLabel.font = [FNAppearance fontWithSize:26];
            ((FNEditableCell *)cell).indentationLevel = 0;
            ((FNEditableCell *)cell).detailTextField.delegate = self;
        }
    };
    return block;
}

- (CellConfigBlock)itemCellConfigureBlockForController:(FNTVController *)controller
{
    CellConfigBlock block = ^(UITableViewCell *cell, id object) {
        if ([object isKindOfClass:[FNTeam class]] && [cell isKindOfClass:[FNSelectableCell class]]) {
            ((FNSelectableCell *)cell).mainTextLabel.text = ((FNTeam *)object).name;
            ((FNSelectableCell *)cell).mainTextLabel.textColor = [FNAppearance textColorLabel];
            ((FNSelectableCell *)cell).textLabel.font = [FNAppearance fontWithSize:20];
            ((FNSelectableCell *)cell).indentationLevel = 3;
            ((FNSelectableCell *)cell).objectForCell = object;
            [((FNSelectableCell *)cell).button addTarget:self action:@selector(playerAssignmentIndicatorPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    };
    return block;
}

@end


















