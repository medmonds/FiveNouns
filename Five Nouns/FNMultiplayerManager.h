//
//  FNMultiplayerManager.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/14/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@class FNMultiplayerJoinVC;

@protocol FNMultiplayerManagerDelegate <NSObject, GKSessionDelegate>
- (UIViewController *)viewController;
- (void)start;
- (void)stop;
@end

@interface FNMultiplayerManager : NSObject

#define SESSION_ID @"FiveNouns"

@property (nonatomic, strong) GKSession *session;

+ (FNMultiplayerManager *)sharedMultiplayerManager;
+ (SEL)selectorForMultiplayerView;

- (UIViewController *)joinViewController;
- (void)startServingGame;

- (void)delegate:(id <FNMultiplayerManagerDelegate>)delegate didConnectToServer:(NSString *)serverPeerID;
- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didConnectToClient:(NSString *)clientPeerID;
// add disconnect methods
@end
