//
//  FNAssignTeamsVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNAssignTeamsVC.h"
#import "FNSelectTeamVC.h"
#import "FNPlayer.h"
#import "FNOrderTeamsVC.h"
#import "FNStepperCell.h"
#import "FNReorderableCell.h"
#import "FNSelectableCell.h"

@interface FNAssignTeamsVC ()
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSMutableArray *teams;
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

- (void)stepperDidStep:(UIStepper *)stepper
{
    [self.tableView beginUpdates];
    int numberOfTeams = stepper.value;
    if (numberOfTeams > [self.teams count]) {
        for (int i = numberOfTeams - [self.teams count]; i > 0; i--) {
            FNTeam *newTeam = [[FNTeam alloc] init];
            newTeam.name = [NSString stringWithFormat:@"Team %d", [self.teams count] + 1];
            [self.teams insertObject:newTeam atIndex:[self.teams count]];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:[self.teams count]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else if ([self.teams count] > numberOfTeams) {
        for (int i = [self.teams count] - numberOfTeams; i > 0; i--) {
            [self.teams removeLastObject];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:[self.teams count] + 1] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    NSMutableArray *players = [[NSMutableArray alloc] init];
    for (FNPlayer *player in [self.brain allPlayers]) {
        if (!player.team) {
            [players addObject:player];
        }
    }
    if ([self.teams count] > 0) {
        NSInteger playersPerTeam = [self.brain.allPlayers count] / [self.teams count];
        for (FNTeam *team in self.teams) {
            for (int i = [team.players count]; i < playersPerTeam; i++) {
                if ([players count] > 0) {
                    NSInteger randomPlayer = arc4random() % [players count];
                    [team addPlayer:[players objectAtIndex:randomPlayer]];
                }
            }
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        //[self performSegueWithIdentifier:@"orderTeams" sender:nil];
    }
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
        FNTeam *team = [self.teams objectAtIndex:section - 1];
        NSInteger playerCount = [team.players count];
        return 2 + playerCount + [[self availablePlayersForTeam:team] count];
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
        [cell.stepper addTarget:self action:@selector(stepperDidStep:) forControlEvents:UIControlEventTouchUpInside];
        [cell.detailButtonLabel setBackgroundImage:[FNAppearance backgroundForTextField] forState:UIControlStateNormal];
        cell.detailButtonLabel.titleLabel.text = @"0";
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
            cell.detailTextField.tag = indexPath.row - 2;
            cell.mainTextLabel.text = nil;
            cell.detailTextField.text = nil;
            cell.mainTextLabel.text = @"name:";
            cell.detailTextField.text = team.name;
            return cell;
        } else if ((indexPath.row - 2) < [((FNTeam *)[self.teams objectAtIndex:indexPath.section - 1]).players count]) {
            FNSelectableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"selectable"];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleTextField atIndexPath:indexPath];
            FNPlayer *player = [team.players objectAtIndex:indexPath.row - 2];
            cell.mainTextLabel.text = player.name;
            // if player.team is this team then set the check mark to indicate user selected team member
            // else set the check mark differently
            return cell;
        } else {
            FNSelectableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"selectable"];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleTextField atIndexPath:indexPath];
            FNPlayer *player = [[self availablePlayersForTeam:team] lastObject];
            cell.mainTextLabel.text = player.name;
            // set the check mark to no check mark
            return cell;
        }
    }
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
