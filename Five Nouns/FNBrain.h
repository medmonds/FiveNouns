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
@class FNTurnData;

typedef NS_ENUM(NSInteger, FNGameStatus) {
    FNGameStatusNotStarted,
    FNGameStatusStarted,
    FNGameStatusTurnInProgress,
};


@interface FNBrain : NSObject <NSCoding, FNMultiplayerBrain>

- (NSString *)noun;

@property (nonatomic, strong) NSMutableArray *allPlayers;
- (void)addPlayer:(FNPlayer *)player;
- (void)removePlayer:(FNPlayer *)player;
- (FNPlayer *)nextPlayer;


@property (nonatomic, strong) NSMutableArray *allTeams;
- (NSArray *)orderOfTeams;
- (void)addTeam:(FNTeam *)team;
- (void)removeTeam:(FNTeam *)team;
- (void)moveTeam:(FNTeam *)team toIndex:(NSInteger)newIndex;
- (void)assignPlayer:(FNPlayer *)player toTeam:(FNTeam *)team;
- (void)unassignPlayer:(FNPlayer *)player;
- (void)setName:(NSString *)name forTeam:(FNTeam *)team;


- (void)addScoreCard:(FNScoreCard *)scoreCard;
- (NSArray *)allScoreCards;



- (void)returnUnplayedNoun:(NSString *)noun;
- (void)prepareForNewRound;
- (void)gameStatus:(FNGameStatus)status;



- (void)saveCurrentTurn:(FNTurnData *)turn;
- (void)saveGameData;
+ (FNBrain *)brainFromPreviousGame;

- (void)handleUpdate:(FNUpdate *)newUpdate;

@property (nonatomic, weak) UINavigationController *navController;

@end




















