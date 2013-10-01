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
@property (nonatomic, strong) GKSession *session;
@property (nonatomic, strong) NSMutableArray *availableServers;
@property BOOL isLookingForServers;
@property FNDisconnectReason disconnectReason;
@property BOOL alreadyAttemptedReconnect;
@property (nonatomic, copy) NSString *serverPeerID;
@end




@implementation FNNetworkClientDelegate

/*
 
 Note: If you restore the server app after putting it into the background with the Home button, then you need to go back to the main screen and press Host Game again. The GKSession object is no longer valid after the app has been suspended.

 How to handle disconnects:
    if the player was disconnected because they quit the game then do not attempt to reconnect to the game
    if they were disconnected because of a network error then attempt to reconnect without getting the user involved
    if a reconnect attempt failed then present options to the user
        options Reconnect to game
                Become a new host in a seperate new game
                Quit Game
 
*/


- (instancetype)initWithManager:(FNNetworkManager *)manager
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.manager = manager;
    self.isLookingForServers = NO;
    self.alreadyAttemptedReconnect = NO;
    self.disconnectReason = FNDisconnectReasonUnknown;
    return self;
}

- (void)setSession:(GKSession *)session
{
    _session = session;
}

- (NSInteger)peersCount;
{
    return [self.availableServers count];
}

- (NSString *)displayNameForPeerAtIndex:(NSInteger)index;
{
    NSString *displayName;
    if (index < [self.availableServers count]) {
        displayName = [self.session displayNameForPeer:[self.availableServers objectAtIndex:index]];
    }
    return displayName;
}

- (void)connectToServerAtIndex:(NSInteger)index;
{
    if ([self.availableServers count] > index) {
        [self connectToServerWithPeerID:[self.availableServers objectAtIndex:index]];
    }
}

- (void)connectToServerWithPeerID:(NSString *)peerID
{
    [self.session connectToPeer:peerID withTimeout:10];
}

- (void)start
{
    if (!self.session) {
        self.session = [[GKSession alloc] initWithSessionID:SESSION_ID displayName:nil sessionMode:GKSessionModeClient];
        self.session.delegate = self;
        [self.session setDataReceiveHandler:self withContext:nil];
    }
    [self startLookingForServers];
}

- (void)stop
{
    [self stopLookingForServers];
    self.disconnectReason = FNDisconnectReasonUser;
    [self.session disconnectFromAllPeers];
    NSInteger serverCount = [self.availableServers count];
    for (NSInteger i = 0; i < serverCount; i++) {
        [self.manager delegate:self deleteAvailableServerAtIndex:i];
    }
    self.availableServers = nil;
    self.session.delegate = nil;
    self.session = nil;
}

- (void)startLookingForServers
{
    self.session.available = YES;
    self.isLookingForServers = YES;
}

- (void)stopLookingForServers
{
    self.session.available = NO;
    self.isLookingForServers = NO;
}

- (NSMutableArray *)availableServers
{
    if (!_availableServers) {
        _availableServers = [[NSMutableArray alloc] init];
    }
    return _availableServers;
}

- (void)didConnectToPeer:(NSString *)peerID
{
    // can send data or whateves // the check is to make sure not connecting to a different peer or host unintentionally
    if (!self.serverPeerID) {
        self.serverPeerID = peerID;
        [self stopLookingForServers];
        [self.manager delegate:self didConnectToServer:peerID];
        self.alreadyAttemptedReconnect = NO;
    }
}

- (void)didDisconnectFromPeer:(NSString *)peerID
{
    if (peerID == self.serverPeerID) {
        self.serverPeerID = nil;
        switch (self.disconnectReason) {
            case FNDisconnectReasonUnknown:
                [self startLookingForServers];
                [self attemptReconnectToServer:peerID];
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
    // will unavailable be called after this is called in the state update method if not then do the following:
    //        NSInteger index = [self.availableServers indexOfObject:peerID];
    //        [self.availableServers removeObject:peerID];
    //        [self.joinVC deleteAvailableServerAtIndex:index];

}

- (void)attemptReconnectToServer:(NSString *)server
{
    if ([self.availableServers containsObject:server] && !self.alreadyAttemptedReconnect) {
        [self connectToServerWithPeerID:server];
        self.alreadyAttemptedReconnect = YES;
    }
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    NSLog(@"Client - Did receive data from Peer: %@", peer);
    [self.manager delegate:self didRecieveData:data];
}

- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode
{
    NSError *error;
    NSString *serverID = [self.serverPeerID copy];
    if (serverID) {
        if (![self.session sendData:data toPeers:@[serverID] withDataMode:mode error:&error]) {
            NSLog(@"Client - Send data to Server: %@ failed with Error: %@", self.serverPeerID, error);
            return NO;
        } else {
            return YES;
        }
    }
}

- (BOOL)sendData:(NSData *)data withDataMode:(GKSendDataMode)mode toPeer:(NSString *)peerID
{
    if ([peerID isEqualToString:self.serverPeerID]) {
        NSError *error;
        if (![self.session sendData:data toPeers:@[[self.serverPeerID copy]] withDataMode:mode error:&error]) {
            NSLog(@"Client - Send data to Server: %@ failed with Error: %@", self.serverPeerID, error);
            return NO;
        } else {
            return YES;
        }
    } else {
        NSLog(@"Client - Send data to Server: %@ failed b/c not connected to server", peerID);
        return NO;
    }
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    switch (state) {
        case GKPeerStateAvailable:
            NSLog(@"Client - Peer: %@ changed state to: Available", peerID);
            if (![self.availableServers containsObject:peerID]) {
                [self.availableServers addObject:peerID];
                NSInteger index = [self.availableServers indexOfObject:peerID];
                [self.manager delegate:self insertAvailableServerAtIndex:index];
            }
            break;
            
        case GKPeerStateUnavailable:
            NSLog(@"Client - Peer: %@ changed state to: Unavailable", peerID);
            if ([self.availableServers containsObject:peerID]) {
                NSInteger index = [self.availableServers indexOfObject:peerID];
                [self.availableServers removeObject:peerID];
                [self.manager delegate:self deleteAvailableServerAtIndex:index];
            }
            break;
            
        case GKPeerStateConnected:
            NSLog(@"Client - Peer: %@ changed state to: Connected", peerID);
            [self didConnectToPeer:peerID];
            break;
            
        case GKPeerStateDisconnected:
            NSLog(@"Client Peer: %@ changed state to: Disconnected", peerID);
            // stop sending data etc...
            [self didDisconnectFromPeer:peerID];
            break;
            
        default:
            NSLog(@"MatchmakingClient: peer %@ changed state %d", peerID, state);
            break;
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	NSLog(@"MatchmakingServer: connection request from peer %@", peerID);
    // should call the denyConnectionRequest method here but this method should also never be called    
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	NSLog(@"MatchmakingServer: connection with peer %@ failed %@", peerID, error);
    // this is called when an attempted connection fails naturally or the host calls denyConnectionRequest: fromPeer:
    // evaluate the error then maybe figure out a way to pass that info up to the manager to inform the user if necessary
    [self.manager delegate:self connectionAttemptToPeerFailed:peerID];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	NSLog(@"MatchmakingServer: session failed %@", error);
    [self stop];
    [self.manager delegate:self sessionFailedWithError:error];
}


















@end





















