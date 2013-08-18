//
//  FNTeam.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNUniqueIDObject.h"

@class FNPlayer;
@class FNScoreCard;

@interface FNTeam : FNUniqueIDObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *players;

- (void)addPlayer:(FNPlayer *)player;
- (void)addTeamPlayers:(NSArray *)players;
- (void)removePlayer:(FNPlayer *)player;
- (void)removeTeamPlayers:(NSArray *)players;
- (FNPlayer *)nextPlayer;
- (NSInteger)currentScore;
- (void)addScoreCard:(FNScoreCard *)scoreCard;
- (NSArray *)scoreCards;

@end
