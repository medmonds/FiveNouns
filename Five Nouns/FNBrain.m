//
//  FNBrain.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/12/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNBrain.h"
#import "FNScoreCard.h"
#import "FNPlayer.h"
#import "FNTeam.h"
#import "FNUpdate.h"
#import "FNAddPlayersContainer.h"

@interface FNBrain ()
@property (nonatomic, strong) NSMutableSet *unplayedNouns;
@property (nonatomic, strong) NSMutableSet *playedNouns;
@property (nonatomic, strong) NSMutableArray *scoreCards;
@property (nonatomic, strong) NSNumber *gameStatus;
@property (nonatomic, strong) NSArray *teamOrder;
@property (nonatomic, strong) FNPlayer *player;
@end

static NSString * const AllTeamsKey = @"allTeams";
static NSString * const TeamOrderKey = @"teamOrder";
static NSString * const AllPlayersKey = @"allPlayers";
static NSString * const ScoreCardsKey = @"scoreCards";
static NSString * const UnplayedNounsKey = @"unplayedNouns";
static NSString * const PlayedNounsKey = @"playedNouns";
static NSString * const GameStatusKey = @"gameStatus";

@implementation FNBrain


- (FNPlayer *)player
{
    if (!_player) {
        _player = [((FNTeam *)self.allTeams[0]) nextPlayer];
    }
    return _player;
}

- (FNPlayer *)nextPlayer
{
    NSAssert([self.allTeams count] > 0, @"Brain - Next Player was called but the Teams array is empty");
    // rotate teams
    FNTeam *nextTeam = self.allTeams[0];
    [self.allTeams removeObjectAtIndex:0];
    [self.allTeams addObject:nextTeam];
    // rotate players
    FNPlayer *nextPlayer = [self.allTeams[0] nextPlayer];
    self.player = nextPlayer;
    return nextPlayer;
}

- (FNPlayer *)currentPlayer
{
    return self.player;
}

- (void)prepareForNewRound
{
    [self.unplayedNouns unionSet:self.playedNouns];
}

- (void)returnUnplayedNoun:(NSString *)noun
{
    [self.unplayedNouns addObject:noun];
}

- (NSMutableSet *)unplayedNouns
{
    if (!_unplayedNouns) {
        _unplayedNouns = [[NSMutableSet alloc] init];
    }
    return _unplayedNouns;
}

- (NSMutableSet *)playedNouns
{
    if (!_playedNouns) {
        _playedNouns = [[NSMutableSet alloc] init];
    }
    return _playedNouns;
}

- (NSString *)noun
{
    NSString *noun = [self.unplayedNouns anyObject];
    if (noun) {
        [self.unplayedNouns removeObject:noun];
        [self.playedNouns addObject:noun];
    }
    return noun;
}

#pragma mark - Players

- (NSMutableArray *)allPlayers
{
    if (!_allPlayers) {
        _allPlayers = [[NSMutableArray alloc] init];
    }
    return _allPlayers;
}

- (NSUInteger)countOfAllPlayers
{
    return [self.allPlayers count];
}

- (FNPlayer *)objectInAllPlayersAtIndex:(NSUInteger)index
{
    return [self.allPlayers objectAtIndex:index];
}

- (void)insertObject:(FNPlayer *)object inAllPlayersAtIndex:(NSUInteger)index
{
    [self.allPlayers insertObject:object atIndex:index];
}

- (void)removeObjectFromAllPlayersAtIndex:(NSUInteger)index
{
    [self.allPlayers removeObjectAtIndex:index];
}

- (void)addPlayerWithoutUpdate:(FNPlayer *)player
{
    [self insertObject:player inAllPlayersAtIndex:[self.allPlayers count]];
    [self.unplayedNouns addObjectsFromArray:player.nouns];
}

- (void)removePlayerWithoutUpdate:(FNPlayer *)player
{
    [self removeObjectFromAllPlayersAtIndex:[self.allPlayers indexOfObject:player]];
}

- (void)addPlayer:(FNPlayer *)player
{
    [self sendUpdate:[FNUpdate updateForObject:nil updateType:FNUpdateTypePlayerAdd valueNew:player valueOld:nil]];
    [self addPlayerWithoutUpdate:player];
}

- (void)removePlayer:(FNPlayer *)player
{
    [self sendUpdate:[FNUpdate updateForObject:nil updateType:FNUpdateTypePlayerRemove valueNew:nil valueOld:player]];
    [self removePlayerWithoutUpdate:player];
}

