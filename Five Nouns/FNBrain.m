//
//  FNBrain.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/12/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNBrain.h"

@interface FNBrain ()
@end

@implementation FNBrain

- (NSMutableArray *)allPlayers
{
    if (!_allPlayers) {
        _allPlayers = [[NSMutableArray alloc] init];
    }
    return _allPlayers;
}

- (void)addPlayer:(FNPlayer *)player
{
    // incomplete implementation need to get the nous from the new player and whatever else...
    [self.allPlayers addObject:player];
}

- (NSMutableArray *)allTeams
{
    if (!_allTeams) {
        _allTeams = [[NSMutableArray alloc] init];
    }
    return _allTeams;
}

- (void)addTeam:(FNTeam *)team
{
    // incomplete implementation need to get the nous from the new player and whatever else...
    [self.allTeams addObject:team];
}

@end
