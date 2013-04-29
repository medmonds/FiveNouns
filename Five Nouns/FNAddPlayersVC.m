//
//  FNAddPlayersVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNAddPlayersVC.h"
#import "FNCreatePlayerVC.h"
#import "FNAssignTeamsVC.h"
#import "FNBrain.h"
#import "FNPlayer.h"

@interface FNAddPlayersVC ()
@property BOOL addPlayerIsVisible;
@property (nonatomic, strong) FNPlayer *currentPlayer;
@end

@implementation FNAddPlayersVC

- (void)infoFromPresentedModal:(NSArray *)info
{
    FNPlayer *newPlayer = [info lastObject];
    if (newPlayer) {
        [self.brain addPlayer:newPlayer];
    }
    [self.tableView reloadData];
}

- (void)toggleAddPlayer
{
    if (!self.addPlayerIsVisible) {
        self.addPlayerIsVisible = YES;
        if (!self.currentPlayer) {
            self.currentPlayer = [[FNPlayer alloc] init];
        }
    } else {
        self.addPlayerIsVisible = NO;
    }
}

- (void)cellButtonPressed
{
    // save button pressed
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self toggleAddPlayer];
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
        ((FNCreatePlayerVC *)segue.destinationViewController).delegate = self;
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
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_BUTTON forIndexPath:indexPath];
            cell.textLabel.text = @"Add Player";
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleButton atIndexPath:indexPath];
            return cell;
        } else if (indexPath.row == 1) {
            FNEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TEXT_FIELD forIndexPath:indexPath];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleTextFieldLabel atIndexPath:indexPath];
            cell.mainTextLabel.text = @"Name";
            if (self.currentPlayer.name) {
                cell.detailTextField.text = self.currentPlayer.name;
            } else {
                cell.detailTextField.text = nil;
            }
            return cell;
        } else if (indexPath.row == 2 ) {
            FNEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TEXT_FIELD forIndexPath:indexPath];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleTextFieldLabel atIndexPath:indexPath];
            cell.mainTextLabel.text = @"Noun";
            if ([self.currentPlayer.nouns objectAtIndex:indexPath.row - 2]) {
                cell.detailTextField.text = [self.currentPlayer.nouns objectAtIndex:indexPath.row - 2];
            } else {
                cell.detailTextField.text = nil;
            }
            return cell;
        } else if (indexPath.row != [self.tableView numberOfRowsInSection:indexPath.section] - 1) {
            FNEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TEXT_FIELD forIndexPath:indexPath];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleTextFieldLabel atIndexPath:indexPath];
            cell.mainTextLabel.text = nil;
            if ([self.currentPlayer.nouns objectAtIndex:indexPath.row - 2]) {
                cell.detailTextField.text = [self.currentPlayer.nouns objectAtIndex:indexPath.row - 2];
            } else {
                cell.detailTextField.text = nil;
            }
            return cell;
        } else {
            FNButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_SMALL_BUTTON forIndexPath:indexPath];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleButtonSmall atIndexPath:indexPath];
            cell.delegate = self;
            return cell;
        }
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_PLAIN forIndexPath:indexPath];
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
