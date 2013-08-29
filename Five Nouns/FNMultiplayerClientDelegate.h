//
//  FNMultiplayerClientDelegate.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/17/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "FNMultiplayerManager.h"

@interface FNMultiplayerClientDelegate : NSObject <GKSessionDelegate, FNMultiplayerManagerDelegate>

// the designated initializer
- (instancetype)initWithManager:(FNMultiplayerManager *)manager;

@property (nonatomic, copy) NSString *serverPeerID;
//- (void)startLookingForServers;
//- (void)stopLookingForServers;
//- (void)connectToServerWithPeerID:(NSString *)peerID;

- (void)connectToServerAtIndex:(NSInteger)index;

@end
