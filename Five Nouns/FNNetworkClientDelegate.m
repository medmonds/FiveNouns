//
//  FNNetworkClientDelegate.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/17/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNNetworkClientDelegate.h"
#import "FNNetworkManager.h"
#import "FNNetworkJoinVC.h"

typedef NS_ENUM(NSUInteger, FNDisconnectReason) {
    FNDisconnectReasonUnknown,
    FNDisconnectReasonUser,
    FNDisconnectReasonNoNetwork,
//    FNDisconnectReasonConnectionError,
//    FNDisconnectReasonHostQuit
};

@interface FNNetworkClientDelegate ()
@property (nonatomic, weak) FNNetworkManager *manager;
@property BOOL attemptReconnectToTrustedPeers;
@property BOOL initialAutoConnect;
@property FNDisconnectReason disconnectReason;
@property BOOL alreadyAttemptedReconnect;
@property (nonatomic, copy) NSString *serverPeerID;
@property (nonatomic, copy) void (^completion) (NSError *error);
@property (nonatomic, strong) NSMutableSet *peersWithOutstandingReconnectAttempt;
@property (nonatomic, weak) GKSession *session;
@end


@implementation FNNetworkClientDelegate


/******************************************* Notes **************************************************
 session
 trustedPeerDisplayNames
 adds all connected peerIDS to the trusted list
 needs list of connected peers
 needs list of trusted peers
 needs list of available peers
 
 
 Client Delegate:
 sends data to the host
 receives data from the host
 accepts all connections
 attempts reconnection to trusted peers
 
 
 ok so only the host can see available clients (once clients are in the game they get the same multiplayerUI as the host but only the host is notified of newly available clients)
    client jumps into the joinGameVC creates a session object with available = YES
        as the client notices peers becoming available it automatically sends connection requests to those available peers
            if the connection request is accepted then great wait for the update and segue and let the user know what game they just connected to also
            if the connection request is rejected then stop trying to connect to that host
            // if the connection request fails then attempt it again
            if a connection request is received and I don't have a serverID yet then accept the connection
        visually the client just sits in a waiting room waiting to be picked (maybe sees some info but can't really do anything)
        set available = NO; this could take care of the host trying to connect to a client who chose a differnt game issue in the host as well
 
 whenever a peer joins the session all peers add the peer's DisplayName to the trustedPeers array
 this array of trusted peers is only locally purged when a peer quits the game or otherwise returns to the main menu
 
 now the client drops from the game (takes a call) and returns to the foreground
    client will then find the available server and check its displayName againts the trustedPeers array and if it matches will automatically try to reconnect
    this method will allow a player to automatically reconnect to any peer that is now acting as server as long as that peer was around before clientB disconnected!
 

 
 what are the reasons I attempt a connection?? what do i do if it fails
 
 when I return from the background and the manager tells me to reconnect to trusted peers
    i tell the manager about success and failure
 when I am disconnected from a peer I try to reconnect automatically
    
 when the joinvc 1st appears and it goes out and tries to connect to everyone
 
 
 
 
 ****************************************************************************************************/

/*
 How to handle disconnects:
    if the player was disconnected because they quit the game then do not attempt to reconnect to the game
    if they were disconnected because of a network error then attempt to reconnect without getting the user involved
    if a reconnect attempt failed then tell networkManager
 
*/

- (NSMutableSet *)peersWithOutstandingReconnectAttempt
{
    if (!_peersWithOutstandingReconnectAttempt) {
        _peersWithOutstandingReconnectAttempt = [[NSMutableSet alloc] init];
    }
    return _peersWithOutstandingReconnectAttempt;
}


- (instancetype)initWithManager:(FNNetworkManager *)manager forSession:(GKSession *)session;
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.initialAutoConnect = YES;
    self.manager = manager;
    self.session = session;
    self.session.delegate = self;
    [self.session setDataReceiveHandler:self withContext:nil];
    self.session.available = YES;
    self.alreadyAttemptedReconnect = NO;
    self.disconnectReason = FNDisconnectReasonUnknown;
    return self;
}

