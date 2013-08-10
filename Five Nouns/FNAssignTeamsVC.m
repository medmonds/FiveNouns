//
//  FNAssignTeamsVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNAssignTeamsVC.h"
#import <QuartzCore/QuartzCore.h>
#import "FNPlayer.h"
#import "FNStepperCell.h"
#import "FNReorderableCell.h"
#import "FNSelectableCell.h"
#import "FMMoveTableView.h"
#import "FNNextUpVC.h"
#import "FNBrain.h"
#import "FNTeam.h"
#import "THObserver.h"

@interface FNAssignTeamsVC ()
@property (nonatomic) NSInteger visibleTeamIndex;
@property (nonatomic, strong) FNTeam *visibleTeam;
@property (nonatomic, strong) NSMutableArray *headerViews;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableOrderedSet *availablePlayers;
@property (nonatomic, strong) NSMutableSet *observedPlayers;
@property (nonatomic, strong) NSMutableSet *observers;
@end



@implementation FNAssignTeamsVC


/*****************************************************************************************************
  
KVO:
 
 kvo brain.allTeams - to know when a team is added or removed
 kvo all team.name - to know when there names are changed
 kvo all team.players - to know when players are assigned and unassigned (auto assigned/unassigned by the brain)
 
 kvo brain.allplayers - to know when a player is added or removed
 kvo all player.team to know when a player is assigned to a team (by the user) this needs to trump & not conflict w/ team.players updates
 unassignedPlayers array should be removed from the brain the and should be created and maintained by the AssignTeamsVC

 
 figure out how adding a player effects team assignments
 
** need to link the players being observed to their observers so I can call stopObsering before releasing the player
 
 
 To Do:
 
 - animate adding and remove the forward button when number of teams moves to & past zero
   then remove the check at - forwardBarButtonItemPressed
 
 - make button backgrounds for the selected state
 - set the selected background for the stepper when stepped
 - (??) set the selected background for the reorder control when reordering (not when pressed)
 - change team name to be edited in the button cell (row 0) and make the background dark when expanded
 
 Ideas:
 
 To show all of the team members (for Review) could just show the assigned players & Just the
 team name header cell (maybe checkmarks) but in a flat (not inset) manner and then when pressed
 animate and "push the cells into the game" for the the inset look
 
 
 ******************************************************************************************************/

#define PLAYER_INDEX_OFFSET 2

typedef NS_ENUM(NSInteger, FNTeamCellType) {
    FNTeamCellTypeNumberOfTeams,
    FNTeamCellTypeReorder,
    FNTeamCellTypeName,
    FNTeamCellTypePlayer
};

- (NSMutableArray *)headerViews
{
    if (!_headerViews) {
        _headerViews = [[NSMutableArray alloc] init];
    }
    return _headerViews;
}

- (NSMutableSet *)observers
{
    if (!_observers) {
        _observers = [[NSMutableSet alloc] init];
    }
    return _observers;
}

- (NSMutableSet *)observedPlayers
{
    if (!_observedPlayers) {
        _observedPlayers = [[NSMutableSet alloc] init];
    }
    return _observedPlayers;
}

- (NSMutableOrderedSet *)availablePlayers
{
    if (!_availablePlayers) {
        _availablePlayers = [[NSMutableOrderedSet alloc] init];
    }
    return _availablePlayers;
}

- (void)tearDown
{
    
}

- (void)setup
{
    self.dataSource = [[NSMutableArray alloc] initWithCapacity:6]; // the maximum number of teams
    THObserver *teamsObserver = [THObserver observerForObject:self.brain keyPath:@"allTeams" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld target:self action:@selector(allTeamsChangedForBrain:keyPath:change:)];
    [self.observers addObject:teamsObserver];
    [self.dataSource addObjectsFromArray:[self createObserversAndDataObjectsForTeams:self.brain.allTeams]];
    THObserver *playersObserver = [THObserver observerForObject:self.brain keyPath:@"allPlayers" options:NSKeyValueObservingOptionNew target:self action:@selector(allPlayersChangedForBrain:keyPath:change:)];
    [self.observers addObject:playersObserver];
    [self createObserversForPlayers:self.brain.allPlayers];
    for (FNPlayer *player in self.brain.allPlayers) {
        if (!player.team) {
            [self.availablePlayers addObject:player];
        }
    }
}

