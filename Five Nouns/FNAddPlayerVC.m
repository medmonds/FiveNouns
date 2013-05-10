//
//  FNAddPlayerVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 5/7/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNAddPlayerVC.h"
#import <QuartzCore/QuartzCore.h>
#import "FNAssignTeamsVC.h"
#import "FNBrain.h"
#import "FNPlayer.h"
#import "FNPlainCell.h"

@interface FNAddPlayerVC ()
@property BOOL addPlayerIsVisible;
@property (nonatomic, strong) FNPlayer *currentPlayer;
//@property (nonatomic, weak) UITableViewCell *cellShowingDelete;
@end

@implementation FNAddPlayerVC

- (FNPlayer *)currentPlayer
{
    if (!_currentPlayer) {
        _currentPlayer = [[FNPlayer alloc] init];
        _currentPlayer.nouns = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    }
    return _currentPlayer;
}

#pragma mark - Actions
- (IBAction)savePressed:(UIButton *)sender
{
    // save button pressed validate the input and proceed or reject with error message
    [self.tableView endEditing:YES]; // otherwise this method is triggered before the textfield resigns
    if ([self currentPlayerIsValid]) {
        [self toggleAddPlayerSavingCurrentPlayer:YES];
        self.currentPlayer = nil;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Save Player"
                                                        message:@"New Player's must have a name and at least three nouns."
                                                       delegate:nil cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)addPlayerPressed:(UIButton *)sender
{
    [self toggleAddPlayerSavingCurrentPlayer:NO];
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
    if (textField == self.name) {
        self.currentPlayer.name = textField.text;
    } else if (textField == self.noun0) {
        [self.currentPlayer.nouns replaceObjectAtIndex:0 withObject:textField.text];
    } else if (textField == self.noun1) {
        [self.currentPlayer.nouns replaceObjectAtIndex:1 withObject:textField.text];
    } else if (textField == self.noun2) {
        [self.currentPlayer.nouns replaceObjectAtIndex:2 withObject:textField.text];
    } else if (textField == self.noun3) {
        [self.currentPlayer.nouns replaceObjectAtIndex:3 withObject:textField.text];
    } else if (textField == self.noun4) {
        [self.currentPlayer.nouns replaceObjectAtIndex:4 withObject:textField.text];
    }
    return YES;
}

#pragma mark - Logic Methods

- (void)toggleAddPlayerSavingCurrentPlayer:(BOOL)save
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{

    }];
    if (!self.addPlayerIsVisible) {
        self.addPlayerIsVisible = YES;
        // remove the views
        [self.addPlayerButton setBackgroundImage:[FNAppearance backgroundForCellWithStyle:FNTableViewCellStyleButton forPosition:FNTableViewCellPositionTop] forState:UIControlStateNormal];
        [UIView animateWithDuration:1 animations:^{
            self.tableView.frame = [self tvFrameForBottomPosition];
        }];
    } else {
        self.addPlayerIsVisible = NO;
        // add the views
        [UIView animateWithDuration:1 animations:^{
            self.tableView.frame = [self tvFrameForTopPosition];
        }];
        if (save) {
            [self.tableView beginUpdates];
            // save the currentPlayer and add it to the table view
            [self.brain addPlayer:self.currentPlayer];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.brain.allPlayers indexOfObject:self.currentPlayer] inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    }
    [CATransaction commit];
}

- (CGRect)tvFrameForTopPosition
{
    CGFloat xOrigin = 0;
    CGFloat yOrigin = self.addPlayerButton.frame.origin.y + self.addPlayerButton.bounds.size.height;
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height - yOrigin;
    CGRect tvFrame = CGRectMake(xOrigin, yOrigin, width, height);
    return tvFrame;
}

- (CGRect)tvFrameForBottomPosition
{
    CGFloat xOrigin = 0;
    CGFloat yOrigin = self.addPlayerView.frame.origin.y + self.addPlayerView.frame.size.height + 5;
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height - yOrigin;
    CGRect tvFrame = CGRectMake(xOrigin, yOrigin, width, height);
    return tvFrame;
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
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // do nothing here cells should never be selected
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.brain.allPlayers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FNPlainCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_PLAIN];
    [self setBackgroundForCell:cell Style:FNTableViewCellStylePlain atIndexPath:indexPath];
    FNPlayer *player = [self.brain.allPlayers objectAtIndex:indexPath.row];
    cell.textLabel.text = player.name;
    return cell;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Players"];
    self.addPlayerView.image = [FNAppearance backgroundForButton];
    [self.addPlayerButton setBackgroundImage:[FNAppearance backgroundForButton] forState:UIControlStateNormal];
    CGRect tvFrame = self.tableView.frame;
    tvFrame.origin.y = self.addPlayerButton.frame.origin.y + self.addPlayerButton.bounds.size.height;
    tvFrame.size.height = self.view.bounds.size.height - tvFrame.origin.y;
    self.tableView.frame = [self tvFrameForTopPosition];
}


@end










