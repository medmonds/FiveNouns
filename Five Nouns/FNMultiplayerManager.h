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
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context;
- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode;
@end

@interface FNMultiplayerManager : NSObject

#define SESSION_ID @"FiveNouns"

@property (nonatomic, strong) GKSession *session;

+ (FNMultiplayerManager *)sharedMultiplayerManager;
+ (SEL)selectorForMultiplayerView;

- (UIViewController *)joinViewController;
- (void)startServingGame;
- (void)stopServingGame;
- (void)delegate:(id <FNMultiplayerManagerDelegate>)delegate didConnectToServer:(NSString *)serverPeerID;
- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didConnectToClient:(NSString *)clientPeerID;
// add disconnect methods
- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didRecieveData:(NSData *)data;




@end
