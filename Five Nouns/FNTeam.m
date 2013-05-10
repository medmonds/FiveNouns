//
//  FNTeam.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNTeam.h"
#import "FNPlayer.h"

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


@end