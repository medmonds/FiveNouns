//
//  FNAddPlayersVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNAddPlayersVC.h"
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

- (void)addPlayer
{
    //[self toggleAddPlayerSavingCurrentPlayer:NO];
    [self addDummyData];
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
    // to change the bottom cell background to flat bottomed before the new cell is inserted
    if ([self.brain.allPlayers count] > 0 && save) {
        NSIndexPath *indexFor2ndToBottom =[NSIndexPath indexPathForRow:[self.brain.allPlayers count] - 1 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:@[indexFor2ndToBottom] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self.tableView beginUpdates];
    if (!self.addPlayerIsVisible) {
        self.addPlayerIsVisible = YES;
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
    } else {
        self.addPlayerIsVisible = NO; // why do I need to set this? !!!
        if (save) {
            // save the currentPlayer and add it to the table view
            [self.brain addPlayer:self.currentPlayer];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.brain.allPlayers indexOfObject:self.currentPlayer] inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        }
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
    }
    [self.tableView endUpdates];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [FNAppearance tableViewBackgroundColor];
    return header;
}

// should this be in didSelectRowAtIndexPath not shouldSelect? !!!
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    // make the textfield (if cell has a textfield) the first responder
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[FNEditableCell class]]) {
        FNEditableCell *textFieldCell = cell;
        [textFieldCell.detailTextField becomeFirstResponder];
    }
    return NO;
}

// to allow deteing players
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    if (self.addPlayerIsVisible) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.addPlayerIsVisible) {
            return 7;
        }
        return [self.brain.allPlayers count];
    }
    return [self.brain.allPlayers count];
}

- (UITableViewCell *)configureNameCellForIndexPath:(NSIndexPath *)indexPath
{
    FNEditableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TEXT_FIELD];
    cell.mainTextLabel.text = @"name:";
    cell.detailTextField.text = self.currentPlayer.name;
    cell.detailTextField.tag = indexPath.row - 1;
    cell.detailTextField.placeholder = @"New Player";
    cell.detailTextField.placeholderTextColor = [FNAppearance textColorButton];
    cell.detailTextField.delegate = self;
    [self setBackgroundForTextField:cell.detailTextField];
    cell.showCellSeparator = NO;
    return cell;
}

- (UITableViewCell *)configureNounCellForIndexPath:(NSIndexPath *)indexPath
{
    FNEditableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TEXT_FIELD];
    // if it is the 1st noun show the "nouns" label
    if (indexPath.row == 1) {
        [cell.mainTextLabel setText:@"nouns:"];
    } else {
        [cell.mainTextLabel setText:nil];
    }
    // if there is a noun to show, show it
    if ([self.currentPlayer.nouns count] >= indexPath.row - 1) {
        cell.detailTextField.text = [self.currentPlayer.nouns objectAtIndex:indexPath.row - 1];
    } else {
        cell.detailTextField.text = nil;
    }
    cell.detailTextField.placeholder = @"Noun";
    cell.detailTextField.placeholderTextColor = [FNAppearance textColorButton];
    cell.detailTextField.delegate = self;
    cell.detailTextField.tag = indexPath.row - 1;
    [self setBackgroundForTextField:cell.detailTextField];
    cell.showCellSeparator = NO;
    return cell;
}

- (UITableViewCell *)configureSaveCellForIndexPath:(NSIndexPath *)indexPath
{
    FNButtonCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_SMALL_BUTTON];
    cell.delegate = self;
    cell.showCellSeparator = NO;
    return cell;
}

- (UITableViewCell *)configureAddedPlayerCellForIndexPath:(NSIndexPath *)indexPath
{
    FNPlainCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_PLAIN];
    FNPlayer *player = [self.brain.allPlayers objectAtIndex:indexPath.row];
    cell.textLabel.text = player.name;
    cell.textLabel.textColor = [FNAppearance textColorLabel];
    cell.showCellSeparator = [self showCellSeparatorForIndexPath:indexPath];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0 && self.addPlayerIsVisible) {
        if (indexPath.row == 0) {
            // name cell
            cell = [self configureNameCellForIndexPath:indexPath];
        } else if (indexPath.row < ([self.tableView numberOfRowsInSection:indexPath.section] - 1)) {
            // noun cell
            cell = [self configureNounCellForIndexPath:indexPath];
        } else {
            // save button cell
            cell = [self configureSaveCellForIndexPath:indexPath];
        }
        [self setBackgroundForCell:cell atIndexPath:indexPath];
    } else {
        cell = [self configureAddedPlayerCellForIndexPath:indexPath];
        [self setBackgroundForCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (BOOL)showCellSeparatorForIndexPath:(NSIndexPath *)indexPath
{
    // only called for the added player cells
    BOOL decision = NO;
    decision = indexPath.row != [self.tableView numberOfRowsInSection:0] - 1;
    NSLog(@"IndexPath: %@   Decision: %d", indexPath, decision);
    return decision;
}


#pragma mark - View Controller Life Cycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addPlayerIsVisible = NO;
}

- (void)addDummyData
{
    FNPlayer *one = [[FNPlayer alloc] init];
    one.name = @"Matt";
    one.nouns = [[NSMutableArray alloc] initWithObjects:@"Civil War Tony Hair", @"Aj", @"Beef", nil];
    [self.brain addPlayer:one];
    FNPlayer *two = [[FNPlayer alloc] init];
    two.name = @"Jill";
    two.nouns = [[NSMutableArray alloc] initWithObjects:@"Civil War Tony Hair", @"Aj", @"Gopher", nil];
    [self.brain addPlayer:two];
    FNPlayer *three= [[FNPlayer alloc] init];
    three.name = @"Abbey";
    three.nouns = [[NSMutableArray alloc] initWithObjects:@"Civil War Tony Hair", @"Aj", @"Stool", nil];
    [self.brain addPlayer:three];
    FNPlayer *four = [[FNPlayer alloc] init];
    four.name = @"Wes";
    four.nouns = [[NSMutableArray alloc] initWithObjects:@"Civil War Tony Hair", @"Aj", @"Spoon", nil];
    [self.brain addPlayer:four];
}

@end
