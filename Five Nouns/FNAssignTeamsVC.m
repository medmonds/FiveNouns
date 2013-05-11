//
//  FNAssignTeamsVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNAssignTeamsVC.h"
#import <QuartzCore/QuartzCore.h>
#import "FNSelectTeamVC.h"
#import "FNPlayer.h"
#import "FNOrderTeamsVC.h"
#import "FNStepperCell.h"
#import "FNReorderableCell.h"
#import "FNSelectableCell.h"

@interface FNAssignTeamsVC ()
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSMutableArray *teams;
@property (nonatomic) NSInteger visibleTeam;
@end

@implementation FNAssignTeamsVC

- (void)configureDataSource
{
    NSArray *rawData = [self.brain.allPlayers copy];
    NSArray *sorted = [rawData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *first = ((FNPlayer *)obj1).team.name ? ((FNPlayer *)obj1).team.name : @"";
        NSString *second = ((FNPlayer *)obj2).team.name ? ((FNPlayer *)obj2).team.name : @"";
        return [first localizedCaseInsensitiveCompare:second];
    }];
    self.dataSource = sorted;
}

- (NSMutableArray *)teams
{
    if (!_teams) {
        _teams = [[NSMutableArray alloc] init];
    }
    return _teams;
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    // if the textfield is active & the team is deleted by the stepper could go out of array bounds
    if ([self.teams count] > textField.tag) {
        FNTeam *team = [self.teams objectAtIndex:textField.tag];
        team.name = textField.text;
    }
    return YES;
}

- (void)playerAssignmentIndicatorPressed:(UIButton *)sender
{
    // figure out the current state then cycle it accordingly & set the properties & image
    FNSelectableCell *cell = ((FNSelectableCell *)sender.superview.superview);
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    FNPlayer *player = [self playerForIndexPath:indexPath];
    FNTeam *team = [self.teams objectAtIndex:indexPath.section - 1];
    if ([team.players containsObject:player] && player.team == team) {
        // full release of player
        player.team = nil;
        [team removePlayer:player];
        [cell.button setImage:nil forState:UIControlStateNormal];
    } else if ([team.players containsObject:player]) {
        // user assigned team
        player.team = team;
        [cell.button setImage:[FNAppearance checkmarkWithStyle:FNCheckmarkStyleUser] forState:UIControlStateNormal];
    } else {
        // computer assigned team
        for (FNTeam *team in self.teams) {
            [team removePlayer:player];
        }
        [team addPlayer:player];
        [cell.button setImage:[FNAppearance checkmarkWithStyle:FNCheckmarkStyleGame] forState:UIControlStateNormal];
    }
}

- (void)stepperDidStep:(UIStepper *)stepper
{
    [self.tableView beginUpdates];
    int numberOfTeams = stepper.value;
    if (numberOfTeams > [self.teams count]) {
        for (int i = numberOfTeams - [self.teams count]; i > 0; i--) {
            FNTeam *newTeam = [[FNTeam alloc] init];
            newTeam.name = [NSString stringWithFormat:@"Team %d", [self.teams count] + 1];
            [self.teams insertObject:newTeam atIndex:[self.teams count]];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:[self.teams count]] withRowAnimation:UITableViewRowAnimationTop];
        }
    } else if ([self.teams count] > numberOfTeams) {
        for (int i = [self.teams count] - numberOfTeams; i > 0; i--) {
            [self.teams removeLastObject];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:[self.teams count] + 1] withRowAnimation:UITableViewRowAnimationTop];
            if (self.visibleTeam == [self.teams count] + 1) {
                self.visibleTeam = 0;
            }
        }
    }
    FNStepperCell *cell = (FNStepperCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UIButton *buttonLabel = cell.detailButtonLabel;
    buttonLabel.titleLabel.text = [NSString stringWithFormat:@"%d", numberOfTeams];
    [self.tableView endUpdates];
    [self assignPlayersToTeams];
}

- (void)assignPlayersToTeams
{
    // all players in the game
    NSMutableArray *players = [[NSMutableArray alloc] init];
    for (FNPlayer *player in [self.brain allPlayers]) {
        if (!player.team) {
            [players addObject:player];
        }
    }
    // reset the computer assigned team assignments
    FNPlayer *player;
    for (FNTeam *team in self.teams) {
        for (int i = [team.players count] -1; i >= 0; i--) {
            player = [team.players objectAtIndex:i];
            if (player.team != team) {
                [team removePlayer:player];
            }
        }
    }
    if ([self.teams count] > 0) {
        NSInteger playersPerTeam = [self.brain.allPlayers count] / [self.teams count];
        if ([self.brain.allPlayers count] % [self.teams count] != 0) playersPerTeam++;
        for (FNTeam *team in self.teams) {
            for (int i = [team.players count]; i < playersPerTeam; i++) {
                if ([players count] > 0) {
                    NSInteger randomPlayer = arc4random() % [players count];
                    [team addPlayer:[players objectAtIndex:randomPlayer]];
                    [players removeObjectAtIndex:randomPlayer];
                }
            }
        }
    }
}

