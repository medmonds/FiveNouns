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

@interface FNAssignTeamsVC ()
@property (nonatomic, strong) NSArray *dataSource;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.dataSource count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *CellIdentifier = @"informationCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        FNPlayer *player = [self.dataSource objectAtIndex:indexPath.row];
        cell.textLabel.text = player.name;
        cell.detailTextLabel.text = player.team.name ? player.team.name : @"Choose Team";
        return cell;
    } else {
        NSString *CellIdentifier = @"navigationCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Next";
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureDataSource];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
