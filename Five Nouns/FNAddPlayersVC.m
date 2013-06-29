//
//  FNAddPlayersVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNAddPlayersVC.h"
#import <QuartzCore/QuartzCore.h>
#import "FNAssignTeamsVC.h"
#import "FNBrain.h"
#import "FNPlayer.h"
#import "FNPlainCell.h"

@interface FNAddPlayersVC ()
@property BOOL addPlayerIsVisible;
@property (nonatomic, strong) FNPlayer *currentPlayer;
@property (nonatomic, weak) UITableViewCell *cellShowingDelete;
@end

@implementation FNAddPlayersVC

- (FNPlayer *)currentPlayer
{
    if (!_currentPlayer) {
        _currentPlayer = [[FNPlayer alloc] init];
        _currentPlayer.nouns = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    }
    return _currentPlayer;
}

#pragma mark - Actions

- (void)displayInvalidPlayerAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Save Player"
                                                    message:@"New Player's must have a name and at least three nouns."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)cellButtonPressed
{
    // save button pressed validate the input and proceed or reject with error message
    [self.tableView endEditing:YES]; // otherwise this method is triggered before the textfield resigns
    if ([self currentPlayerIsValid]) {
        [self toggleAddPlayerSavingCurrentPlayer:YES];
        self.currentPlayer = nil;
    } else {
        [self displayInvalidPlayerAlert];
    }
}

- (void)forwardBarButtonItemPressed
{
    [self performSegueWithIdentifier:@"teamsOverview" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((FNAssignTeamsVC *)segue.destinationViewController).brain = self.brain;
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag == -1) {
        self.currentPlayer.name = textField.text;
    } else if (textField.tag >= 0 && textField.tag <= 4) {
        [self.currentPlayer.nouns replaceObjectAtIndex:textField.tag withObject:textField.text];
    }
    return YES;
}

#pragma mark - Logic Methods

- (void)toggleAddPlayerSavingCurrentPlayer:(BOOL)save
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:7];
    for (int i = 1; i < 8; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        [array addObject:path];
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        // change the add player button on completion otherwise the removed cell fade out
        // above the add player button and which looks bad
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [self.tableView beginUpdates];
    
    if (!self.addPlayerIsVisible) {
        self.addPlayerIsVisible = YES;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
    } else {
        self.addPlayerIsVisible = NO; // why do I need to set this? !!!
        if (save) {
            // save the currentPlayer and add it to the table view
            [self.brain addPlayer:self.currentPlayer];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.brain.allPlayers indexOfObject:self.currentPlayer] inSection:1];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            if ([self.brain.allPlayers count] == 1) {
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
            }
        }
        [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
    }
    [self.tableView endUpdates];
    [CATransaction commit];
}

- (BOOL)currentPlayerIsValid
{
    // validates that a new player was created properly
    NSMutableArray *goodNouns = [[NSMutableArray alloc] init];
    for (NSString *noun in self.currentPlayer.nouns) {
        if ([noun length] > 0) {
            [goodNouns addObject:noun];
        }
    }
    if ([goodNouns count] > 2 && [self.currentPlayer.name length] > 0) {
        self.currentPlayer.nouns = goodNouns;
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self toggleAddPlayerSavingCurrentPlayer:NO];
//            FNPlayer *one = [[FNPlayer alloc] init];
//            one.name = @"Matt";
//            one.nouns = [[NSMutableArray alloc] initWithObjects:@"Civil War Tony Hair", @"Aj", @"Beef", nil];
//            [self.brain addPlayer:one];
//            FNPlayer *two = [[FNPlayer alloc] init];
//            two.name = @"Jill";
//            two.nouns = [[NSMutableArray alloc] initWithObjects:@"Civil War Tony Hair", @"Aj", @"Gopher", nil];
//            [self.brain addPlayer:two];
//            FNPlayer *three= [[FNPlayer alloc] init];
//            three.name = @"Abbey";
//            three.nouns = [[NSMutableArray alloc] initWithObjects:@"Civil War Tony Hair", @"Aj", @"Stool", nil];
//            [self.brain addPlayer:three];
//            FNPlayer *four = [[FNPlayer alloc] init];
//            four.name = @"Wes";
//            four.nouns = [[NSMutableArray alloc] initWithObjects:@"Civil War Tony Hair", @"Aj", @"Spoon", nil];
//            [self.brain addPlayer:four];
        } else {
            // make the textfield (if cell has a textfield) the first responder
            id cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[FNEditableCell class]]) {
                FNEditableCell *textFieldCell = cell;
                [textFieldCell.detailTextField becomeFirstResponder];
            }
        }
    }
    return NO;
}

// to allow deteing players
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

// deletes the player
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tableView beginUpdates];
        [self.brain.allPlayers removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.brain.allPlayers count] > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.addPlayerIsVisible) {
            // add player cell + name + save cell + (minimum of 3 nouns)
            // return (3 + MAX([self.currentPlayer.nouns count], 3));
            // a fixed number of nouns is sooooo much easier
            return 8;
        } else {
            return 1;
        }
    } else {
        return [self.brain.allPlayers count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // add player button cell
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_BUTTON];
            cell.textLabel.text = @"Add Player";
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleButton atIndexPath:indexPath];
            return cell;
        } else if (indexPath.row > 0 && indexPath.row < ([self.tableView numberOfRowsInSection:indexPath.section] - 1)) {
            FNEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TEXT_FIELD];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleTextField atIndexPath:indexPath];
            [self setBackgroundForTextField:cell.detailTextField];
            cell.detailTextField.delegate = self;
            cell.detailTextField.tag = indexPath.row - 2;
            cell.mainTextLabel.text = nil;
            cell.detailTextField.text = nil;
            if (indexPath.row == 1) {
                // name cell
                cell.mainTextLabel.text = @"name:";
                cell.detailTextField.text = self.currentPlayer.name;
            } else if (indexPath.row == 2 ) {
                // the 1st noun
                cell.mainTextLabel.text = @"nouns:";
                if ([self.currentPlayer.nouns count] > 0) {
                    cell.detailTextField.text = [self.currentPlayer.nouns objectAtIndex:0];
                }
            } else if (indexPath.row != [self.tableView numberOfRowsInSection:indexPath.section] - 1) {
                // not the last row so still a noun
                cell.mainTextLabel.text = nil;
                if ([self.currentPlayer.nouns count] >= indexPath.row - 1) {
                    cell.detailTextField.text = [self.currentPlayer.nouns objectAtIndex:indexPath.row - 2];
                }
            }
            return cell;
        } else {
            FNButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_SMALL_BUTTON];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleButtonSmall atIndexPath:indexPath];
            cell.delegate = self;
            return cell;
        }
    } else {
        FNPlainCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_PLAIN];
        [self setBackgroundForCell:cell Style:FNTableViewCellStylePlain atIndexPath:indexPath];
        FNPlayer *player = [self.brain.allPlayers objectAtIndex:indexPath.row];
        cell.textLabel.text = player.name;
        return cell;
    }
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Players"];
    self.addPlayerIsVisible = NO;
}

@end
