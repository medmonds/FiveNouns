//
//  FNNetworkHostDelegate.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/17/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNNetworkHostDelegate.h"
#import "FNNetworkManager.h"
#import "FNUpdateManager.h"

@interface FNNetworkHostDelegate ()
@property (nonatomic, weak) FNNetworkManager *manager;
@property (nonatomic, weak) GKSession *session;
@end


@implementation FNNetworkHostDelegate


/******************************************* Notes **************************************************
 session
 trustedPeerDisplayNames
 adds all connected peerIDS to the trusted list
 needs list of connected peers
 needs list of trusted peers
 needs list of available peers

 
 Host Delegate:
 sends data to all peers
 receives data from all peers
 validates data from peers
 accepts all connections from trusted peers
 doesn't attempt automatic reconnection (b/c one of the other peers should become the new host)
 
 NM  asks to accept connections from untrusted peers
 NM  when it looses connection with all peers should become a client and search for the lost peers and the new host
 
 
 
 ok so only the host can see available clients (once clients are in the game they get the same multiplayerUI as the host but only the host is notified of newly available clients)
    so clientA starts a game and creates a peer session object with available = YES
        when host sees an available peer it adds them to a list of availablePeers for the UI (makes this info available to the NM)
            if they are a trusted peerIDDisplayName then clientB's connection request is automatically accepted
            if the connection succeeds then the peerID is moved to a list of connectedPeers (then give the update manager a chance to bring them up to speed)
            if they aren't a trusted PeerIDDisplayName then clientA presents a modal asking the user if they would like to add the client to the game
            if yes then accept the connection request
            if the connection succeeds then add them to the connected list & trustedPeerIDDisplayNames and give the updateManager a chance to bring clientB up to speed
 
 the trustedPeerDisplayNames array of trusted peers is only locally purged when a peer quits the game or otherwise returns to the main menu
 
 when a connected client drops from the game (takes a call) and returns to the foreground and sets up its session to be visible to the host again the above process repeats
 this method will allow a player to automatically reconnect to any peer that is now acting as server as long as that peer was around before the client disconnected!
 
 if a host user goes into the multiplayervc & taps an available client then a connection request is sent
    if that request is accepted and the connection succeeds then add them to the connected peers array the trusted peers array & let the updatemanager know
    if the request is rejected then remove the client from the available peers array (the client must now be in a different game)
    if the request fails let the user know the attempt just failed chance nothing and allow the user to tap and try again

 
****************************************************************************************************/



#pragma mark - FNNetworkManagerDelegate Methods


- (void)stop
{
    self.session.available = NO;
    for (NSString *peerID in self.manager.connectedPeerIDs) {
        [self.manager delegate:self didDisconnectFromPeer:peerID];
    }
    [self.session disconnectFromAllPeers];
    self.session.delegate = nil;
}

#pragma mark - FNNetworkHostDelegate Header Methods

- (instancetype)initWithManager:(FNNetworkManager *)manager forSession:(GKSession *)session
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.manager = manager;
    self.session = session;
    self.session.delegate = self;
    [self.session setDataReceiveHandler:self withContext:nil];
    self.session.available = YES;

    return self;
}

#pragma mark - Private Methods


#pragma mark - GKSessionDelegate Methods

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    NSLog(@"Host - Did receive data from Peer: %@", [self.session displayNameForPeer:peer]);
    if ([[FNUpdateManager sharedUpdateManager] isUpdateValid:data]) {
        [self.manager delegate:self didRecieveData:data];
        BOOL success = [self sendData:data withDataMode:GKSendDataReliable];
    }
}

- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode
{
    NSError *error;
    if (![self.session sendData:data toPeers:self.manager.connectedPeerIDs withDataMode:mode error:&error]) {
        NSLog(@"Host - Send data to Clients: %@ failed with Error: %@", self.manager.connectedPeerIDs, error);
        return NO;
    } else {
        NSLog(@"Host - Sent data to Clients: %@", self.manager.connectedPeerIDs);
        return YES;
    }
}

- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode toPeer:(NSString *)peerID
{
    if ([self.manager.connectedPeerIDs containsObject:peerID]) {
        NSError *error;
        if (![self.session sendData:data toPeers:@[peerID] withDataMode:mode error:&error]) {
            NSLog(@"Host - Send data to Client: %@ failed with Error: %@", [self.session displayNameForPeer:peerID], error);
            return NO;
        } else {
            NSLog(@"Host - Sent data to Client: %@", [self.session displayNameForPeer:peerID]);
            return YES;
        }
    } else {
        NSLog(@"Host - Send data to Client: %@ failed b/c host not connected to client.", [self.session displayNameForPeer:peerID]);
        return NO;
    }
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    switch (state) {
        case GKPeerStateAvailable:
            NSLog(@"Server - Peer: %@ changed state to Available", [self.session displayNameForPeer:peerID]);
            [self.manager delegate:self addAvailablePeer:peerID];
            break;
            
        case GKPeerStateUnavailable:
            NSLog(@"Server - Peer: %@ changed state to Unavailable", [self.session displayNameForPeer:peerID]);
            [self.manager delegate:self deleteAvailablePeer:peerID];
            break;
            
        case GKPeerStateConnected:
            NSLog(@"Server - Peer: %@ changed state to Connected", [self.session displayNameForPeer:peerID]);
                [self.manager delegate:self didConnectToPeer:peerID];
            break;
            
        case GKPeerStateDisconnected:
            NSLog(@"Server - Peer: %@ changed state to Disconnected", [self.session displayNameForPeer:peerID]);
                [self.manager delegate:self didDisconnectFromPeer:peerID];
            break;

        default:
            NSLog(@"MatchmakingServer: peer %@ changed state %d", [self.session displayNameForPeer:peerID], state);
            break;
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{    
    if (MAX_CONNECTED_PEERS > [self.manager.connectedPeerIDs count]) {
        if ([self.manager.trustedPeerDisplayNames containsObject:[self.session displayNameForPeer:peerID]]) {
            NSError *error;
            if (![self.session acceptConnectionFromPeer:peerID error:&error]) {
                NSLog(@"Network Host connection request for peerID: %@ failed with error: %@", [self.session displayNameForPeer:peerID], error);
                [self.manager delegate:self connectionAttemptToPeerFailed:peerID];
            }
        } else {
            // ask the user put up a madal with a completion block to connect or deny
            NSError *error;
            [self.session acceptConnectionFromPeer:peerID error:&error];
        }
    } else {
        [self.session denyConnectionFromPeer:peerID];
        NSLog(@"Network Host denied connection for peerID: %@ b/c at max connections", [self.session displayNameForPeer:peerID]);
    }
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	NSLog(@"MatchmakingServer: connection with peer %@ failed %@", [self.session displayNameForPeer:peerID], error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	NSLog(@"MatchmakingServer: session failed %@", error);
}





@end





















