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

@interface FNMultiplayerHostDelegate : NSObject <GKSessionDelegate, FNMultiplayerManagerDelegate>

// the designated initializer
- (instancetype)initWithManager:(FNMultiplayerManager *)manager;

// could be a property
- (NSArray *)connectedClientPeerIDs;
- (void)startHostingGame;
- (void)stopHostingGame;

// to be used by the UI
- (NSInteger)clientsCount;
- (NSString *)displayNameForClientAtIndex:(NSInteger)index;

- (void)viewControllerWillAppear;
- (void)viewControllerWasDismissed;

@end
