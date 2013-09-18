//
//  FNBrain.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/12/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNMultiplayerManager.h"

@class FNScoreCard;
@class FNPlayer;
@class FNTeam;

typedef NS_ENUM(NSInteger, FNGameStatus) {
    FNGameStatusNotStarted,
    FNGameStatusReadyToStart,
    FNGameStatusStarted,
    FNGameStatusTurnInProgress,
};


@interface FNBrain : NSObject <NSCoding, FNMultiplayerBrain>


@property (nonatomic, strong) NSMutableArray *allPlayers;
- (void)addPlayer:(FNPlayer *)player;
- (void)removePlayer:(FNPlayer *)player;


@property (nonatomic, strong) NSMutableArray *allTeams;
- (NSArray *)orderOfTeams;
- (void)addTeam:(FNTeam *)team;
- (void)removeTeam:(FNTeam *)team;
- (void)moveTeam:(FNTeam *)team toIndex:(NSInteger)newIndex;
- (void)assignTeam:(FNTeam *)team toPlayer:(FNPlayer *)player;
- (void)unassignTeamFromPlayer:(FNPlayer *)player;
- (void)setName:(NSString *)name forTeam:(FNTeam *)team;
- (void)addScoreCard:(FNScoreCard *)scoreCard;
- (NSArray *)allScoreCards;
- (NSArray *)scoreCardsForTeam:(FNTeam *)team;

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

- (void)handleUpdate:(FNUpdate *)newUpdate;

@property (nonatomic, weak) UINavigationController *navController;

@end




















