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
@end

static NSString * const AllTeamsKey = @"allTeams";
static NSString * const TeamOrderKey = @"teamOrder";
static NSString * const AllPlayersKey = @"allPlayers";
static NSString * const ScoreCardsKey = @"scoreCards";
static NSString * const UnplayedNounsKey = @"unplayedNouns";
static NSString * const PlayedNounsKey = @"playedNouns";
static NSString * const GameStatusKey = @"gameStatus";

@implementation FNBrain



- (FNPlayer *)nextPlayer
{
    NSAssert([self.allTeams count] > 0, @"Brain - Next Player was called but the Teams array is empty");
    // rotate teams
    FNTeam *nextTeam = self.allTeams[0];
    [self.allTeams removeObjectAtIndex:0];
    [self.allTeams addObject:nextTeam];
    // rotate players
    FNPlayer *nextPlayer = [nextTeam nextPlayer];
    return nextPlayer;
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
    [self addPlayerWithoutUpdate:player];
    [self.unplayedNouns addObjectsFromArray:player.nouns];
    FNUpdate *update = [FNUpdate updateForObject:nil updateType:FNUpdateTypePlayerAdd valueNew:player valueOld:nil];
    [self sendUpdate:update];
}

- (void)removePlayer:(FNPlayer *)player
{
    [self removePlayerWithoutUpdate:player];
    FNUpdate *update = [FNUpdate updateForObject:nil updateType:FNUpdateTypePlayerRemove valueNew:nil valueOld:player];
    [self sendUpdate:update];
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
    [self insertObject:team inAllTeamsAtIndex:[self.allTeams count]];
}

- (void)removeTeamWithoutUpdate:(FNTeam *)team
{
    [self removeObjectFromAllTeamsAtIndex:[self.allTeams indexOfObject:team]];
}

- (void)addTeam:(FNTeam *)team
{
    [self addTeamWithoutUpdate:team];
    FNUpdate *update = [FNUpdate updateForObject:nil updateType:FNUpdateTypeTeamAdd valueNew:team valueOld:nil];
    [self sendUpdate:update];
}

- (void)removeTeam:(FNTeam *)team
{
    [self removeTeamWithoutUpdate:team];
    FNUpdate *update = [FNUpdate updateForObject:nil updateType:FNUpdateTypeTeamRemove valueNew:nil valueOld:team];
    [self sendUpdate:update];
}


#pragma mark - Player Team Assignment





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
            [self removePlayerWithoutUpdate:update.valueOld];
            break;
        }
        case FNUpdateTypeTeamAdd: {
            [self addTeamWithoutUpdate:update.valueNew];
            break;
        }
        case FNUpdateTypeTeamRemove: {
            [self removeTeamWithoutUpdate:update.valueOld];
            break;
        }
            
        default:
            break;
    }
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