#pragma mark - Teams

- (NSMutableArray *)allTeams
{
    if (!_allTeams) {
        _allTeams = [[NSMutableArray alloc] init];
    }
    return _allTeams;
}

- (NSUInteger)countOfAllTeams
{
    return [self.allPlayers count];
}

- (FNTeam *)objectInAllTeamsAtIndex:(NSUInteger)index
{
    return [self.allTeams objectAtIndex:index];
}

- (void)insertObject:(FNTeam *)object inAllTeamsAtIndex:(NSUInteger)index
{
    [self.allTeams insertObject:object atIndex:index];
}

- (void)removeObjectFromAllTeamsAtIndex:(NSUInteger)index
{
    [self.allTeams removeObjectAtIndex:index];
}

- (void)addTeamWithoutUpdate:(FNTeam *)team
{
    NSInteger oldCount = [self.allTeams count];
    [self insertObject:team inAllTeamsAtIndex:[self.allTeams count]];
    self.teamOrder = self.allTeams;
    [self assignPlayersToTeam:team OldTeamsCount:oldCount];
}

- (void)removeTeamWithoutUpdate:(FNTeam *)team
{
    NSInteger oldCount = [self.allTeams count];
    [self removeObjectFromAllTeamsAtIndex:[self.allTeams indexOfObject:team]];
    self.teamOrder = self.allTeams;
    for (FNPlayer *player in team.players) {
        player.team = nil;
    }
    [self assignPlayersToTeam:team OldTeamsCount:oldCount];
}

- (void)addTeam:(FNTeam *)team
{
    [self sendUpdate:[FNUpdate updateForObject:nil updateType:FNUpdateTypeTeamAdd valueNew:team valueOld:nil]];
    [self addTeamWithoutUpdate:team];
}

- (void)removeTeam:(FNTeam *)team
{
    [self sendUpdate:[FNUpdate updateForObject:nil updateType:FNUpdateTypeTeamRemove valueNew:nil valueOld:team]];
    [self removeTeamWithoutUpdate:team];
}

- (void)setName:(NSString *)name forTeam:(FNTeam *)team
{
    [self sendUpdate:[FNUpdate updateForObject:team updateType:FNUpdateTypeTeamName valueNew:name valueOld:nil]];
    [self setNameWithoutUpdate:name forTeam:team];
}

- (void)setNameWithoutUpdate:(NSString *)name forTeam:(FNTeam*)team
{
    team.name = name;
}

- (void)moveTeam:(FNTeam *)team toIndex:(NSInteger)newIndex
{
    [self sendUpdate:[FNUpdate updateForObject:team updateType:FNUpdateTypeTeamOrder valueNew:@(newIndex) valueOld:nil]];
    [self moveTeamWithoutUpdate:team toIndex:newIndex];
}

- (void)moveTeamWithoutUpdate:(FNTeam *)team toIndex:(NSInteger)newIndex
{
    [self removeObjectFromAllTeamsAtIndex:[self.allTeams indexOfObject:team]];
    [self insertObject:team inAllTeamsAtIndex:newIndex];
    self.teamOrder = self.allTeams;
}

- (NSArray *)orderOfTeams
{
    return self.teamOrder;
}


#pragma mark - Player Team Assignment

