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
- (NSArray *)connectedClientPeerIDs;


// to be used by the UI
- (BOOL)isMultiplayerEnabled;
- (NSInteger)clientsCount;
- (NSString *)displayNameForClientAtIndex:(NSInteger)index;

- (void)viewControllerWillAppear:(FNMultiplayerContainer *)viewController;
- (void)viewControllerWasDismissed:(FNMultiplayerContainer *)viewController;

@end