- (NSArray *)createObserversAndDataObjectsForTeams:(NSArray *)teams
{
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:[teams count]];
    for (FNTeam *team in teams) {
        THObserver *teamName = [THObserver observerForObject:team keyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld target:self action:@selector(nameChangedForTeam:keyPath:change:)];
        THObserver *teamPlayers = [THObserver observerForObject:team keyPath:@"players" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld target:self action:@selector(playersAssignedToTeam:keyPath:change:)];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"team" : team, @"players" : [team.players mutableCopy], @"observers" : @[teamName, teamPlayers]}];
        [data addObject:dict];
    }
    return data;
}

- (void)stopObserversForTeams:(NSArray *)teams
{
    for (FNTeam *team in teams) {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:self.dataSource];
        __block NSUInteger index;
        [temp enumerateObjectsUsingBlock:^(NSMutableDictionary *dict, NSUInteger idx, BOOL *stop) {
            if ([dict objectForKey:@"team"] == team) {
                [dict removeObjectForKey:@"observers"];
                index = idx;
                stop = YES;
            }
        }];
        [temp removeObjectAtIndex:index];
    }
}

- (void)createObserversForPlayers:(NSArray *)players
{
    for (FNPlayer *player in players) {
        THObserver *playerTeam = [THObserver observerForObject:player keyPath:@"team" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld target:self valueAction:@selector(player:teamChangedFrom:to:)];
        [self.observers addObject:playerTeam];
        [self.observedPlayers addObject:player];
    }
}

- (void)stopObserversForPlayers:(NSArray *)players
{
    for (FNPlayer *player in players) {
        THObserver *toDelete;
        for (THObserver *observer in self.observers) {
            if (observer.observed == player) {
                [observer stopObserving];
                toDelete = observer;
                break;
            }
        }
        [self.observers removeObject:toDelete];
        [self.observedPlayers removeObject:player];
    }
}

- (void)refreshCells
{
    NSIndexPath *indexPath;
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        indexPath = [self.tableView indexPathForCell:cell];
        [super setBackgroundForCell:cell atIndexPath:indexPath];
    }
}

