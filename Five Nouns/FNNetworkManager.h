//
//  FNNetworkManager.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/14/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "FNNetworkMessage.h"

@class FNNetworkJoinVC;
@class FNBrain;


@protocol FNNetworkManagerDelegate <NSObject, GKSessionDelegate>
- (void)stop;
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context;
- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode;
- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode toPeer:(NSString *)peerID;
@optional
// used by the client UI only
- (void)connectToServerAtIndex:(NSInteger)index;
// used by the client to reconnect when coming out of background
- (void)attemptReconnectToTrustedPeersWithCompletion:(void (^)(NSError *error))completion;
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

#define MAX_CONNECTED_PEERS 5

+ (FNNetworkManager *)sharedNetworkManager;
- (void)handleNetworkMessage:(FNNetworkMessage *)message;

- (UIViewController *)joinViewController;
- (UIViewController *)hostViewController;
+ (SEL)selectorForNetworkView;
- (void)startServingGame;

@property (nonatomic, strong) NSMutableArray *availablePeerIDs;
@property (nonatomic, strong) NSMutableArray *connectedPeerIDs;
@property (nonatomic, strong) NSMutableSet *trustedPeerDisplayNames;
@property (nonatomic, readonly) NSString *serverPeerID;

- (BOOL)sendData:(NSData *)data;
- (BOOL)sendData:(NSData *)data toClient:(NSString *)peerID;
- (void)delegate:(id<FNNetworkManagerDelegate>)delegate didRecieveData:(NSData *)data;

- (void)delegate:(id <FNNetworkManagerDelegate>)delegate addAvailablePeer:(NSString *)peerID;
- (void)delegate:(id <FNNetworkManagerDelegate>)delegate deleteAvailablePeer:(NSString *)peerID;

- (void)delegate:(id <FNNetworkManagerDelegate>)delegate didConnectToServer:(NSString *)serverPeerID;
- (void)delegateDidDisconnectFromServer:(id<FNNetworkManagerDelegate>)delegate;

- (void)delegate:(id<FNNetworkManagerDelegate>)delegate didConnectToPeer:(NSString *)peerID;
- (void)delegate:(id<FNNetworkManagerDelegate>)delegate didDisconnectFromPeer:(NSString *)peerID;
- (void)delegate:(id<FNNetworkManagerDelegate>)delegate connectionAttemptToPeerFailed:(NSString *)peerID;

- (void)delegate:(id<FNNetworkManagerDelegate>)delegate sessionFailedWithError:(NSError *)error;


@end
