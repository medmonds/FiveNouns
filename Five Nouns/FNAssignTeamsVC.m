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
#import "FNAssignTeamsContainer.h"

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
  NOTES:
 
 
 
 ******************************************************************************************************/

#define PLAYER_INDEX_OFFSET 2

typedef NS_ENUM(NSInteger, FNTeamCellType) {
    FNTeamCellTypeNumberOfTeams,
    FNTeamCellTypeReorder,
    FNTeamCellTypeName,
    FNTeamCellTypePlayer
};

typedef NS_ENUM(NSInteger, FNAssignmentIndicatorStyle) {
    FNAssignmentIndicatorStyleUnassigned,
    FNAssignmentIndicatorStyleGame,
    FNAssignmentIndicatorStyleUser
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
    self.observers = nil;
    self.observedPlayers = nil;
    self.dataSource = nil;
    self.visibleTeam = nil;
    self.availablePlayers = nil;
    self.visibleTeamIndex = -1;
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
        [self.observers addObject:teamName];
        THObserver *teamPlayers = [THObserver observerForObject:team keyPath:@"players" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld target:self action:@selector(playersAssignedToTeam:keyPath:change:)];
        [self.observers addObject:teamPlayers];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"team" : team, @"players" : [team.players mutableCopy]}];
        [data addObject:dict];
    }
    return data;
}

- (void)stopObserversForTeams:(NSArray *)teams
{
    NSMutableSet *toRemove = [[NSMutableSet alloc] initWithCapacity:[teams count]];
    for (FNTeam *team in teams) {
        for (THObserver *observer in self.observers) {
            if (observer.observed == team) {
                [observer stopObserving]; // should not really need this !!!
                [toRemove addObject:observer];
            }
        }
    }
    [self.observers minusSet:toRemove];
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
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        [super setBackgroundForCell:cell atIndexPath:[self.tableView indexPathForCell:cell]];
    }
}

- (void)allTeamsChangedForBrain:(FNBrain *)brain keyPath:(NSString *)keypath change:(NSDictionary *)changeDictionary
{
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
            NSInteger currentIndex = [indexes firstIndex];
            NSInteger i, count = [indexes count];
            for (i = 0; i < count; i++) {
                if ([self teamForSection:currentIndex] != inserted[i]) {
                    [self.dataSource insertObject:[self createObserversAndDataObjectsForTeams:inserted][0] atIndex:currentIndex];
                    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:currentIndex] withRowAnimation:UITableViewRowAnimationTop];
                }
                currentIndex = [indexes indexGreaterThanIndex:currentIndex];
            }
            break;
        }
        case NSKeyValueChangeRemoval: {
            NSArray *removed = [changeDictionary objectForKey:NSKeyValueChangeOldKey];
            NSUInteger currentIndex = [indexes firstIndex];
            NSUInteger i, count = [indexes count];
            for (i = 0; i < count; i++) {
                if ([self teamForSection:currentIndex] == removed[i]) {
                    [self stopObserversForTeams:@[[[self.dataSource objectAtIndex:currentIndex] objectForKey:@"team"]]];
                    [self.dataSource removeObjectAtIndex:currentIndex];
                    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:currentIndex] withRowAnimation:UITableViewRowAnimationTop];
                }
                currentIndex = [indexes indexGreaterThanIndex:currentIndex];
            }
            break;
        }
        case NSKeyValueChangeReplacement: {
            NSArray *replacements = [changeDictionary objectForKey:NSKeyValueChangeNewKey];
            [self stopObserversForTeams:[self.dataSource objectsAtIndexes:indexes]];
            [self createObserversAndDataObjectsForTeams:replacements];
            [self.dataSource replaceObjectsAtIndexes:indexes withObjects:replacements];
            [self.tableView reloadSections:indexes withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        default:
            break;
    }
    self.visibleTeamIndex = [self sectionForTeam:self.visibleTeam];
    if (self.visibleTeamIndex == -1) {
        self.visibleTeam = nil;
    }
    [self.tableView endUpdates];
    [CATransaction commit];
    [((FNAssignTeamsContainer *)self.parentViewController) setStepperValue:[self.dataSource count]];
}