- (void)attemptReconnectToTrustedPeersWithCompletion:(void (^)(NSError *error))completion;
{
    if ([self.manager.trustedPeerDisplayNames count]) {
        self.completion = completion;
        self.attemptReconnectToTrustedPeers = YES;
        for (NSString *peerID in [self.session peersWithConnectionState:GKPeerStateAvailable]) {
            [self connectToPeerIfTrusted:peerID];
        }
    } else {
        completion([NSError errorWithDomain:@"FiveNouns" code:1 userInfo:nil]);
    }
}

- (void)connectToPeerIfTrusted:(NSString *)peerID
{
    if ([self.manager.trustedPeerDisplayNames containsObject:[self.session displayNameForPeer:peerID]]) {
        [self.session connectToPeer:peerID withTimeout:5];
        [self.peersWithOutstandingReconnectAttempt addObject:peerID];
    }
}

- (void)reportReconnectOutcomeToManager
{
    self.attemptReconnectToTrustedPeers = NO;
    if (self.completion) {
        if (self.serverPeerID) {
            self.completion(nil);
        } else {
            self.completion ([NSError errorWithDomain:nil code:0 userInfo:nil]);
        }
        self.completion = nil;
    }
}

- (void)connectToServerWithPeerID:(NSString *)peerID
{
    [self.session connectToPeer:peerID withTimeout:6];
}

- (void)stop
{
    self.serverPeerID = nil;
    self.disconnectReason = FNDisconnectReasonUser;
    [self.session disconnectFromAllPeers];
    for (NSString *peerID in [self.manager.availablePeerIDs copy]) {
        [self.manager delegate:self deleteAvailablePeer:peerID];
    }
    self.session.available = NO;
    [self.session setDataReceiveHandler:nil withContext:nil];
    self.session.delegate = nil;
}

- (void)didConnectToPeer:(NSString *)peerID
{
    self.initialAutoConnect = NO;
    [self.peersWithOutstandingReconnectAttempt removeObject:peerID];
    [self cancelOutstandingConnectionAttempts];
    
    if (!self.serverPeerID) {
        self.serverPeerID = peerID;
        if (self.attemptReconnectToTrustedPeers) {
            [self reportReconnectOutcomeToManager];
        } else {
            [self.manager delegate:self didConnectToServer:peerID];
        }
        self.alreadyAttemptedReconnect = NO;
    } else {
        // the session connected to a peer that was connected to a peer I intentionally connected to.
        [self.manager delegate:self didConnectToPeer:peerID];
    }
}

- (void)cancelOutstandingConnectionAttempts
{
    // create the temp & empty the set b/c the cancel will call connectionWithPeerFailed which will remove the peerid from self.peersWithOutstandingReconnectAttempt which would be bad
    NSArray *temp = [self.peersWithOutstandingReconnectAttempt allObjects];
    [self.peersWithOutstandingReconnectAttempt removeAllObjects];
    for (NSString *peerID in temp) {
        [self.session cancelConnectToPeer:peerID];
    }
}

- (void)didDisconnectFromPeer:(NSString *)peerID
{
    if (peerID == self.serverPeerID) {
        self.serverPeerID = nil;
        switch (self.disconnectReason) {
            case FNDisconnectReasonUnknown:
                //[self attemptReconnectToServer:peerID];
                break;
                
            case FNDisconnectReasonNoNetwork:
                break;
                
            case FNDisconnectReasonUser:
                break;
                
            default:
                break;
        }
        [self.manager delegate:self didDisconnectFromServer:peerID];
    }
    [self.manager delegate:self didDisconnectFromPeer:peerID];
}

