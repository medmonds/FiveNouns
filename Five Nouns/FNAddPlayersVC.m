//
//  FNAddPlayersVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNAddPlayersVC.h"
#import "FNAppearance.h"
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
    // need to make and use the right kind of cells
    if (indexPath.section == 0) {
        NSString *CellIdentifier = @"navigationCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Add Player";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Name";
            // set the name in the textfield
        } else if (indexPath.row != [self.tableView numberOfRowsInSection:indexPath.section] - 1) {
            // it is a noun cell assuming a fixed number of nouns
            cell.textLabel.text = @"Noun";
            // set the nouns in the textfields
        } else {
            // do nothing the button will already say "Save"
        }
        return cell;
    } else {
        NSString *CellIdentifier = @"informationCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
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