- (void)allTeamsChangedForBrain:(FNBrain *)brain keyPath:(NSString *)keypath change:(NSDictionary *)changeDictionary
{
//    NSLog(@"allTeamsChangedForBrain");
    NSKeyValueChange change = [[changeDictionary objectForKey:NSKeyValueChangeKindKey] integerValue];
    NSIndexSet *indexes = [changeDictionary objectForKey:NSKeyValueChangeIndexesKey];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self refreshCells];
    }];
    [self.tableView beginUpdates];
    switch (change) {
        case NSKeyValueChangeInsertion: {
            NSArray *inserted = [changeDictionary objectForKey:NSKeyValueChangeNewKey];
            [self.dataSource insertObjects:[self createObserversAndDataObjectsForTeams:inserted] atIndexes:indexes];
            [self.tableView insertSections:indexes withRowAnimation:UITableViewRowAnimationTop];
            break;
        }
        case NSKeyValueChangeRemoval: {
            [self stopObserversForTeams:[changeDictionary objectForKey:NSKeyValueChangeOldKey]];
            [self.dataSource removeObjectsAtIndexes:indexes];
            [self.tableView deleteSections:indexes withRowAnimation:UITableViewRowAnimationTop];
            break;
        }
        case NSKeyValueChangeReplacement: {
            NSArray *replacements = [changeDictionary objectForKey:NSKeyValueChangeNewKey];
            [self.dataSource replaceObjectsAtIndexes:indexes withObjects:replacements];
            [self.tableView reloadSections:indexes withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
            
        default:
            break;
    }
    [self.tableView endUpdates];
    [CATransaction commit];
}

- (void)nameChangedForTeam:(FNTeam *)team keyPath:(NSString *)keyPath change:(NSDictionary *)changeDictionary
{
    NSLog(@"nameChangedForTeam");
    NSString *newName = [changeDictionary objectForKey:NSKeyValueChangeNewKey];
    __block FNTeam *myTeam;
    __block NSInteger section;
    [self.dataSource enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        if ([dict objectForKey:@"team"] == team) {
            myTeam = team;
            section = idx;
        }
    }];
    if (team.name == newName) {
        return;
    }
    FNEditableCell *cell = (FNEditableCell  *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    [UIView animateWithDuration:.2 animations:^{
        cell.detailTextField.alpha = 0;
    } completion:^(BOOL finished) {
        cell.detailTextField.text = team.name;
        cell.detailTextField.alpha = 1;
    }];
}

- (void)playersAssignedToTeam:(FNTeam *)team keyPath:(NSString *)keyPath change:(NSDictionary *)changeDictionary
{
    NSLog(@"playersAssignedToTeam");
    // if the player was assigned to a team then remove the player from the available players list
    // if the player was assigned to the visible team then indicate that for the team (show checkmark and move the player up the list)
    // if the player was assigned to a different team then remove the player from the available players section
    
    // if the player was unassigned from a team then add the player to the available players list
    // if the player was unassigned from the visible team then remove the checkmark and move the player to the bottom of the list
    // if the player was unassigned from a different team then show the player at the bottom of the list
    
    NSKeyValueChange change = [[changeDictionary objectForKey:NSKeyValueChangeKindKey] integerValue];
    NSIndexSet *indexes = [changeDictionary objectForKey:NSKeyValueChangeIndexesKey];
    __block NSMutableArray *teamPlayers;
    [self.dataSource enumerateObjectsUsingBlock:^(NSMutableDictionary *dict, NSUInteger idx, BOOL *stop) {
        if (team == [dict objectForKey:@"team"]) {
            teamPlayers = [dict objectForKey:@"players"];
            stop = YES;
        }
    }];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self refreshCells];
    }];
    [self.tableView beginUpdates];
    switch (change) {
        case NSKeyValueChangeInsertion: {
            // players were assigned to a team
            NSArray *assigned = [changeDictionary objectForKey:NSKeyValueChangeNewKey];
            [teamPlayers insertObjects:assigned atIndexes:indexes];
            if (self.visibleTeam == team) {
                NSMutableArray *fromIndexes = [[NSMutableArray alloc] initWithCapacity:[assigned count]];
                NSInteger unassignedPlayerIndexOffset = ([teamPlayers count] - [assigned count]) + PLAYER_INDEX_OFFSET;
                for (FNPlayer *player in assigned) {
                    [fromIndexes addObject:[NSIndexPath indexPathForRow:[self.availablePlayers indexOfObject:player] + unassignedPlayerIndexOffset inSection:self.visibleTeamIndex]];
                    [self.availablePlayers removeObject:player];
                }
                [self setAssignmentIndicatorsForCellsAtIndexPaths:fromIndexes to:YES];
                NSMutableArray *toIndexes = [[NSMutableArray alloc] initWithCapacity:[assigned count]];
                for (FNPlayer *player in assigned) {
                    [toIndexes addObject:[NSIndexPath indexPathForRow:[teamPlayers indexOfObject:player] + PLAYER_INDEX_OFFSET inSection:self.visibleTeamIndex]];
                }
                for (int i = 0; i < [toIndexes count]; i++) {
                    [self.tableView moveRowAtIndexPath:[fromIndexes objectAtIndex:i] toIndexPath:[toIndexes objectAtIndex:i]];
                }
            } else if (self.visibleTeamIndex >= 0) {
                NSInteger unassignedPlayerIndexOffset = [[[self.dataSource objectAtIndex:self.visibleTeamIndex] objectForKey:@"players"] count] + PLAYER_INDEX_OFFSET;
                NSMutableArray *deletePaths = [[NSMutableArray alloc] initWithCapacity:[indexes count]];
                for (FNPlayer *player in assigned) {
                    [deletePaths addObject:[NSIndexPath indexPathForRow:[self.availablePlayers indexOfObject:player] + unassignedPlayerIndexOffset inSection:self.visibleTeamIndex]];
                }
                [self.availablePlayers removeObjectsInArray:assigned];
                [self.tableView deleteRowsAtIndexPaths:deletePaths withRowAnimation:UITableViewRowAnimationTop];
            } else {
                [self.availablePlayers removeObjectsInArray:assigned];
            }
            break;
        }
        case NSKeyValueChangeRemoval: {
            // players were removed from a team
            NSArray *unassigned = [changeDictionary objectForKey:NSKeyValueChangeOldKey];
            [self.availablePlayers addObjectsFromArray:unassigned];
            // the player is now available so add them to that part of the list
            if (self.visibleTeam == team) {
                // move the rows down to the bottom half
                NSMutableArray *fromIndexes = [[NSMutableArray alloc] initWithCapacity:[unassigned count]];
                for (FNPlayer *player in unassigned) {
                    [fromIndexes addObject:[NSIndexPath indexPathForRow:[teamPlayers indexOfObject:player] + PLAYER_INDEX_OFFSET inSection:self.visibleTeamIndex]];
                    [teamPlayers removeObject:player];
                }
                [self setAssignmentIndicatorsForCellsAtIndexPaths:fromIndexes to:NO];
                NSMutableArray *toIndexes = [[NSMutableArray alloc] initWithCapacity:[unassigned count]];
                NSInteger unassignedPlayerIndexOffset = [teamPlayers count] + PLAYER_INDEX_OFFSET;
                for (FNPlayer *player in unassigned) {
                    [toIndexes addObject:[NSIndexPath indexPathForRow:[self.availablePlayers indexOfObject:player] + unassignedPlayerIndexOffset inSection:self.visibleTeamIndex]];
                }
                for (int i = 0; i < [toIndexes count]; i++) {
                    [self.tableView moveRowAtIndexPath:[fromIndexes objectAtIndex:i] toIndexPath:[toIndexes objectAtIndex:i]];
                }
            } else if (self.visibleTeamIndex >= 0) {
                NSInteger unassignedPlayerIndexOffset = [[[self.dataSource objectAtIndex:self.visibleTeamIndex] objectForKey:@"players"] count] + PLAYER_INDEX_OFFSET;
                NSMutableArray *insertIndexes = [[NSMutableArray alloc] initWithCapacity:[unassigned count]];
                for (FNPlayer *player in unassigned) {
                    [insertIndexes addObject:[NSIndexPath indexPathForRow:[self.availablePlayers indexOfObject:player] + unassignedPlayerIndexOffset inSection:self.visibleTeamIndex]];
                }
                [teamPlayers removeObjectsInArray:unassigned];
                [self.tableView insertRowsAtIndexPaths:insertIndexes withRowAnimation:UITableViewRowAnimationTop];
            } else {
                [teamPlayers removeObjectsInArray:unassigned];
            }
            break;
        }
        case NSKeyValueChangeReplacement: {
            // should never happen
            break;
        }
        default:
            break;
    }
    [self.tableView endUpdates];
    [CATransaction commit];
}

