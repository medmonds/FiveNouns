//
//  FNSelectTeamVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNSelectTeamVC.h"
#import "FNCreateTeamVC.h"
#import "FNPlayer.h"


@interface FNSelectTeamVC ()
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation FNSelectTeamVC

- (void)infoFromPresentedModal:(NSArray *)info
{
    FNTeam *newTeam = [info lastObject];
    if (newTeam) {
        // [self.playerForTeam.team.players removeObject:self.playerForTeam]; // remove player from old team
        // [newTeam.players addObject:self.playerForTeam]; // add the player to the new team
        // self.playerForTeam.team = newTeam; // set the player's team to new team
        [self.brain addTeam:newTeam];
    }
}

- (void)configureDataSource
{
    NSArray *rawData = [self.brain.allTeams copy];
    NSArray *sorted = [rawData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *first = ((FNTeam *)obj1).name ? ((FNTeam *)obj1).name : @"";
        NSString *second = ((FNTeam *)obj2).name ? ((FNTeam *)obj2).name : @"";
        return [first localizedCaseInsensitiveCompare:second];
    }];
    self.dataSource = sorted;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"createTeam" sender:self];
    } else {
        FNTeam *selectedTeam = [self.dataSource objectAtIndex:indexPath.row];
        [self.playerForTeam.team.players removeObject:self.playerForTeam]; // remove player from old team
        [selectedTeam.players addObject:self.playerForTeam]; // add player to new team
        self.playerForTeam.team = selectedTeam; // set the player's team to new team
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"createTeam"]) {
        ((FNCreateTeamVC *)segue.destinationViewController).delegate = self;
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
        return 1;
    } else {
        return [self.dataSource count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *CellIdentifier = @"navigationCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Add Team";
        return cell;
    } else {
        NSString *CellIdentifier = @"informationCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        FNTeam *team = [self.dataSource objectAtIndex:indexPath.row];
        cell.textLabel.text = team.name;
        cell.detailTextLabel.text = nil;
        return cell;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureDataSource];
    [self.tableView reloadData];
}


@end
