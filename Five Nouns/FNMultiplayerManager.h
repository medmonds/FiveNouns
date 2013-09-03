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
// to enable / disable multiplayer completely
@property (nonatomic, readonly) GKSession *session;
- (void)start;
- (void)stop;
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context;
- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode;
- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode toPeer:(NSString *)peerID;
// for UI
- (NSInteger)peersCount;
- (NSString *)displayNameForPeerAtIndex:(NSInteger)index;
@optional
// used by the client UI only
- (void)connectToServerAtIndex:(NSInteger)index;
@end


@protocol FNMultiplayerViewControllerDataSource;
@protocol FNMultiplayerViewController <NSObject>
- (void)insertPeerAtIndex:(NSInteger)index;
- (void)deletePeerAtIndex:(NSInteger)index;
@property (nonatomic, weak) id <FNMultiplayerViewControllerDataSource> dataSource;
@end


@protocol FNMultiplayerViewControllerDataSource <NSObject>
// these are the questions that the vcs will ask not that the vcs will answer so this protocol makes no sense this way
- (BOOL)isMultiplayerEnabled;
- (NSInteger)peersCount;
- (NSString *)displayNameForPeerAtIndex:(NSInteger)index;

- (void)viewControllerWillAppear:(id <FNMultiplayerViewController>)viewController;
- (void)viewControllerWasDismissed:(id <FNMultiplayerViewController>)viewController;

- (void)connectToServerAtIndex:(NSInteger)index;
- (void)turnOnMultiplayer;
- (void)turnOffMultiplayer;
@end


@interface FNMultiplayerManager : NSObject <FNMultiplayerViewControllerDataSource>

#define SESSION_ID @"FiveNouns"

@property (nonatomic, weak) FNBrain *brain;

+ (FNMultiplayerManager *)sharedMultiplayerManager;

- (BOOL)sendUpdate:(FNUpdate *)update;
- (BOOL)sendUpdate:(FNUpdate *)update toClient:(NSString *)peerID;

- (UIViewController *)joinViewController;
- (UIViewController *)hostViewController;
+ (SEL)selectorForMultiplayerView;
- (void)startServingGame;
//- (void)stopServingGame;

- (void)delegate:(id <FNMultiplayerManagerDelegate>)delegate insertAvailableServerAtIndex:(NSInteger)index;
- (void)delegate:(id <FNMultiplayerManagerDelegate>)delegate deleteAvailableServerAtIndex:(NSInteger)index;
- (void)delegate:(id <FNMultiplayerManagerDelegate>)delegate didConnectToServer:(NSString *)serverPeerID;
- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didDisconnectFromServer:(NSString *)serverPeerID;
- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate connectionAttemptToPeerFailed:(NSString *)peerID;


- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didConnectToClient:(NSString *)clientPeerID;
- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didDisconnectFromClient:(NSString *)clientPeerID;

- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didRecieveData:(NSData *)data;

- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate sessionFailedWithError:(NSError *)error;


@end
