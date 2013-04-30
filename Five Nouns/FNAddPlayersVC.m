//
//  FNAddPlayersVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNAddPlayersVC.h"
#import "FNAssignTeamsVC.h"
#import "FNBrain.h"
#import "FNPlayer.h"

@interface FNAddPlayersVC () <UITextFieldDelegate>
@property BOOL addPlayerIsVisible;
@property (nonatomic, strong) FNPlayer *currentPlayer;
@end

@implementation FNAddPlayersVC

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag == -1) {
        self.currentPlayer.name = textField.text;
    } else if (0 <= textField.tag <= 4) {
        [self.currentPlayer.nouns replaceObjectAtIndex:textField.tag withObject:textField.text];
    }
    return YES;
}

- (NSMutableArray *)indexPathsForAddPlayer
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:7];
    for (int i = 1; i < 8; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        [array addObject:path];
    }
    return array;
}

- (FNPlayer *)currentPlayer
{
    if (!_currentPlayer) {
        _currentPlayer = [[FNPlayer alloc] init];
        _currentPlayer.nouns = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    }
    return _currentPlayer;
}

- (void)toggleAddPlayer
{
    if (!self.addPlayerIsVisible) {
        self.addPlayerIsVisible = YES;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView insertRowsAtIndexPaths:[self indexPathsForAddPlayer] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        self.addPlayerIsVisible = NO;
        [self.tableView deleteRowsAtIndexPaths:[self indexPathsForAddPlayer] withRowAnimation:UITableViewRowAnimationAutomatic];
        // need to change the add player button back to rounded bottom !!??
        //[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)cellButtonPressed
{
    // save button pressed
    // validate the input and proceed or reject with error message
    [self.tableView endEditing:YES]; // otherwise the this method is triggered before the textfield resigns
    if ([self currentPlayerIsValid]) {
        [self.tableView beginUpdates];
        [self.brain addPlayer:self.currentPlayer];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.brain.allPlayers indexOfObject:self.currentPlayer] inSection:1];
        // if inserting 1st player must insert section too (inserting a row does not create the section insertion)
        if ([self.brain.allPlayers count] == 1) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self toggleAddPlayer];
        [self.tableView endUpdates];
        self.currentPlayer = nil;
        // animate this !!??
        [self.tableView reloadData];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Save Player" message:@"New Player's must have a name and at least three nouns." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
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
            [self.tableView beginUpdates];
            [self toggleAddPlayer];
            [self.tableView endUpdates];
        } else {
            // make the textfield (if cell has a textfield) the first responder
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // do nothing here cells should never be selected
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"createPlayer"]) {
//        ((FNCreatePlayerVC *)segue.destinationViewController).delegate = self;
    } else if ([segue.identifier isEqualToString:@"teamsOverview"]) {
        ((FNAssignTeamsVC *)segue.destinationViewController).brain = self.brain;
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
    } else if (section == 1) {
        return [self.brain.allPlayers count];
    } else {
        return 0;
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
        } else if (indexPath.row == 1) {
            // name cell
            FNEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TEXT_FIELD];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleTextFieldLabel atIndexPath:indexPath];
            cell.detailTextField.delegate = self;
            cell.detailTextField.tag = -1;
            [self setBackgroundForTextField:cell.detailTextField];
            cell.mainTextLabel.text = @"name:";
            if (self.currentPlayer.name) {
                cell.detailTextField.text = self.currentPlayer.name;
            } else {
                cell.detailTextField.text = @"";
            }
            return cell;
        } else if (indexPath.row == 2 ) {
            // the 1st noun
            FNEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TEXT_FIELD];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleTextFieldLabel atIndexPath:indexPath];
            cell.detailTextField.delegate = self;
            cell.detailTextField.tag = 0;
            [self setBackgroundForTextField:cell.detailTextField];
            cell.mainTextLabel.text = @"nouns:";
            if ([self.currentPlayer.nouns count] > 0) {
                cell.detailTextField.text = [self.currentPlayer.nouns objectAtIndex:0];
            } else {
                cell.detailTextField.text = @"";
            }
            return cell;
        } else if (indexPath.row != [self.tableView numberOfRowsInSection:indexPath.section] - 1) {
            // not the last row so still a noun
            FNEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TEXT_FIELD];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleTextFieldLabel atIndexPath:indexPath];
            cell.detailTextField.delegate = self;
            cell.detailTextField.tag = indexPath.row - 2;
            [self setBackgroundForTextField:cell.detailTextField];
            cell.mainTextLabel.text = nil;
            if ([self.currentPlayer.nouns count] >= indexPath.row - 1) {
                cell.detailTextField.text = [self.currentPlayer.nouns objectAtIndex:indexPath.row - 2];
            } else {
                cell.detailTextField.text = @"";
            }
            return cell;
        } else {
            FNButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_SMALL_BUTTON];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleButtonSmall atIndexPath:indexPath];
            cell.delegate = self;
            return cell;
        }
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_PLAIN];
        [self setBackgroundForCell:cell Style:FNTableViewCellStylePlain atIndexPath:indexPath];
        FNPlayer *player = [self.brain.allPlayers objectAtIndex:indexPath.row];
        cell.textLabel.text = player.name;
        return cell;
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Players"];
    UIBarButtonItem *back = [FNAppearance backBarButtonItem];
    [back setTarget:self.navigationController];
    [back setAction:@selector(popViewControllerAnimated:)];
    [self.navigationItem setLeftBarButtonItem:back];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

@end
