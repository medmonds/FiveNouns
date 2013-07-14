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

@interface FNBrain ()
@property (nonatomic, strong) NSMutableSet *unplayedNouns;
@property (nonatomic, strong) NSMutableSet *playedNouns;
@property (nonatomic, strong) NSMutableArray *scoreCards;
@end

@implementation FNBrain

/*
 
 
*/

- (FNPlayer *)nextPlayer
{
    // Assert that these are not empty arrays!!
    
    // rotate teams
    FNTeam *nextTeam = self.allTeams[0];
    [self.allTeams removeObjectAtIndex:0];
    [self.allTeams addObject:nextTeam];
    
    // rotate players
    FNPlayer *nextPlayer = nextTeam.players[0];
    [nextTeam.players removeObjectAtIndex:0];
    [nextTeam.players addObject:nextPlayer];
    
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

- (NSMutableArray *)allPlayers
{
    if (!_allPlayers) {
        _allPlayers = [[NSMutableArray alloc] init];
    }
    return _allPlayers;
}

- (void)addPlayer:(FNPlayer *)player
{
    // incomplete implementation need to get the nous from the new player and whatever else...
    [self.allPlayers addObject:player];
    [self.unplayedNouns addObjectsFromArray:player.nouns];
}

- (NSMutableArray *)allTeams
{
    if (!_allTeams) {
        _allTeams = [[NSMutableArray alloc] init];
    }
    return _allTeams;
}

- (NSString *)directionsForRound:(NSInteger)round
{
#warning - Incomplete Implementation
    return @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in rep...";
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

//- (void)addTeam:(FNTeam *)team
//{
//    // incomplete implementation need to get the nous from the new player and whatever else...
//    [self.allTeams addObject:team];
//}

- (NSArray *)allScoreCards
{
    NSArray *cards = [self.scoreCards copy];
    return cards;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.allPlayers = [aDecoder decodeObjectForKey:@"allPlayers"];
    self.allTeams = [aDecoder decodeObjectForKey:@"allTeams"];
    self.teamOrder = [aDecoder decodeObjectForKey:@"teamOrder"];
    self.unplayedNouns = [aDecoder decodeObjectForKey:@"unplayedNouns"];
    self.playedNouns = [aDecoder decodeObjectForKey:@"playedNouns"];
    self.scoreCards = [aDecoder decodeObjectForKey:@"scoreCards"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.allPlayers forKey:@"allPlayers"];
    [aCoder encodeObject:self.allTeams forKey:@"allTeams"];
    [aCoder encodeObject:self.teamOrder forKey:@"teamOrder"];
    [aCoder encodeObject:self.unplayedNouns forKey:@"unplayedNouns"];
    [aCoder encodeObject:self.playedNouns forKey:@"playedNouns"];
    [aCoder encodeObject:self.scoreCards forKey:@"scoreCards"];
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





@end
