- (void)toggleTeamForSection:(NSInteger)section
{
    // if anything is open close it. If selected is not open, open it.
    [CATransaction begin];
    NSInteger oldTeam = self.visibleTeam;
    [CATransaction setCompletionBlock:^{
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:oldTeam]] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [self.tableView beginUpdates];
    NSInteger currentlyVisible = self.visibleTeam;
    // close the open team
    if (currentlyVisible > 0) {
        // get the indexPaths for the open section & delete the rows
        NSMutableArray *array = [[NSMutableArray alloc] init];
        int rowsToDelete = [self tableView:self.tableView numberOfRowsInSection:currentlyVisible];
        for (int i = 1; i < rowsToDelete; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:currentlyVisible];
            [array addObject:path];
        }
        [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
        self.visibleTeam = 0;
    }
    // open the team section
    if (section != currentlyVisible) {
        self.visibleTeam = section;
        // conditionally open the selected team
        NSMutableArray *array = [[NSMutableArray alloc] init];
        int rowsToInsert = [self tableView:self.tableView numberOfRowsInSection:section];
        for (int i = 1; i < rowsToInsert; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:section];
            [array addObject:path];
        }
        [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
    }
    [self.tableView endUpdates];
    [CATransaction commit];

}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        [self toggleTeamForSection:indexPath.section];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // should never be called
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((FNSelectTeamVC *)segue.destinationViewController).brain = self.brain;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + [self.teams count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        if (section == self.visibleTeam) {
            FNTeam *team = [self.teams objectAtIndex:section - 1];
            NSInteger playerCount = [team.players count];
            return 2 + playerCount + [[self availablePlayersForTeam:team] count];
        }
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        FNStepperCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"stepper"];
        [self setBackgroundForCell:cell Style:FNTableViewCellStyleButton atIndexPath:indexPath];
        cell.stepper.autorepeat = NO;
        cell.stepper.wraps = YES;
        cell.stepper.maximumValue = 6;
        cell.stepper.value = [self.teams count];
        [cell.stepper addTarget:self action:@selector(stepperDidStep:) forControlEvents:UIControlEventTouchUpInside];
        [cell.detailButtonLabel setBackgroundImage:[FNAppearance backgroundForTextField] forState:UIControlStateNormal];
        cell.detailButtonLabel.titleLabel.text = [NSString stringWithFormat:@"%d", [self.teams count]];
        return cell;
    } else {
        FNTeam *team = [self.teams objectAtIndex:indexPath.section - 1];
        if (indexPath.row == 0) {
            FNReorderableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"reorderable"];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleButton atIndexPath:indexPath];
            cell.mainTextLabel.text = team.name;
            return cell;
        } else if (indexPath.row == 1) {
            FNEditableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TEXT_FIELD];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleTextField atIndexPath:indexPath];
            [self setBackgroundForTextField:cell.detailTextField];
            cell.detailTextField.delegate = self;
            cell.detailTextField.tag = indexPath.section -1;
            cell.mainTextLabel.text = nil;
            cell.detailTextField.text = nil;
            cell.mainTextLabel.text = @"name:";
            cell.detailTextField.text = team.name;
            return cell;
        } else {
            FNSelectableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"selectable"];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleTextField atIndexPath:indexPath];
            [cell.button addTarget:self action:@selector(playerAssignmentIndicatorPressed:) forControlEvents:UIControlEventTouchUpInside];
            FNPlayer *player = [self playerForIndexPath:indexPath];
            NSLog(@"IndexPath: %d", indexPath.row);
            NSLog(@"playerIndex: %d", indexPath.row - 2);
            NSLog(@"[Team.players count]: %d", [team.players count]);
            NSLog(@"[self availablePlayerForTeam count]: %d", [[self availablePlayersForTeam:team] count]);
            if (player.team == team) {
                [cell.button setImage:[FNAppearance checkmarkWithStyle:FNCheckmarkStyleUser] forState:UIControlStateNormal];
            } else if ([team.players containsObject:player]) {
                [cell.button setImage:[FNAppearance checkmarkWithStyle:FNCheckmarkStyleGame] forState:UIControlStateNormal];
            } else {
                [cell.button setImage:nil forState:UIControlStateNormal];
            }
            cell.mainTextLabel.text = player.name;
            return cell;
        }
    }
}

- (FNPlayer *)playerForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger playerIndex = indexPath.row - 2;
    FNPlayer *player;
    FNTeam *team = [self.teams objectAtIndex:indexPath.section - 1];
    if ([team.players count] > playerIndex) {
        player = [team.players objectAtIndex:playerIndex];
    } else {
        player = [[self availablePlayersForTeam:team] objectAtIndex:playerIndex - [team.players count]];
    }
    return player;
}

- (NSArray *)availablePlayersForTeam:(FNTeam *)team
{
    NSMutableArray *allPlayers = self.brain.allPlayers;
    NSMutableArray *availablePlayers = [[NSMutableArray alloc] init];
    for (FNPlayer *player in allPlayers) {
        if (!player.team && ![team.players containsObject:player]) {
            [availablePlayers addObject:player];
        }
    }
    return availablePlayers;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureDataSource];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Teams"];
}

@end