- (void)assignPlayersToTeam:(FNTeam *)team OldTeamsCount:(NSInteger)oldCount
{
    // this needs to trigger calls about player assignement changes and team assignment changes !!!    
    if (!oldCount) {
        // this is the one and only team so add all players to the team
        [team addTeamPlayers:self.allPlayers];
    } else if (oldCount < [self.allTeams count]) {
        // the passed in team was added so add players to it
        NSInteger allTeams = [self.allTeams count] ? [self.allTeams count] : 1;
        oldCount = oldCount ? oldCount : 1;
        NSInteger countPlayersNeeded = ceil(([self.allPlayers count] / (float)oldCount) - ([self.allPlayers count] / (float)allTeams));
        NSMutableArray *playersForNewTeam = [[NSMutableArray alloc] initWithCapacity:countPlayersNeeded];
        // to stop an infinite loop if it can't find players
        // the plus 1s (+ 1)s are sloppy looking !!!
        NSInteger beforeCount = -1;
        NSArray *sortedTeams = [self.allTeams sortedArrayUsingComparator:^NSComparisonResult(FNTeam *team1, FNTeam *team2) {
            if ([team1.players count] < [team2.players count]) {
                return NSOrderedDescending;
            } else if ([team1.players count] > [team2.players count]) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
        while (([playersForNewTeam count] + 1) < (countPlayersNeeded + 1) && ([playersForNewTeam count] + 1) > (beforeCount + 1)) {
            beforeCount = [playersForNewTeam count];
            [sortedTeams enumerateObjectsUsingBlock:^(FNTeam *otherTeam, NSUInteger idx, BOOL *stop) {
                // if the player is not assigned to the team
                FNPlayer *player = [otherTeam.players lastObject];
                if (![player.team isEqual:otherTeam] && player) {
                    [playersForNewTeam addObject:player];
                    [otherTeam removePlayer:player];
                    if ([playersForNewTeam count] == countPlayersNeeded) {
                        *stop = YES;
                    }
                }
            }];
        }
        [team addTeamPlayers:playersForNewTeam];
    } else if ([self.allTeams count]) {
        // the passed in team was removed so pull the players from it and reassign them. the controllers have already been told the team was removed so they are no longer observing it
        // but have to make sure there is a team to add the players too
        NSMutableArray *playersFromOldTeam = [team.players mutableCopy];
        while ([playersFromOldTeam count]) {
            [self.allTeams enumerateObjectsUsingBlock:^(FNTeam *team, NSUInteger idx, BOOL *stop) {
                [team addPlayer:[playersFromOldTeam lastObject]];
                [playersFromOldTeam removeLastObject];
                if (![playersFromOldTeam count]) {
                    *stop = YES;
                }
            }];
        }
    }
}

- (void)assignTeamWithoutUpdate:(FNTeam *)team toPlayer:(FNPlayer *)player;
{
    for (FNTeam *aTeam in self.allTeams) {
        if (![aTeam isEqual:team] && [aTeam.players containsObject:player]) {
            [aTeam removePlayer:player];
            break;
        }
    }
    [team addPlayer:player];
    player.team = team;
}

- (void)assignTeam:(FNTeam *)team toPlayer:(FNPlayer *)player;
{
    [self sendUpdate:[FNUpdate updateForObject:player updateType:FNUpdateTypeTeamToPlayer valueNew:team valueOld:nil]];
    [self assignTeamWithoutUpdate:team toPlayer:player];
}

- (void)unassignTeamFromPlayerWithoutUpdate:(FNPlayer *)player
{
    FNTeam *oldTeam = player.team;
    player.team = nil;
    [oldTeam removePlayer:player];
}

- (void)unassignTeamFromPlayer:(FNPlayer *)player;
{
    [self sendUpdate:[FNUpdate updateForObject:player updateType:FNUpdateTypeTeamToPlayer valueNew:nil valueOld:player.team]];
    [self unassignTeamFromPlayerWithoutUpdate:player];
}

- (NSMutableArray *)scoreCards
{
    if (!_scoreCards) {
        _scoreCards = [[NSMutableArray alloc] init];
    }
    return _scoreCards;
}

- (void)addScoreCard:(FNScoreCard *)scoreCard
{
    if (scoreCard) [self.scoreCards addObject:scoreCard];
}

- (NSArray *)allScoreCards
{
    NSArray *cards = [self.scoreCards copy];
    return cards;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.gameStatus = @(FNGameStatusNotStarted);
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.allPlayers = [aDecoder decodeObjectForKey:AllPlayersKey];
    self.allTeams = [aDecoder decodeObjectForKey:AllTeamsKey];
    self.teamOrder = [aDecoder decodeObjectForKey:TeamOrderKey];
    self.unplayedNouns = [aDecoder decodeObjectForKey:UnplayedNounsKey];
    self.playedNouns = [aDecoder decodeObjectForKey:PlayedNounsKey];
    self.scoreCards = [aDecoder decodeObjectForKey:ScoreCardsKey];
    self.gameStatus = [aDecoder decodeObjectForKey:GameStatusKey];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.allPlayers forKey:AllPlayersKey];
    [aCoder encodeObject:self.allTeams forKey:AllTeamsKey];
    [aCoder encodeObject:self.teamOrder forKey:TeamOrderKey];
    [aCoder encodeObject:self.unplayedNouns forKey:UnplayedNounsKey];
    [aCoder encodeObject:self.playedNouns forKey:PlayedNounsKey];
    [aCoder encodeObject:self.scoreCards forKey:ScoreCardsKey];
    [aCoder encodeObject:self.gameStatus forKey:GameStatusKey];
}

- (void)saveCurrentTurn:(FNTurnData *)turn
{
    // this will be saved more frequently then the rest of the game data
    // game data will be saved after every turn ends
    // then this info + the rest of the game data will make a whole game
    // can then just rotate through nouns and players in the game data to match the turn data and then have complete picture again
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *turnDataFile = [documentsDirectory stringByAppendingPathComponent:@"turnData.fiveNouns"];
    BOOL success = [NSKeyedArchiver archiveRootObject:turn toFile:turnDataFile];
    NSLog(@"Saved turn data: %d", success);
}

- (void)saveGameData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *gameDataFile = [documentsDirectory stringByAppendingPathComponent:@"gameData.fiveNouns"];
    BOOL success = [NSKeyedArchiver archiveRootObject:self toFile:gameDataFile];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSLog(@"Brain Size: %d", [data length]);
    NSLog(@"Saved game data: %d", success);
}

