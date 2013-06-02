//
//  FNBrain.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/12/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNBrain.h"
#import "FNScoreCard.h"
#import "FNPlayer.h"
#import "FNTeam.h"

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

//- (void)addTeam:(FNTeam *)team
//{
//    // incomplete implementation need to get the nous from the new player and whatever else...
//    [self.allTeams addObject:team];
//}

- (NSArray *)allScoreCards
{
//    FNTeam *team1 = [[FNTeam alloc] init];
//    team1.name = @"Team 1";
//    FNTeam *team2 = [[FNTeam alloc] init];
//    team2.name = @"Team 2";
//    FNTeam *team3 = [[FNTeam alloc] init];
//    team3.name = @"Team 3";
//    FNTeam *team4 = [[FNTeam alloc] init];
//    team4.name = @"Team 4";
//    self.allTeams = [[NSMutableArray alloc] initWithObjects:team1, team2, team3, team4, nil];
//    
//    FNPlayer *player1 = [[FNPlayer alloc] init];
//    player1.name = @"Matt";
//    player1.team = team1;
//    FNPlayer *player2 = [[FNPlayer alloc] init];
//    player2.name = @"Jill";
//    player2.team = team2;
//    FNPlayer *player3 = [[FNPlayer alloc] init];
//    player3.name = @"Abbey";
//    player3.team = team3;
//    FNPlayer *player4 = [[FNPlayer alloc] init];
//    player4.name = @"Wes";
//    player4.team = team4;
//    
//    FNScoreCard *card1 = [[FNScoreCard alloc] init];
//    card1.player = player1;
//    card1.nounsScored = [[NSMutableArray alloc] initWithObjects:@"dog", nil];
//    card1.round = 1;
//    card1.turn = 1;
//    FNScoreCard *card2 = [[FNScoreCard alloc] init];
//    card2.player = player2;
//    card2.nounsScored = [[NSMutableArray alloc] initWithObjects:@"dog", @"Cat", nil];
//    card2.round = 1;
//    card2.turn = 2;
//    FNScoreCard *card3 = [[FNScoreCard alloc] init];
//    card3.player = player3;
//    card3.nounsScored = [[NSMutableArray alloc] initWithObjects:@"dog", @"Cat", @"Bunny", nil];
//    card3.round = 1;
//    card3.turn = 3;
//    FNScoreCard *card4 = [[FNScoreCard alloc] init];
//    card4.player = player4;
//    card4.nounsScored = [[NSMutableArray alloc] initWithObjects:@"dog", @"Cat", @"Bunny", @"Mouse", nil];
//    card4.round = 1;
//    card4.turn = 4;
//    
//    FNScoreCard *card12 = [[FNScoreCard alloc] init];
//    card12.player = player1;
//    card12.nounsScored = [[NSMutableArray alloc] initWithObjects:@"dog", @"Cat", @"Bunny", @"Mouse", nil];
//    card12.round = 2;
//    card12.turn = 1;
//    FNScoreCard *card22 = [[FNScoreCard alloc] init];
//    card22.player = player2;
//    card22.nounsScored = [[NSMutableArray alloc] initWithObjects:@"dog", @"Cat", @"Bunny", nil];
//    card22.round = 2;
//    card22.turn = 2;
//    FNScoreCard *card32 = [[FNScoreCard alloc] init];
//    card32.player = player3;
//    card32.nounsScored = [[NSMutableArray alloc] initWithObjects:@"dog", @"Mouse", nil];
//    card32.round = 2;
//    card32.turn = 3;
//    FNScoreCard *card42 = [[FNScoreCard alloc] init];
//    card42.player = player4;
//    card42.nounsScored = [[NSMutableArray alloc] initWithObjects:@"dog", nil];
//    card42.round = 2;
//    card42.turn = 4;
//    
//    return @[card1, card2, card3, card4, card12, card22, card32, card42];
    return nil;
}


@end