// when I show the players assigned to a team and available players I will show the assigned players assigned & available fix this !!!
// will have to make a method like availablePlayerForTeam: or something to get the players to display to account for players assigned to the current team but available to other teams

- (void)allPlayersChangedForBrain:(FNBrain *)brain keyPath:(NSString *)keyPath change:(NSDictionary *)changeDictionary
{
    // only handle the change to available players here and adding or removing any observers
    // the brain will handle adding players & removeing players from teams they might be assigned to
    
    NSLog(@"allPlayersChangedForBrain");
    
    NSKeyValueChange change = [[changeDictionary objectForKey:NSKeyValueChangeKindKey] integerValue];
    [self.tableView beginUpdates];
    switch (change) {
        case NSKeyValueChangeInsertion: {
            NSArray *inserted = [changeDictionary objectForKey:NSKeyValueChangeNewKey];
            [self createObserversForPlayers:inserted];
            NSMutableArray *toInsert = [[NSMutableArray alloc] initWithCapacity:[inserted count]];
            for (FNPlayer *player in inserted) {
                if (player.team == nil) {
                    [self.availablePlayers addObject:player];
                    if (self.visibleTeam) {
                        NSArray *visibleTeamPlayers = [[self.dataSource objectAtIndex:self.visibleTeamIndex] objectForKey:@"players"];
                        if (![visibleTeamPlayers containsObject:player]) {
                            NSInteger unassignedPlayerIndexOffset = [visibleTeamPlayers count] + PLAYER_INDEX_OFFSET;
                            [toInsert addObject:[NSIndexPath indexPathForRow:[self.availablePlayers indexOfObject:player] + unassignedPlayerIndexOffset inSection:self.visibleTeamIndex]];
                        }
                    }
                }
            }
            if ([toInsert count]) {
                [self.tableView insertRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationTop];
            }
            break;
        }
        case NSKeyValueChangeRemoval: {
            NSArray *removed = [changeDictionary objectForKey:NSKeyValueChangeOldKey];
            [self stopObserversForPlayers:removed];
            NSMutableArray *toRemove = [[NSMutableArray alloc] initWithCapacity:[removed count]];
            for (FNPlayer *player in removed) {
                [self.availablePlayers removeObject:player];
                if (self.visibleTeam) {
                    NSArray *visibleTeamPlayers = [[self.dataSource objectAtIndex:self.visibleTeamIndex] objectForKey:@"players"];
                    if ([visibleTeamPlayers containsObject:player]) {
                        [toRemove addObject:[NSIndexPath indexPathForRow:[visibleTeamPlayers indexOfObject:player] + PLAYER_INDEX_OFFSET inSection:self.visibleTeamIndex]];
                    } else if ([self.availablePlayers containsObject:player]) {
                        NSInteger unassignedPlayerIndexOffset = [visibleTeamPlayers count] + PLAYER_INDEX_OFFSET;
                        [toRemove addObject:[NSIndexPath indexPathForRow:[self.availablePlayers indexOfObject:player] + unassignedPlayerIndexOffset inSection:self.visibleTeamIndex]];
                    }
                }
            }
            if ([toRemove count]) {
                [self.tableView deleteRowsAtIndexPaths:toRemove withRowAnimation:UITableViewRowAnimationBottom];
            }
            break;
        }
        case NSKeyValueChangeSetting: {
            // see if this looks good if not use more finesse by only removing and adding the changed players instead of all of them
            if (self.visibleTeam) {
                NSArray *visibleTeamPlayers = [[self.dataSource objectAtIndex:self.visibleTeamIndex] objectForKey:@"players"];
                NSInteger unassignedPlayerIndexOffset = [visibleTeamPlayers count] + PLAYER_INDEX_OFFSET;
                NSMutableArray *toDelete = [[NSMutableArray alloc] initWithCapacity:[self.availablePlayers count]];
                [self stopObserversForPlayers:[self.availablePlayers array]];
                for (FNPlayer *player in self.availablePlayers) {
                    [toDelete addObject:[NSIndexPath indexPathForRow:[self.availablePlayers indexOfObject:player] + unassignedPlayerIndexOffset inSection:self.visibleTeamIndex]];
                }
                if ([toDelete count]) {
                    [self.tableView deleteRowsAtIndexPaths:toDelete withRowAnimation:UITableViewRowAnimationTop];
                }
                self.availablePlayers = [changeDictionary objectForKey:NSKeyValueChangeNewKey];
                NSMutableArray *toInsert = [[NSMutableArray alloc] initWithCapacity:[self.availablePlayers count]];
                [self createObserversForPlayers:[self.availablePlayers array]];
                for (FNPlayer *player in self.availablePlayers) {
                    [toInsert addObject:[NSIndexPath indexPathForRow:[self.availablePlayers indexOfObject:player] + unassignedPlayerIndexOffset inSection:self.visibleTeamIndex]];
                }
                if ([toInsert count]) {
                    [self.tableView insertRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationTop];
                }
            } else {
                [self stopObserversForPlayers:[self.availablePlayers array]];
                self.availablePlayers = [changeDictionary objectForKey:NSKeyValueChangeNewKey];
                [self createObserversForPlayers:[self.availablePlayers array]];
            }
            break;
        }
        default:
            break;
    }
}

