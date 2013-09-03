//
//  FNMultiplayerHostDelegate.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/17/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNMultiplayerHostDelegate.h"
#import "FNMultiplayerManager.h"
#import "FNMultiPlayerVC.h"
#import "FNMultiplayerContainer.h"

@interface FNMultiplayerHostDelegate ()
@property FNMultiplayerManager *manager;
@property (nonatomic, strong) NSMutableArray *connectedClients;
@property (nonatomic) NSInteger maxConnectedClients;
@property (nonatomic, strong) GKSession *session;
//@property (nonatomic, strong) UINavigationController *viewController;
//@property (nonatomic, strong) FNMultiplayerContainer *serverVC;
@end


@implementation FNMultiplayerHostDelegate

#pragma mark - FNMultiplayerManagerDelegate Methods

//- (UIViewController *)viewController
//{
//    UINavigationController *nc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MultiplayerNC"];
//    self.serverVC = nc.childViewControllers[0];
//    self.serverVC.dataSource = self;
//    return nc;
//}

- (void)start
{
    self.session = [[GKSession alloc] initWithSessionID:SESSION_ID displayName:nil sessionMode:GKSessionModeServer];
    self.session.delegate = self;
    [self.session setDataReceiveHandler:self withContext:nil];
    self.session.available = YES;
}

- (void)stop
{
    self.session.available = NO;
    [self.session disconnectFromAllPeers];
    self.session = nil;
}

#pragma mark - FNMultiplayerHostDelegate Header Methods

- (instancetype)initWithManager:(FNMultiplayerManager *)manager
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.maxConnectedClients = 3;
    self.manager = manager;
    return self;
}

//- (void)userStartServingGame
//{
//    [self.manager startServingGame];
//}

//- (void)userStopServingGame
//{
//    NSInteger count = [self.connectedClients count];
//    for (NSInteger i = 0; i < count; i++) {
//        [self.connectedClients removeObjectAtIndex:i];
//        [self.serverVC deleteClientAtIndex:i];
//    }
//    [self.manager stopServingGame];
//}

- (NSArray *)connectedClientPeerIDs
{
    return [self.connectedClients copy];
}

//- (BOOL)isMultiplayerEnabled
//{
//    if (self.session) {
//        return YES;
//    } else {
//        return NO;
//    }
//}

- (NSInteger)peersCount
{
    return [self.connectedClients count];
}

- (NSString *)displayNameForPeerAtIndex:(NSInteger)index
{
    NSString *displayName;
    if ([self.connectedClients count] > index) {
        displayName = [self.session displayNameForPeer:[self.connectedClients objectAtIndex:index]];
    }
    return displayName;
}

#pragma mark - Private Methods

- (NSMutableArray *)connectedClients
{
    if (!_connectedClients) {
        _connectedClients = [[NSMutableArray alloc] init];
    }
    return _connectedClients;
}


#pragma mark - GKSessionDelegate Methods

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    NSLog(@"Host - Did receive data from Peer: %@", peer);
    [self.manager delegate:self didRecieveData:data];
    [self sendData:data withDataMode:GKSendDataReliable notToPeer:peer];
}

- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode
{
    NSError *error;
    if (![self.session sendData:data toPeers:self.connectedClients withDataMode:mode error:&error]) {
        NSLog(@"Host - Send data to Clients: %@ failed with Error: %@", self.connectedClients, error);
        return NO;
    } else {
        NSLog(@"Host - Sent data to Clients: %@", self.connectedClients);
        return YES;
    }
}

- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode toPeer:(NSString *)peerID
{
    if ([self.connectedClients containsObject:peerID]) {
        NSError *error;
        if (![self.session sendData:data toPeers:@[peerID] withDataMode:mode error:&error]) {
            NSLog(@"Host - Send data to Client: %@ failed with Error: %@", peerID, error);
            return NO;
        } else {
            NSLog(@"Host - Sent data to Client: %@", peerID);
            return YES;
        }
    } else {
        NSLog(@"Host - Send data to Client: %@ failed b/c host not connected to client.", peerID);
        return NO;
    }
}

- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode notToPeer:(NSString *)peerID
{
    NSError *error;
    NSMutableArray *recipients = [self.connectedClients mutableCopy];
    [recipients removeObject:peerID];
    if (![self.session sendData:data toPeers:recipients withDataMode:mode error:&error]) {
        NSLog(@"Host - Reflect data to Clients: %@ failed with Error: %@", recipients, error);
        return NO;
    } else {
        NSLog(@"Host - Reflected data to Clients: %@", recipients);
        return YES;
    }
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    // available & unavailable do not appear to be called from experience so far
    switch (state) {
        case GKPeerStateConnected:
            NSLog(@"Server - Peer: %@ changed state to: Connected", peerID);
            if (![self.connectedClients containsObject:peerID]) {
                [self.connectedClients addObject:peerID];
                NSInteger index = [self.connectedClients indexOfObject:peerID];
                [self.manager delegate:self didConnectToClient:peerID];
            }
            break;
            
        case GKPeerStateDisconnected:
            NSLog(@"Server - Peer: %@ changed state to: Disconnected", peerID);
            if ([self.connectedClients containsObject:peerID]) {
                NSInteger index = [self.connectedClients indexOfObject:peerID];
                [self.connectedClients removeObject:peerID];
                [self.manager delegate:self didDisconnectFromClient:peerID];
            }
            break;

        default:
            NSLog(@"MatchmakingServer: peer %@ changed state %d", peerID, state);
            break;
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    if (self.maxConnectedClients > [self.connectedClients count]) {
        NSError *error;
        if (![self.session acceptConnectionFromPeer:peerID error:&error]) {
            NSLog(@"Multiplayer Host connection request for peerID: %@ failed with error: %@", peerID, error);
        }
    } else {
        [self.session denyConnectionFromPeer:peerID];
        NSLog(@"Multiplayer Host denied connection for peerID: %@ b/c at max connections", peerID);
    }
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	NSLog(@"MatchmakingServer: connection with peer %@ failed %@", peerID, error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	NSLog(@"MatchmakingServer: session failed %@", error);
}


















@end





















