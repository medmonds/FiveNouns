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

//typedef NS_ENUM(NSInteger, FNDirectionsForRound) {
//    FNDirectionsForRoundOverview,
//    FNDirectionsForRoundOne,
//    FNDirectionsForRoundTwo,
//    FNDirectionsForRoundThree,
//    FNDirectionsForRoundFour
//};


- (NSString *)noun;

@property (nonatomic, strong) NSMutableArray *allPlayers;
- (void)addPlayer:(FNPlayer *)player;

@property (nonatomic, strong) NSMutableArray *allTeams;
//- (void)addTeam:(FNTeam *)team;

- (void)addScoreCard:(FNScoreCard *)scoreCard;
- (NSArray *)allScoreCards;

- (void)returnUnplayedNoun:(NSString *)noun;

- (NSString *)directionsForRound:(NSInteger)round;

@end