- (void)player:(FNPlayer *)player teamChangedFrom:(FNTeam *)fromTeam to:(FNTeam *)toTeam
{
    NSLog(@"player");
    // if i just have players auto assigned in the beginning and then only have assigned or not assigned do i need this???
    // this should only effect wether or not the player is in the available players and it's check mark style
}

- (void)setAssignmentIndicatorsForCellsAtIndexPaths:(NSArray *)indexPaths to:(BOOL)assigned
{
    // need to account for game assigned vs user assigned and change the arguement to an enum not bool and change the call in team:playersChanged
    UIImage *indicator;
    if (assigned) {
        indicator = [FNAppearance checkmarkWithStyle:FNCheckmarkStyleUser];
    } else {
        indicator = [[UIImage alloc] init];
    }
    for (NSIndexPath *indexPath in indexPaths) {
        FNSelectableCell *cell = (FNSelectableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.button setImage:indicator forState:UIControlStateNormal];
    }
}

- (FNTeam *)teamForSection:(NSInteger *)section
{
    return [[self.dataSource objectAtIndex:section] objectForKey:@"team"];
}

- (NSArray *)playersForTeam:(FNTeam *)team
{
    NSMutableOrderedSet *playersForTeam = [[NSMutableOrderedSet alloc] init];
    for (NSDictionary *dict in self.dataSource) {
        if ([dict objectForKey:@"team"] == team) {
            [playersForTeam addObjectsFromArray:[dict objectForKey:@"players"]];
            break;
        }
    }
    [playersForTeam unionOrderedSet:self.availablePlayers];
    return [playersForTeam array];
}

