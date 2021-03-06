//
//  FNBrain.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/12/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNNetworkManager.h"

@class FNScoreCard;
@class FNPlayer;
@class FNTeam;
@class FNUpdate;

typedef NS_ENUM(NSInteger, FNGameStatus) {
    FNGameStatusNotStarted,
    FNGameStatusReadyToStart,
    FNGameStatusStarted,
    FNGameStatusTurnInProgress,
};


@interface FNBrain : NSObject <NSCoding>


// how things are changed
- (void)addPlayer:(FNPlayer *)player;
- (void)removePlayer:(FNPlayer *)player;
- (void)addTeam:(FNTeam *)team;
- (void)removeTeam:(FNTeam *)team;
- (void)moveTeam:(FNTeam *)team toIndex:(NSInteger)newIndex;
- (void)assignTeam:(FNTeam *)team toPlayer:(FNPlayer *)player;
- (void)unassignTeamFromPlayer:(FNPlayer *)player;
- (void)setName:(NSString *)name forTeam:(FNTeam *)team;
- (void)addScoreCard:(FNScoreCard *)scoreCard;


- (NSArray *)orderOfTeams;
@property (nonatomic, strong) NSMutableArray *allTeams;
@property (nonatomic, strong) NSMutableArray *allPlayers;
- (NSArray *)scoreCardsForTeam:(FNTeam *)team;
- (NSArray *)allScoreCards;

- (BOOL)canBeginGame;
- (BOOL)allPlayersAssignedToTeams;






// these will have to be properties in the gameVC is to KVO when in the passenger seat like all of the other VCs
// and how will I handle the pausing and starting and receiving those events in the gameVC?
- (FNPlayer *)currentPlayer;
- (NSInteger)scoreForCurrentTurn;
- (NSString *)currentNoun;
@property (nonatomic) NSInteger round;
@property (nonatomic) NSInteger timeRemaining;


- (NSString *)nextNoun;
- (void)nounScored:(NSString *)noun forPlayer:(FNPlayer *)player;
- (void)returnUnplayedNoun:(NSString *)noun;

- (void)prepareForNewRound;
- (void)turnBeganForPlayer:(FNPlayer *)player;
- (void)turnEndedForPlayer:(FNPlayer *)player;
- (void)gameOver;
- (void)setGameStatus:(FNGameStatus)status;

+ (FNBrain *)brainFromPreviousGame;

- (NSDictionary *)currentGameState;

- (void)handleUpdate:(FNUpdate *)update;

@property (nonatomic, weak) UINavigationController *navController;

@end




















