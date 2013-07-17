//
//  FNMultiPlayerVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/15/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNTableViewController.h"

@class FNMultiplayerManager;
@class GKPlayer;

@interface FNMultiPlayerVC : FNTableViewController
@property (nonatomic, strong) FNMultiplayerManager *multiplayerManager;

@property (nonatomic, strong) NSMutableArray *connectedPlayers;
@property (nonatomic, strong) NSMutableArray *localPlayers;

- (void)showLocalPlayersPressed;

- (void)insertLocalPlayer:(GKPlayer *)player;
- (void)deleteLocalPlayer:(GKPlayer *)player;

- (void)insertConnectedPlayer:(GKPlayer *)player;
- (void)deleteConnectedPlayer:(GKPlayer *)player;

@end