- (void)attemptReconnectToServer:(NSString *)server
{
    if ([[self.session peersWithConnectionState:GKPeerStateAvailable] containsObject:server] && !self.alreadyAttemptedReconnect) {
        [self connectToServerWithPeerID:server];
        self.alreadyAttemptedReconnect = YES;
    }
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    NSLog(@"Client - Did receive data from Peer: %@", [self.session displayNameForPeer:peer]);
    [self.manager delegate:self didRecieveData:data];
}

- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode
{
    NSError *error;
    NSString *serverID = [self.serverPeerID copy];
    if (serverID) {
        if (![self.session sendData:data toPeers:@[serverID] withDataMode:mode error:&error]) {
            NSLog(@"Client - Send data to Server: %@ failed with Error: %@", [self.session displayNameForPeer:self.serverPeerID], error);
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode toPeer:(NSString *)peerID
{
    if ([peerID isEqualToString:self.serverPeerID]) {
        NSError *error;
        if (![self.session sendData:data toPeers:@[[self.serverPeerID copy]] withDataMode:mode error:&error]) {
            NSLog(@"Client - Send data to Server: %@ failed with Error: %@", [self.session displayNameForPeer:self.serverPeerID], error);
            return NO;
        } else {
            return YES;
        }
    } else {
        NSLog(@"Client - Send data to Server: %@ failed b/c not connected to server", [self.session displayNameForPeer:peerID]);
        return NO;
    }
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    switch (state) {
        case GKPeerStateAvailable:
            NSLog(@"Client - Peer: %@ changed state to: Available", [self.session displayNameForPeer:peerID]);
            [self.manager delegate:self addAvailablePeer:peerID];
            if (self.initialAutoConnect) {
                [self.session connectToPeer:peerID withTimeout:8];
                [self.peersWithOutstandingReconnectAttempt addObject:peerID];
            } else if (self.attemptReconnectToTrustedPeers) {
                [self connectToPeerIfTrusted:peerID];
            }
            break;
            
        case GKPeerStateUnavailable:
            NSLog(@"Client - Peer: %@ changed state to: Unavailable", [self.session displayNameForPeer:peerID]);
            [self.manager delegate:self deleteAvailablePeer:peerID];
            break;
            
        case GKPeerStateConnected:
            NSLog(@"Client - Peer: %@ changed state to: Connected", [self.session displayNameForPeer:peerID]);
            [self didConnectToPeer:peerID];
            break;
            
        case GKPeerStateDisconnected:
            NSLog(@"Client Peer: %@ changed state to: Disconnected", [self.session displayNameForPeer:peerID]);
            [self didDisconnectFromPeer:peerID];
            break;
            
        default:
            NSLog(@"MatchmakingClient: peer %@ changed state %d", [self.session displayNameForPeer:peerID], state);
            break;
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	NSLog(@"MatchmakingServer: connection request from peer %@", [self.session displayNameForPeer:peerID]);
    [self.session denyConnectionFromPeer:peerID];
}

// this is called when an attempted connection fails naturally or the host calls denyConnectionRequest: fromPeer: or a connectionAttempt is canceled
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	NSLog(@"MatchmakingServer: connection with peer %@ failed %@", [self.session displayNameForPeer:peerID], error);
    
    // remove the peers who failed.
    if ([self.peersWithOutstandingReconnectAttempt containsObject:peerID]) {
        [self.peersWithOutstandingReconnectAttempt removeObject:peerID];
        if (![self.peersWithOutstandingReconnectAttempt count] && self.attemptReconnectToTrustedPeers) {
            // If that was the last outstanding peer report that the reconnect attempt failed to the manager.
            [self reportReconnectOutcomeToManager];
        }
    }
    
    
    
    // why am I calling this I dont do anything in the manager and what does it mean to have this fail since I call it from so many places
    // [self.manager delegate:self connectionAttemptToPeerFailed:peerID];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	NSLog(@"MatchmakingServer: session failed %@", error);
    [self stop];
    [self.manager delegate:self sessionFailedWithError:error];
}


@end





