+ (FNBrain *)brainFromPreviousGame
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *gameDataFile = [documentsDirectory stringByAppendingPathComponent:@"gameData.fiveNouns"];
    FNBrain *previousBrain = [NSKeyedUnarchiver unarchiveObjectWithFile:gameDataFile];
    return previousBrain;
}

- (NSDictionary *)currentGameState
{
    // why do i make them nsdata?? !!!
    // dont forget about current turn state & if the game has started
    NSData *allTeams = [NSKeyedArchiver archivedDataWithRootObject:self.allTeams];
    NSData *teamOrder = [NSKeyedArchiver archivedDataWithRootObject:self.teamOrder];
    NSData *allPlayers = [NSKeyedArchiver archivedDataWithRootObject:self.allPlayers];
    NSData *scoreCards = [NSKeyedArchiver archivedDataWithRootObject:self.scoreCards];
    NSData *unplayedNouns = [NSKeyedArchiver archivedDataWithRootObject:self.unplayedNouns];
    NSData *playedNouns = [NSKeyedArchiver archivedDataWithRootObject:self.playedNouns];
    NSData *gameStatus = [NSKeyedArchiver archivedDataWithRootObject:self.gameStatus];
    
    NSDictionary *gameState = @{AllTeamsKey : allTeams, TeamOrderKey : teamOrder, AllPlayersKey : allPlayers, ScoreCardsKey : scoreCards, UnplayedNounsKey : unplayedNouns, PlayedNounsKey : playedNouns, GameStatusKey : gameStatus};
    return gameState;
}

- (void)didConnectToClient:(NSString *)peerID
{
    FNUpdate *update = [[FNUpdate alloc] init];
    update.updateType = FNUpdateTypeEverything;
    update.valueNew = [self currentGameState];
    [self sendUpdate:update];
    // need to handle if this send fails well if all sends fail i guess !!!
}

- (void)sendUpdate:(FNUpdate *)update
{
    BOOL success = [[FNMultiplayerManager sharedMultiplayerManager] sendUpdate:update];
}

// do i need this method if i use isEqual everywhere?
- (FNTeam *)localTeamForTeamFromUpdate:(FNTeam *)updateTeam
{
    FNTeam *localTeam;
    for (FNTeam *team in self.allTeams) {
        if ([team isEqual:updateTeam]) {
            localTeam = team;
            break;
        }
    }
    return localTeam;
}

- (FNPlayer *)localPlayerForPlayerFromUpdate:(FNPlayer *)updatePlayer
{
    FNPlayer *localPlayer;
    for (FNPlayer *player in self.allPlayers) {
        if ([player isEqual:updatePlayer]) {
            localPlayer = player;
            break;
        }
    }
    return localPlayer;
}