/*
 
 
 
 **** THe controllers will tell the brain what changes the controller wants and then KVO the model to update the UI
 the brain will dispatch the changes when it is asked to perform them create an object that represents a change
 
 
 
 Controllers Responding to Model Changes:
 
 the controller could get a copy the brain's allTeams array and use the copy to drive the controllers views and then KVO the brain's allTeams array (I guess i would KVO the allTeams array keypath on the brain (so KVO the brain))
 the controller would also KVO all the teams in its copy of the allTeams array to watch for player assignment changes
 then when a team was removed from the array (team deleted by a client) the controller would see that the brain's allTeams array changed
 the controller would then change its ui to remove the deleted team
 it would then stop observing the deleted team and then remove the team from the controllers local model
 this way i dont have to worry about an observed object being dealloc'd while I am still observing it
 
 Brain Responding & Forwarding Model Changes:
 
 Do the controllers explicitly tell the brain about the model changes or does the brain KVO to see model changes?
 How about when a player is assigned to a team?
 I can assign a player to a team by calling: - (void)assignPlayer:(FNPlayer *)player toTeam:(FNTeam *)team
 then the controller's KVO will see the change and update the UI
 
 
 In order for the above code to work the brain will have to be the automatic team assigner
 then you dont have competing view controllers thring to set the teams or conditionallu setting the teams ,,, kinda an issue
 that might work better anyway that way the brain will have all of the teams assignemnts and changes readily at hand
 the controller tells the brain to assign a player to a team it then un-autoassigns the player from other teams and reports that to the other connected games instead of the controller doin it... well either way it has to be done so what does it matter?
 
 the controller can then ask the brain for all of it's data instead of having to change the model just to show the model
 
 what would the controller do to get its data?
 well it gets the player assignments by looking at the all teams array
 three kinds of team assignments:
 1) player.team == team && [team.players containsObject:player]
 2) [team.players containsObject:player]
 3) there is no third option really the way I do it currently with the 3rd option is kinda bogus this should be changed so that when a player is selected an auto assigned player is deselected and all teams have to be even... well you might want uneven teams right... so if you dont auto assign teams then you have to completely custom assign teams and assign every player no half and half
 
 
 
 Why not have model objects post some kind of notice or call a method with a change object that conforms to a protocol that is then passed to the other brains and they know what to do with it to change the model and then the controllers (that are KVOing the model) will automatically change
 
 
 or the controllers could just change the model. the model objects could then go grab the shared multiplayer manager and send a change object to the manager that could then send the change object to the other managers and some how be dispatched to the model objects that will then in turn modify themselves -- have to make sure you have data integrity though what to do if someone deletes a team on one phone while some else assigns a player to that team so a team thinks it has a player that was just deleted…
 
 basically I want to instead of having the brain understand how the model obis work and manipulating their properties, i want the brain to just dispatch change object to the model objects that then change themselves. and have the model objects dispatch change objects to the brain
 
 the brain would then only need to know how to create and delete objects (b/c the objects can't do that themselves) could all this be handled by a superclass like the uniqueID class?
 
 how would this work when a new player is created?
 the controller would create the player object and set its nouns then pass it to the brain and call addPlayer:
 then the brain would make its own changeRecord and dispatch that to the remote users
 then call a method on the added object that would start it sending changeRecords to handle all subsequent changes on the object
 this way when the controller makes the player & then adds each noun to the player in turn the player is not already sending changeRecord calls before the brains even know that the new player exists this way the controllers can create scratch objects that can be created and deleted without concern
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 To KVO an array:
 You don't need an NSArrayController to observe changes to an NSArray. However you cannot directly observe these changes, i.e., you can't call -addObserver:forKeyPath:options:context: directly on an NSArray. In your case you want to call it on your GameModel with @"playerNameArray" as the key.
 
 You're not done yet though. The normal automatic KVO notifications will only kick in if you call -setPlayerNameArray:, thereby replacing the entire array. If you want more granular notifications, then you need to use -willChange:valuesAtIndexes:forKey: and -didChange:valuesAtIndexes:forKey: whenever you insert, remove, or replace items in that array.
 
 This will send a notification whenever the contents of the array changes. Depending on the NSKeyValueObservingOptions you use when adding your observer, you can also get the incremental changes that are made—a cool feature, but you may not need it in this case.
 
 OR
 
 You need to implement the indexed array accessors as defined in the KVC programming guide. Then you must use those accessors to access the array and the KVO triggering will work.
 @interface MyClass : NSObject
 {
 NSMutableArray *_orders;
 }
 
 @property(retain) NSMutableArray *orders;
 
 - (NSUInteger)countOfOrders;
 - (id)objectInOrdersAtIndex:(NSUInteger)index;
 - (void)insertObject:(id)obj inOrdersAtIndex:(NSUInteger)index;
 - (void)removeObjectFromOrdersAtIndex:(NSUInteger)index;
 - (void)replaceObjectInOrdersAtIndex:(NSUInteger)index withObject:(id)obj;
 
 
 */