- (FNPlayer *)playerForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row - 2;
    NSArray *players = [self playersForTeam:[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"team"]];
    return [players objectAtIndex:index];
}


//- (NSMutableArray *)configureDataSource:(NSMutableArray*)data
//{
//    NSArray *sorted = [data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        NSString *first = ((FNPlayer *)obj1).team.name ? ((FNPlayer *)obj1).team.name : @"";
//        NSString *second = ((FNPlayer *)obj2).team.name ? ((FNPlayer *)obj2).team.name : @"";
//        return [first localizedCaseInsensitiveCompare:second];
//    }];
//    data = [sorted mutableCopy];
//    return data;
//}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    // if the textfield is active & the team is deleted by the stepper could go out of array bounds
    if ([self.brain.allTeams count] > textField.tag) {
        FNTeam *team = [self.brain.allTeams objectAtIndex:textField.tag];
        team.name = textField.text;
    }
    return YES;
}

- (void)playerAssignmentIndicatorPressed:(UIButton *)sender
{
    // figure out the current state then cycle it accordingly & set the properties & image
    FNSelectableCell *cell = ((FNSelectableCell *)sender.superview.superview);
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    FNPlayer *player = cell.objectForCell;
    FNTeam *team = [[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"team"];
    if (player.team == team) {
        // full release of player
        [self.brain unassignPlayer:player];
        [cell.button setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    } else {
        // user assigned team
        [self.brain assignPlayer:player toTeam:team];
        [cell.button setImage:[FNAppearance checkmarkWithStyle:FNCheckmarkStyleUser] forState:UIControlStateNormal];
    }
}

- (void)stepperDidStep:(UIStepper *)stepper
{
    if (stepper.value > [self.dataSource count]) {
        FNTeam *team = [[FNTeam alloc] init];
        team.name = [NSString stringWithFormat:@"Team %d", ([self.dataSource count] + 1)];
        [self.brain addTeam:team];
    } else if (stepper.value < [self.dataSource count]){
        [self.brain removeTeam:[[self.dataSource lastObject] objectForKey:@"team"]];
    }
}

- (void)refreshVisibleTeam
{
    if (self.visibleTeamIndex > 0) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = [self tableView:self.tableView numberOfRowsInSection:self.visibleTeamIndex] - 1; i > 1; i--) {
            [array addObject:[NSIndexPath indexPathForRow:i inSection:self.visibleTeamIndex]];
        }
        [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)toggleTeamForSection:(NSInteger)section
{
    // if anything is open close it. If selected is not open, open it.
    [CATransaction begin];
    NSInteger oldTeam = self.visibleTeamIndex;
    [CATransaction setCompletionBlock:^{
        NSIndexPath *index1 = [NSIndexPath indexPathForRow:0 inSection:section];
        UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:index1];
        [self setBackgroundForCell:cell1 atIndexPath:index1];
        if (oldTeam >= 0) {
            NSIndexPath *index2 = [NSIndexPath indexPathForRow:0 inSection:oldTeam];
            UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:index2];
            [self setBackgroundForCell:cell2 atIndexPath:index2];
        }
    }];
    [self.tableView beginUpdates];
    NSInteger currentlyVisible = self.visibleTeamIndex;
    // close the open team
    if (currentlyVisible >= 0) {
        // get the indexPaths for the open section & delete the rows
        NSMutableArray *array = [[NSMutableArray alloc] init];
        int rowsToDelete = [self tableView:self.tableView numberOfRowsInSection:currentlyVisible];
        for (int i = 1; i < rowsToDelete; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:currentlyVisible];
            [array addObject:path];
        }
        [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
        self.visibleTeamIndex = -1;
        self.visibleTeam = nil;
    }
    // open the team section
    if (section != currentlyVisible) {
        self.visibleTeamIndex = section;
        self.visibleTeam = [self teamForSection:section];
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
    [self toggleTeamForSection:indexPath.section];
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setHighlighted:YES animated:YES];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setHighlighted:NO animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // should never be called
}