- (void)nameChangedForTeam:(FNTeam *)team keyPath:(NSString *)keyPath change:(NSDictionary *)changeDictionary
{
    NSLog(@"nameChangedForTeam");
    NSString *oldName = [changeDictionary objectForKey:NSKeyValueChangeOldKey];
    if ([oldName isEqualToString:team.name]) {
        return;
    }
    FNReorderableCell *cell = (FNReorderableCell  *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self sectionForTeam:team]]];
    [UIView animateWithDuration:.2 animations:^{
        cell.mainTextLabel.alpha = 0;
    } completion:^(BOOL finished) {
        cell.mainTextLabel.text = team.name;
        [UIView animateWithDuration:.2 animations:^{
            cell.mainTextLabel.alpha = 1;
        }];
    }];
}

- (void)playersAssignedToTeam:(FNTeam *)team keyPath:(NSString *)keyPath change:(NSDictionary *)changeDictionary
{
    NSKeyValueChange change = [[changeDictionary objectForKey:NSKeyValueChangeKindKey] integerValue];
    NSIndexSet *indexes = [changeDictionary objectForKey:NSKeyValueChangeIndexesKey];
    __block NSMutableArray *teamPlayers;
    [self.dataSource enumerateObjectsUsingBlock:^(NSMutableDictionary *dict, NSUInteger idx, BOOL *stop) {
        if (team == [dict objectForKey:@"team"]) {
            teamPlayers = [dict objectForKey:@"players"];
            *stop = YES;
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
            if (self.visibleTeam == team) {
                NSMutableArray *fromIndexes = [[NSMutableArray alloc] initWithCapacity:[assigned count]];
                for (FNPlayer *player in assigned) {
                    [fromIndexes addObject:[NSIndexPath indexPathForRow:[[self playersForTeam:team] indexOfObject:player] + PLAYER_INDEX_OFFSET inSection:self.visibleTeamIndex]];
                }
                [teamPlayers insertObjects:assigned atIndexes:indexes];
                [self setAssignmentIndicatorsForCellsAtIndexPaths:fromIndexes to:FNAssignmentIndicatorStyleGame];
                NSMutableArray *toIndexes = [[NSMutableArray alloc] initWithCapacity:[assigned count]];
                for (FNPlayer *player in assigned) {
                    [toIndexes addObject:[NSIndexPath indexPathForRow:[teamPlayers indexOfObject:player] + PLAYER_INDEX_OFFSET inSection:self.visibleTeamIndex]];
                }
                for (int i = 0; i < [toIndexes count]; i++) {
                    [self.tableView moveRowAtIndexPath:[fromIndexes objectAtIndex:i] toIndexPath:[toIndexes objectAtIndex:i]];
                }
            } else if (self.visibleTeamIndex >= 0) {
                NSMutableArray *refreshIndexes = [[NSMutableArray alloc] initWithCapacity:[assigned count]];
                for (FNPlayer *player in assigned) {
                    [refreshIndexes addObject:[NSIndexPath indexPathForRow:[[self playersForTeam:self.visibleTeam] indexOfObject:player] + PLAYER_INDEX_OFFSET inSection:self.visibleTeamIndex]];
                }
                [teamPlayers insertObjects:assigned atIndexes:indexes];
                [self setAssignmentIndicatorsForCellsAtIndexPaths:refreshIndexes to:FNAssignmentIndicatorStyleUnassigned];
            } else {
                [teamPlayers insertObjects:assigned atIndexes:indexes];
            }
            break;
        }
        case NSKeyValueChangeRemoval: {
            // players were removed from a team
            NSArray *unassigned = [changeDictionary objectForKey:NSKeyValueChangeOldKey];
            // the player is now available so add them to that part of the list
            if (self.visibleTeam == team) {
                // move the rows down to the bottom half
                NSMutableArray *fromIndexes = [[NSMutableArray alloc] initWithCapacity:[unassigned count]];
                for (FNPlayer *player in unassigned) {
                    [fromIndexes addObject:[NSIndexPath indexPathForRow:[[self playersForTeam:self.visibleTeam] indexOfObject:player] + PLAYER_INDEX_OFFSET inSection:self.visibleTeamIndex]];
                }
                [teamPlayers removeObjectsInArray:unassigned];
                [self setAssignmentIndicatorsForCellsAtIndexPaths:fromIndexes to:FNAssignmentIndicatorStyleUnassigned];
                NSMutableArray *toIndexes = [[NSMutableArray alloc] initWithCapacity:[unassigned count]];
                for (FNPlayer *player in unassigned) {
                    [toIndexes addObject:[NSIndexPath indexPathForRow:[[self playersForTeam:self.visibleTeam] indexOfObject:player] + PLAYER_INDEX_OFFSET inSection:self.visibleTeamIndex]];
                }
                for (int i = 0; i < [toIndexes count]; i++) {
                    [self.tableView moveRowAtIndexPath:[fromIndexes objectAtIndex:i] toIndexPath:[toIndexes objectAtIndex:i]];
                }
            } else if (self.visibleTeamIndex >= 0) {
                NSMutableArray *refreshIndexes = [[NSMutableArray alloc] initWithCapacity:[unassigned count]];
                for (FNPlayer *player in unassigned) {
                    [refreshIndexes addObject:[NSIndexPath indexPathForRow:[[self playersForTeam:self.visibleTeam] indexOfObject:player] + PLAYER_INDEX_OFFSET inSection:self.visibleTeamIndex]];
                }
                [teamPlayers insertObjects:unassigned atIndexes:indexes];
                [self setAssignmentIndicatorsForCellsAtIndexPaths:refreshIndexes to:FNAssignmentIndicatorStyleUnassigned];
                [teamPlayers removeObjectsInArray:unassigned];
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

- (void)allPlayersChangedForBrain:(FNBrain *)brain keyPath:(NSString *)keyPath change:(NSDictionary *)changeDictionary
{
    // only handle the change to available players here and adding or removing any observers        
    [self.tableView beginUpdates];
    NSKeyValueChange change = [[changeDictionary objectForKey:NSKeyValueChangeKindKey] integerValue];
    switch (change) {
        case NSKeyValueChangeInsertion: {
            NSArray *inserted = [changeDictionary objectForKey:NSKeyValueChangeNewKey];
            [self createObserversForPlayers:inserted];
            // this is all to be defensive in the case that the player was added to the team (and shown in the tableView) before this was called thid kind of defense is beeter implemented in the brain
            for (FNPlayer *player in inserted) {
                if (player.team == nil) {
                    [self.availablePlayers addObject:player];
                    if (self.visibleTeam) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[self playersForTeam:self.visibleTeam] indexOfObject:player] inSection:self.visibleTeamIndex];
                        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                    }
                }
            }
            break;
        }
        case NSKeyValueChangeRemoval: {
            NSArray *removed = [changeDictionary objectForKey:NSKeyValueChangeOldKey];
            [self stopObserversForPlayers:removed];
            NSArray *visiblePlayers = [self playersForTeam:self.visibleTeam];
            for (FNPlayer *player in removed) {
                NSInteger index = [visiblePlayers indexOfObject:player];
                if (visiblePlayers && index != NSNotFound) {
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index + PLAYER_INDEX_OFFSET inSection:self.visibleTeamIndex]] withRowAnimation:UITableViewRowAnimationBottom];
                }
            }
            [self.availablePlayers removeObjectsInArray:removed];
            break;
        }
        case NSKeyValueChangeSetting: {
            // see if this looks good if not use more finesse by only removing and adding the changed players instead of all of them
            // change this to so that is doesnt create an array of things to update and then update them just do it all in 1 loop
            if (self.visibleTeam) {
                NSArray *visibleTeamPlayers = [[self.dataSource objectAtIndex:self.visibleTeamIndex] objectForKey:@"players"];
                NSInteger unassignedPlayerIndexOffset = [visibleTeamPlayers count] + PLAYER_INDEX_OFFSET;
                NSMutableArray *toDelete = [[NSMutableArray alloc] initWithCapacity:[self.availablePlayers count]];
                [self stopObserversForPlayers:[self.availablePlayers array]];
                for (FNPlayer *player in self.availablePlayers) {
                    
//                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self playersForTeam:self.visibleTeam] index inSection:<#(NSInteger)#>]] withRowAnimation:<#(UITableViewRowAnimation)#>]
                    
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
    [self.tableView endUpdates];
    [self refreshCells];
    [((FNAssignTeamsContainer *)self.parentViewController) setStepperMaxValue:MIN(6, [self.brain.allPlayers count])];
}

- (void)player:(FNPlayer *)player teamChangedFrom:(FNTeam *)fromTeam to:(FNTeam *)toTeam
{
    NSLog(@"player's team changed");
    NSAssert(toTeam && fromTeam, @"a player's team was changed from one team to another not just assigned or unassigned");
    if (self.visibleTeam == toTeam) {
        // remove from availablePlayers && refresh the assignmentIndicator - the player has already been moved to the proper location by team assignment
        [self.availablePlayers removeObject:player];
        NSIndexPath *playerIndexPath = [NSIndexPath indexPathForRow:[[self playersForTeam:self.visibleTeam] indexOfObject:player] + PLAYER_INDEX_OFFSET inSection:self.visibleTeamIndex];
        [self setAssignmentIndicatorsForCellsAtIndexPaths:@[playerIndexPath] to:FNAssignmentIndicatorStyleUser];
    } else if (self.visibleTeam == fromTeam) {
        // add the player to the availablePlayers list && make sure the indicator is the proper color (refresh cell indicator)
        [self.availablePlayers addObject:player];
        NSIndexPath *playerIndexPath = [NSIndexPath indexPathForRow:[[self playersForTeam:self.visibleTeam] indexOfObject:player] + PLAYER_INDEX_OFFSET inSection:self.visibleTeamIndex];
        [self setAssignmentIndicatorsForCellsAtIndexPaths:@[playerIndexPath] to:FNAssignmentIndicatorStyleUnassigned];
    } else if (self.visibleTeam) {
        // add the player to the availablePlayers list && add the row at the button
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self refreshCells];
        }];
        [self.tableView beginUpdates];
        if (toTeam && toTeam != (id)[NSNull null]) { // if (toTeam && !fromTeam) !!!
            // the player was visible and should no longer be
            NSIndexPath *playerIndexPath = [NSIndexPath indexPathForRow:[[self playersForTeam:self.visibleTeam] indexOfObject:player] + PLAYER_INDEX_OFFSET inSection:self.visibleTeamIndex];
            [self.tableView deleteRowsAtIndexPaths:@[playerIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            [self.availablePlayers removeObject:player];
        } else {
            [self.availablePlayers addObject:player];
            NSIndexPath *playerIndexPath = [NSIndexPath indexPathForRow:[[self playersForTeam:self.visibleTeam] indexOfObject:player] + PLAYER_INDEX_OFFSET inSection:self.visibleTeamIndex];
            [self.tableView insertRowsAtIndexPaths:@[playerIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
        [self.tableView endUpdates];
        [CATransaction commit];
    } else {
        // add or remove the player from availablePlayers as appropriate
        if (fromTeam) {
            [self.availablePlayers addObject:player];
        } else {
            [self.availablePlayers removeObject:player];
        }
    }
    
}

- (void)setAssignmentIndicatorsForCellsAtIndexPaths:(NSArray *)indexPaths to:(FNAssignmentIndicatorStyle)style
{
    // need to account for game assigned vs user assigned and change the arguement to an enum not bool and change the call in team:playersChanged
    UIImage *indicator;
    switch (style) {
        case FNAssignmentIndicatorStyleUnassigned: {
            indicator = [[UIImage alloc] init];
            break;
        }
        case FNAssignmentIndicatorStyleGame: {
            indicator = [FNAppearance checkmarkWithStyle:FNCheckmarkStyleGame];
            break;
        }
        case FNAssignmentIndicatorStyleUser: {
            indicator = [FNAppearance checkmarkWithStyle:FNCheckmarkStyleUser];
            break;
        }
        default:
            break;
    }
    for (NSIndexPath *indexPath in indexPaths) {
        FNSelectableCell *cell = (FNSelectableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.button setImage:indicator forState:UIControlStateNormal];
    }
}

- (NSInteger)sectionForTeam:(FNTeam *)team
{
    NSInteger section = -1;
    NSInteger teamCount = [self.dataSource count];
    for (NSInteger i = 0; i < teamCount; i++) {
        if ([[self.dataSource objectAtIndex:i] objectForKey:@"team"] == team) {
            section = i;
            break;
        }
    }
    return section;
}

- (FNTeam *)teamForSection:(NSInteger *)section
{
    if ([self.dataSource count] > (NSUInteger)section) {
        return [[self.dataSource objectAtIndex:section] objectForKey:@"team"];
    } else {
        return nil;
    }
}

- (NSArray *)playersForTeam:(FNTeam *)team
{
    if (!team) return nil;
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

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self.brain setName:textField.text forTeam:[self teamForSection:textField.tag]];
    return YES;
}

- (void)playerAssignmentIndicatorPressed:(UIButton *)sender
{
    FNSelectableCell *cell = ((FNSelectableCell *)sender.superview.superview);
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    FNPlayer *player = [self playerForIndexPath:indexPath];
//    FNPlayer *player = cell.objectForCell;
    FNTeam *team = [[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"team"];
    if (player.team == team) {
        [self.brain unassignTeamFromPlayer:player];
    } else {
        [self.brain assignTeam:team toPlayer:player];
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

- (void)toggleTeamForSection:(NSInteger)section
{
    // if anything is open close it. If selected is not open, open it.
    [CATransaction begin];
    NSInteger oldTeam = self.visibleTeamIndex;
    [CATransaction setCompletionBlock:^{
        NSIndexPath *index1 = [NSIndexPath indexPathForRow:0 inSection:section];
        UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:index1];
        [self setBackgroundForCell:cell1 atIndexPath:index1];
        if (oldTeam >= 0) { // if there was an old visible team
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
        FNSeparatorCell *cell = (FNSeparatorCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:currentlyVisible]];
        cell.showCellSeparator = NO;
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
        if ([array count]) { // this will always be true b/c of the way the name is edited
            UITableViewCell *topCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
            [super setBackgroundForCell:topCell withPosition:FNTableViewCellPositionTop];
            [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
        }
        FNSeparatorCell *cell = (FNSeparatorCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        cell.showCellSeparator = YES;
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
    NSDictionary *movedData = self.dataSource[fromIndexPath.section];
    [self.dataSource removeObjectAtIndex:fromIndexPath.section];
    [self.dataSource insertObject:movedData atIndex:toIndexPath.section];
    [self.brain moveTeam:[movedData objectForKey:@"team"] toIndex:toIndexPath.section];
    NSLog(@"Moved Team: %@ From Index: %d to %d", ((FNTeam *)[movedData objectForKey:@"team"]).name, fromIndexPath.section, toIndexPath.section);
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
        numberOfRows = 2 + [[self playersForTeam:self.visibleTeam] count];
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


// these methods need to be looking into the dataSource dictionaries not team.players !!!
- (UITableViewCell *)configurePlayerCellForIndexPath:(NSIndexPath *)indexPath
{
    FNSelectableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"selectable"];
    FNTeam *team = [self teamForSection:indexPath.section];
    [self setBackgroundForCell:cell atIndexPath:indexPath];
    [cell.button addTarget:self action:@selector(playerAssignmentIndicatorPressed:) forControlEvents:UIControlEventTouchUpInside];
    FNPlayer *player = [self playerForIndexPath:indexPath];
//    cell.objectForCell = player;
    if (player.team == team) {
        [cell.button setImage:[FNAppearance checkmarkWithStyle:FNCheckmarkStyleUser] forState:UIControlStateNormal];
    } else if ([team.players containsObject:player]) {
        [cell.button setImage:[FNAppearance checkmarkWithStyle:FNCheckmarkStyleGame] forState:UIControlStateNormal];
    } else {
        [cell.button setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    }
    cell.showCellSeparator = NO;
    cell.mainTextLabel.text = player.name;
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
    [self tearDown];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.visibleTeamIndex = -1;
}

@end
