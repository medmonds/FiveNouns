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
@class FNBrain;
@class FNUpdate;

@protocol FNMultiplayerBrain <NSObject>

- (void)didConnectToClient:(NSString *)peerID;
- (void)didDisconnectFromClient:(NSString *)peerID;

@end

@protocol FNMultiplayerManagerDelegate <NSObject, GKSessionDelegate>
- (UIViewController *)viewController;
- (void)start;
- (void)stop;
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context;
- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode;
- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode toPeer:(NSString *)peerID;
@end




@interface FNMultiplayerManager : NSObject

#define SESSION_ID @"FiveNouns"
@property (nonatomic, weak) FNBrain *brain;
@property (nonatomic, strong) GKSession *session;

+ (FNMultiplayerManager *)sharedMultiplayerManager;
+ (SEL)selectorForMultiplayerView;

- (BOOL)sendUpdate:(FNUpdate *)update;
- (BOOL)sendUpdate:(FNUpdate *)update toClient:(NSString *)peerID;

- (UIViewController *)joinViewController;
- (void)startServingGame;
- (void)stopServingGame;


- (void)delegate:(id <FNMultiplayerManagerDelegate>)delegate didConnectToServer:(NSString *)serverPeerID;
- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didDisconnectFromServer:(NSString *)serverPeerID;
- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didConnectToClient:(NSString *)clientPeerID;
- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didDisconnectFromClient:(NSString *)clientPeerID;

- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didRecieveData:(NSData *)data;




@end