#pragma mark - Move Table View

- (BOOL)canReorderTableView
{
    if (self.visibleTeamIndex >= 0) {
        return NO;
    }
    return YES;
}

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    FNTeam *movedTeam = self.brain.allTeams[fromIndexPath.section];
    [self.brain.allTeams removeObjectAtIndex:fromIndexPath.section];
    [self.brain.allTeams insertObject:movedTeam atIndex:toIndexPath.section];
    NSLog(@"Moved Team From Index: %d to %d", fromIndexPath.section, toIndexPath.section);
}

- (NSIndexPath *)moveTableView:(FMMoveTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row == 1) {
        proposedDestinationIndexPath = nil;
    }
	return proposedDestinationIndexPath;
}

/*
- (CGFloat)tableView:(FMMoveTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning Implement this check in your table view delegate if necessary
//     * Implement this check in your table view delegate to ensure correct access to the row heights in
//     * data source.
//     *
//     * SKIP this check if all of your rows have the same heigt!
//     *
//     * The data source is in a dirty state when moving a row and is only being updated after the user
//     * releases the moving row
    indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
	
    NSArray *movie = [[[self movies] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    CGFloat heightForRow = [[movie objectAtIndex:kIndexRowHeightOfMovie] floatValue];
    
    return heightForRow;
}
*/

// not implemented b/c if the row doesn't have a reorder control then is can't be moved
//- (BOOL)moveTableView:(FMMoveTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(FMMoveTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (section == self.visibleTeamIndex) {
        numberOfRows = 2 + [[self playersForTeam:[self teamForSection:section]] count];
    } else {
        numberOfRows = 1;
    }
    return numberOfRows;

    /******************************** NOTE ************************************************************
	 * Implement this check in your table view data source to ensure correct access to the data source
	 * The data source is in a dirty state when moving a row and is only being updated after the user
	 * releases the moving row
     * 1. A row is in a moving state
     * 2. The moving row is not in it's initial section
	 *************************************************************************************************/
