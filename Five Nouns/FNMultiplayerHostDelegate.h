//
//  FNMultiplayerHostDelegate.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/17/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "FNMultiplayerManager.h"

@class FNMultiplayerContainer;

@interface FNMultiplayerHostDelegate : NSObject <GKSessionDelegate, FNMultiplayerManagerDelegate>

// the designated initializer
- (instancetype)initWithManager:(FNMultiplayerManager *)manager;

- (void)userStartServingGame;
- (void)userStopServingGame;
// could be a property
//- (NSArray *)connectedClientPeerIDs;



@end
