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
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"selectTeam" sender:[self.dataSource objectAtIndex:indexPath.row]];
    } else {
        [self performSegueWithIdentifier:@"orderTeams" sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectTeam"]) {
        ((FNSelectTeamVC *)segue.destinationViewController).brain = self.brain;
        ((FNSelectTeamVC *)segue.destinationViewController).playerForTeam = sender;
    } else if ([segue.identifier isEqualToString:@"orderTeams"]) {
        ((FNSelectTeamVC *)segue.destinationViewController).brain = self.brain;
    }
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
        NSLog(@"playercount = %d", playerCount);
        return 1 + playerCount;
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
        if (indexPath.row == 0) {
            FNReorderableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"reorderable"];
            [self setBackgroundForCell:cell Style:FNTableViewCellStyleButton atIndexPath:indexPath];
            FNTeam *team = [self.teams objectAtIndex:indexPath.section - 1];
            cell.mainTextLabel.text = team.name;
            return cell;
        } else {
            
        }
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
