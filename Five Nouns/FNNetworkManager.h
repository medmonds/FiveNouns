//
//  FNNetworkManager.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/14/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@class FNNetworkJoinVC;
@class FNBrain;


@protocol FNNetworkManagerDelegate <NSObject, GKSessionDelegate>
// to enable / disable Network completely
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


@protocol FNNetworkViewControllerDataSource;

@protocol FNNetworkViewController <NSObject>
- (void)insertPeerAtIndex:(NSInteger)index;
- (void)deletePeerAtIndex:(NSInteger)index;
@property (nonatomic, weak) id <FNNetworkViewControllerDataSource> dataSource;
@end


@protocol FNNetworkViewControllerDataSource <NSObject>
// these are the questions that the vcs will ask not that the vcs will answer so this protocol makes no sense this way
- (BOOL)isNetworkEnabled;
- (NSInteger)peersCount;
- (NSString *)displayNameForPeerAtIndex:(NSInteger)index;

- (void)viewControllerWillAppear:(id <FNNetworkViewController>)viewController;
- (void)viewControllerWasDismissed:(id <FNNetworkViewController>)viewController;

- (void)connectToServerAtIndex:(NSInteger)index;
- (void)turnOnNetwork;
- (void)turnOffNetwork;
@end


@interface FNNetworkManager : NSObject <FNNetworkViewControllerDataSource>

#define SESSION_ID @"FiveNouns"

@property (nonatomic, weak) FNBrain *brain;

+ (FNNetworkManager *)sharedNetworkManager;

- (BOOL)sendData:(NSData *)data;
- (BOOL)sendData:(NSData *)data toClient:(NSString *)peerID;

- (UIViewController *)joinViewController;
- (UIViewController *)hostViewController;
+ (SEL)selectorForNetworkView;
- (void)startServingGame;
//- (void)stopServingGame;

- (void)delegate:(id <FNNetworkManagerDelegate>)delegate insertAvailableServerAtIndex:(NSInteger)index;
- (void)delegate:(id <FNNetworkManagerDelegate>)delegate deleteAvailableServerAtIndex:(NSInteger)index;
- (void)delegate:(id <FNNetworkManagerDelegate>)delegate didConnectToServer:(NSString *)serverPeerID;
- (void)delegate:(id<FNNetworkManagerDelegate>)delegate didDisconnectFromServer:(NSString *)serverPeerID;
- (void)delegate:(id<FNNetworkManagerDelegate>)delegate connectionAttemptToPeerFailed:(NSString *)peerID;


- (void)delegate:(id<FNNetworkManagerDelegate>)delegate didConnectToClient:(NSString *)clientPeerID;
- (void)delegate:(id<FNNetworkManagerDelegate>)delegate didDisconnectFromClient:(NSString *)clientPeerID;

- (void)delegate:(id<FNNetworkManagerDelegate>)delegate didRecieveData:(NSData *)data;

- (void)delegate:(id<FNNetworkManagerDelegate>)delegate sessionFailedWithError:(NSError *)error;


@end
