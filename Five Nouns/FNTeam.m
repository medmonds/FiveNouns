//
//  FNTeam.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNTeam.h"
#import "FNPlayer.h"

@interface FNTeam ()
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

//* To make players KVC compliant

- (NSUInteger)countOfPlayers
{
    return [self.players count];
}

- (FNPlayer *)objectInPlayersAtIndex:(NSUInteger)index
{
    return [self.players objectAtIndex:index];
}

- (void)insertObject:(FNPlayer *)player inPlayersAtIndex:(NSUInteger)index
{
    [self.players insertObject:player atIndex:index];
}

- (void)insertPlayers:(NSArray *)players atIndexes:(NSIndexSet *)indexes
{
    [self.players insertObjects:players atIndexes:indexes];
}

- (void)removeObjectFromPlayersAtIndex:(NSUInteger)index
{
    [self.players removeObjectAtIndex:index];
}

- (void)removePlayersAtIndexes:(NSIndexSet *)indexes
{
    [self.players removeObjectsAtIndexes:indexes];
}

- (void)addPlayer:(FNPlayer *)player
{
    if (![self.players containsObject:player]) {
        [self insertObject:player inPlayersAtIndex:[self.players count]];
    }
}

- (void)addTeamPlayers:(NSArray *)players
{
    NSMutableSet *newPlayers = [[NSSet setWithArray:players] mutableCopy];
    [newPlayers minusSet:[NSSet setWithArray:self.players]];
    if ([newPlayers count]) {
        [self insertPlayers:players atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.players count], [players count])]];
    }
}

- (void)removeTeamPlayers:(NSArray *)players
{
    NSMutableSet *oldPlayers = [[NSSet setWithArray:players] mutableCopy];
    [oldPlayers intersectSet:[NSSet setWithArray:self.players]];
    if ([oldPlayers count]) {
        [self removePlayersAtIndexes:[self.players indexesOfObjectsPassingTest:^BOOL(FNPlayer *player, NSUInteger idx, BOOL *stop) {
            return [players containsObject:player];
        }]];
    }
}

- (void)removePlayer:(FNPlayer *)player
{
    if ([self.players containsObject:player]) {
        [self removeObjectFromPlayersAtIndex:[self.players indexOfObject:player]];
    }
}

//*

- (FNPlayer *)nextPlayer
{
    if ([self.players count] == 0) {
        return nil;
    }
    // rotate players
    FNPlayer *nextPlayer = self.players[0];
    [self.players removeObjectAtIndex:0];
    [self.players addObject:nextPlayer];
    return nextPlayer;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.players = [aDecoder decodeObjectForKey:@"players"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.players forKey:@"players"];
}


@end
















