//
//  FNBrain.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/12/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FNScoreCard;
@class FNPlayer;
@class FNTeam;

@interface FNBrain : NSObject

- (NSString *)noun;

@property (nonatomic, strong) NSMutableArray *allPlayers;
- (FNPlayer *)player;
- (void)addPlayer:(FNPlayer *)player;

@property (nonatomic, strong) NSMutableArray *allTeams;
//- (void)addTeam:(FNTeam *)team;

- (void)addScoreCard:(FNScoreCard *)scoreCard;
- (void)returnUnplayedNoun:(NSString *)noun;

@end
