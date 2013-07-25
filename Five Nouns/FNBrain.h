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

@interface FNBrain : NSObject <NSCoding, FNMultiplayerBrain>


 

- (NSString *)noun;

@property (nonatomic, strong) NSMutableArray *allPlayers;
- (void)addPlayer:(FNPlayer *)player;
- (void)removePlayer:(FNPlayer *)player;
- (FNPlayer *)nextPlayer;

@property (nonatomic, strong) NSMutableArray *allTeams;
- (void)addTeam:(FNTeam *)team;
- (void)removeTeam:(FNTeam *)team;
@property (nonatomic, strong) NSArray *teamOrder;

- (void)addScoreCard:(FNScoreCard *)scoreCard;
- (NSArray *)allScoreCards;

- (void)returnUnplayedNoun:(NSString *)noun;

- (void)prepareForNewRound;

- (void)saveCurrentTurn:(FNTurnData *)turn;

- (void)saveGameData;

+ (FNBrain *)brainFromPreviousGame;

@end




