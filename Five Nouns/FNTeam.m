//
//  FNTeam.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNTeam.h"
#import "FNPlayer.h"
#import "FNScoreCard.h"

@interface FNTeam ()
@property (nonatomic, strong) NSMutableArray *teamScoreCards;
@end

// might need to set the score card order when handing out the cards !!!

@implementation FNTeam

- (NSMutableArray *)players
{
    if (!_players) {
        _players = [[NSMutableArray alloc] init];
    }
    return _players;
}

- (void)addPlayer:(FNPlayer *)player
{
    [self.players addObject:player];
    //player.team = self;
}

- (void)removePlayer:(FNPlayer *)player
{
    [self.players removeObject:player];
    //player.team = nil;
}

- (NSInteger)currentScore
{
    NSInteger currentScore = 0;
    for (FNScoreCard *card in self.teamScoreCards) {
        currentScore = currentScore + [card.nounsScored count];
    }
    return currentScore;
}

- (void)addScoreCard:(FNScoreCard *)scoreCard
{
    [self.teamScoreCards addObject:scoreCard];
}

- (NSArray *)scoreCards
{
    return [self.teamScoreCards copy];
}


@end