//    if ([tableView movingIndexPath] && [[tableView movingIndexPath] section] != [[tableView initialIndexPathForMovingRow] section]) {
//		if (section == [[tableView movingIndexPath] section]) {
//			numberOfRows++;
//		} else if (section == [[tableView initialIndexPathForMovingRow] section]) {
//			numberOfRows--;
//		}
//	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header;
    if ([self.headerViews count] > section) {
        header = [self.headerViews objectAtIndex:section];
    } else {
        header = [[UIView alloc] init];
        header.backgroundColor = [UIColor clearColor];
        [self.headerViews insertObject:header atIndex:section];
    }
    return header;
}

- (UITableViewCell *)configureTeamReorderCellForIndexPath:(NSIndexPath *)indexPath
{
    FNReorderableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"reorderable"];
    FNTeam *team = [self teamForSection:indexPath.section];
    [self setBackgroundForCell:cell atIndexPath:indexPath];
    [cell.button setImage:[FNAppearance reorderControlImage] forState:UIControlStateNormal];
    cell.mainTextLabel.text = team.name;
    // Moving Table View Methods
    cell.shouldIndentWhileEditing = NO;
    cell.showsReorderControl = NO;
    [cell.button setHidden:NO];
    if ([(FMMoveTableView *)self.tableView indexPathIsMovingIndexPath:indexPath]) {
        [cell prepareForMove];
    }
    cell.showCellSeparator = NO;
    return cell;
}

- (UITableViewCell *)configureNameCellForIndexPath:(NSIndexPath *)indexPath
{
    FNEditableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TEXT_FIELD];
    FNTeam *team = [self teamForSection:indexPath.section];
    [self setBackgroundForCell:cell atIndexPath:indexPath];
    [self setBackgroundForTextField:cell.detailTextField];
    cell.detailTextField.delegate = self;
    cell.detailTextField.tag = indexPath.section;
    cell.mainTextLabel.text = @"name:";
    cell.detailTextField.text = team.name;
    cell.showCellSeparator = NO;
    cell.indentationLevel = 3;
    return cell;
}

- (UITableViewCell *)configurePlayerCellForIndexPath:(NSIndexPath *)indexPath
{
    FNSelectableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"selectable"];
    FNTeam *team = [self teamForSection:indexPath.section];
    [self setBackgroundForCell:cell atIndexPath:indexPath];
    [cell.button addTarget:self action:@selector(playerAssignmentIndicatorPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    FNPlayer *player = [self playerForIndexPath:indexPath];
    
    
    cell.objectForCell = player;
    if (player.team == team) {
        [cell.button setImage:[FNAppearance checkmarkWithStyle:FNCheckmarkStyleUser] forState:UIControlStateNormal];
    } else if ([team.players containsObject:player]) {
        [cell.button setImage:[FNAppearance checkmarkWithStyle:FNCheckmarkStyleGame] forState:UIControlStateNormal];
    } else {
        [cell.button setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    }
    cell.mainTextLabel.text = player.name;
    if (indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section] - 1) {
        cell.showCellSeparator = YES;
    } else {
        cell.showCellSeparator = NO;
    }
    cell.indentationLevel = 3;
    return cell;
}

- (FNTeamCellType)cellTypeForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return FNTeamCellTypeReorder;
    } else if (indexPath.row == 1) {
        return FNTeamCellTypeName;
    } else {
        return FNTeamCellTypePlayer;
    }
}

- (UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self cellTypeForIndexPath:indexPath] == FNTeamCellTypeReorder) {
        return [self configureTeamReorderCellForIndexPath:indexPath];
    } else if ([self cellTypeForIndexPath:indexPath] == FNTeamCellTypeName) {
        return [self configureNameCellForIndexPath:indexPath];
    } else {
        return [self configurePlayerCellForIndexPath:indexPath];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setup];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.brain setTeamOrder:self.brain.allTeams];
    [self tearDown];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.visibleTeamIndex = -1;
}

@end