- (void)handleUpdate:(FNUpdate *)update
{
    switch (update.updateType) {
        case FNUpdateTypeEverything: {
            // Just received a wholesale update from the game server
            [update.valueNew enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                id object = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
                [self setValue:object forKey:key];
            }];
            [self updateUIForGameStatus];
            break;
        }
        case FNUpdateTypePlayerAdd: {
            [self addPlayerWithoutUpdate:update.valueNew];
            break;
        }
        case FNUpdateTypePlayerRemove: {
            [self removePlayerWithoutUpdate:[self localPlayerForPlayerFromUpdate:update.valueOld]];
            break;
        }
        case FNUpdateTypeTeamAdd: {
            [self addTeamWithoutUpdate:update.valueNew];
            break;
        }
        case FNUpdateTypeTeamRemove: {
            [self removeTeamWithoutUpdate:[self localTeamForTeamFromUpdate:update.valueOld]];
            break;
        }
        case FNUpdateTypeTeamName: {
            [self setNameWithoutUpdate:update.valueNew forTeam:[self localTeamForTeamFromUpdate:update.valueNew]];
        }
        case FNUpdateTypeTeamOrder: {
            [self moveTeamWithoutUpdate:[self localTeamForTeamFromUpdate:update.updatedObject] toIndex:[update.valueNew integerValue]];
        }
        case FNUpdateTypeTeamToPlayer: {
            // check to make sure the player is currently assigned to the team to be unassigned from (per update) before unassigning the player if it is not then what? !!!
            FNPlayer *player = [self localPlayerForPlayerFromUpdate:update.updatedObject];
            if (update.valueNew) {
                FNTeam *newTeam = [self localTeamForTeamFromUpdate:update.valueNew];
                if (![newTeam isEqual:player.team]) {
                    [self assignTeamWithoutUpdate:newTeam toPlayer:player];
                } else {
                    // handle this better !!!
                    [NSException raise:@"Invalid Update" format:@"Player from update: %@ already assigned to team.", update];
                }
            } else {
                FNTeam *oldTeam = [self localTeamForTeamFromUpdate:update.valueOld];
                if ([oldTeam isEqual:player.team]) {
                    [self unassignTeamFromPlayerWithoutUpdate:player];
                } else {
                    [NSException raise:@"Invalid Update" format:@"Player from update: %@ not assigned to team.", update];
                }
            }
        }
        case FNUpdateTypePlayerToTeam: {
            
        }
            
        default:
            break;
    }
}

- (void)gameStatus:(FNGameStatus)status
{
    self.gameStatus = @(status);
}

- (void)updateUIForGameStatus
{
    switch ([self.gameStatus integerValue]) {
        case FNGameStatusNotStarted: {
            // trigger a segue to the addPlayers Screen
            FNAddPlayersContainer *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"addPlayerContainer"];
            vc.brain = self;
            [self.navController pushViewController:vc animated:YES];
            break;
        }
        case FNGameStatusStarted:
            // trigger a segue to the NextUp Screen
            break;
            
        case FNGameStatusTurnInProgress:
            // trigger a segue to the gameVC
            break;
            
        default:
            break;
    }
}

@end








//// called when a team is added
//- (void)assignPlayersToTeams
//{
//    // removing players from teams where player doesnt want to be on the team
//    NSMutableArray *playersToAssign = [[NSMutableArray alloc] init];
//    [self.allTeams enumerateObjectsUsingBlock:^(FNTeam *team, NSUInteger idx, BOOL *stop) {
//       [team.players enumerateObjectsUsingBlock:^(FNPlayer *player, NSUInteger idx, BOOL *stop) {
//           if (player.team != team) {
//               [playersToAssign addObject:player];
//           }
//       }];
//    }];
//    if ([self.allTeams count]) {
//        NSInteger playersPerTeam = [self.allPlayers count] / [self.allTeams count];
//        [self.allTeams enumerateObjectsUsingBlock:^(FNTeam *team, NSUInteger idx, BOOL *stop) {
//            for (int i = [team.players count]; i < playersPerTeam; i++) {
//                [team addPlayer:playersToAssign[0]];
//                [playersToAssign removeObjectAtIndex:0];
//            }
//        }];
//        // to assign any left over players
//        [playersToAssign enumerateObjectsUsingBlock:^(FNPlayer *player, NSUInteger idx, BOOL *stop) {
//            [[self.allTeams objectAtIndex:idx] addPlayer:player];
//        }];
//    }
//}


/*
 or i could get old number of teams and the new number of teams and then
 if a team was added grab the last ([allPlayer count] / [allTeams count](new) - [allPlayer count] / [oldAllTeams count]
 and then assign those people to the new team
 I would have to account for players that might have been assigned to the existing teams already
 so what sweep through each team trying to grab the last player until I had as many players as I needed for the new team
 
 */












