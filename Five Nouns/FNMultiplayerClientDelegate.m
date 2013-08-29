//
//  FNMultiplayerClientDelegate.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/17/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNMultiplayerClientDelegate.h"
#import "FNMultiplayerManager.h"
#import "FNMultiplayerJoinVC.h"

@interface FNMultiplayerClientDelegate ()
@property FNMultiplayerManager *manager;
@property GKSession *session;
@property (nonatomic, strong) NSMutableArray *availableServers;
//@property (nonatomic, strong) FNMultiplayerJoinVC *joinVC;
@property BOOL isLookingForServers;
@end


@implementation FNMultiplayerClientDelegate

/*
 
 Note: If you restore the server app after putting it into the background with the Home button, then you need to go back to the main screen and press Host Game again. The GKSession object is no longer valid after the app has been suspended.

Client Flow
 
 When a client is initially created it is given a View Controller to show available servers in and allow the selection of a server
 
 
 How to handle disconnects:
    if the player was disconnected because they quit the game then do not attempt to reconnect to the game
    if they were disconnected because of a network error then attempt to reconnect without getting the user involved
    if a reconnect attempt failed then present options to the user
        options Reconnect to game
                Become a new host in a seperate new game
                Quit Game
 
 
 
 
 
 
 Should have a method something like: didDisconnectWithReason:(quiteReason)reason
 
 typedef enum
 {
 QuitReasonNoNetwork,          // no Wi-Fi or Bluetooth
 QuitReasonConnectionDropped,  // communication failure with server
 QuitReasonUserQuit,           // the user terminated the connection
 QuitReasonServerQuit,         // the server quit the game (on purpose)
 }





*/


- (instancetype)initWithManager:(FNMultiplayerManager *)manager
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.manager = manager;
    self.isLookingForServers = NO;
    return self;
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

//- (NSString *)nameForConnectedServer
//{
//    return [self.session displayNameForPeer:self.serverPeerID];
//}

- (void)connectToServerAtIndex:(NSInteger)index;
{
    if ([self.availableServers count] > index) {
        [self connectToServerWithPeerID:[self.availableServers objectAtIndex:index]];
    }
}

- (void)connectToServerWithPeerID:(NSString *)peerID
{
    [self.session connectToPeer:peerID withTimeout:60];
}

- (void)start
{
    if (!self.session) {
        self.session = [[GKSession alloc] initWithSessionID:SESSION_ID displayName:nil sessionMode:GKSessionModeClient];
        self.session.delegate = self;
        [self.session setDataReceiveHandler:self withContext:nil];
        self.manager.session = self.session;
    }
    self.session.available = YES;
    self.isLookingForServers = YES;
}

- (void)stop
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
    // can send data or whateves
    if (!self.serverPeerID) {
        self.serverPeerID = peerID;
        [self stop];
        self.session.available = NO;
        [self.manager delegate:self didConnectToServer:peerID];
    }
}

- (void)didDisconnectFromPeer:(NSString *)peerID
{
    // will unavailable be called after this is called in the state update method
    if (peerID == self.serverPeerID) {
//        NSInteger index = [self.availableServers indexOfObject:peerID];
//        [self.availableServers removeObject:peerID];
        self.serverPeerID = nil;
//        [self.joinVC deleteAvailableServerAtIndex:index];
        [self start];
        [self.manager delegate:self didDisconnectFromServer:peerID];
        [self attemptReconnectToHost:peerID];
    }
}

- (void)attemptReconnectToHost:(NSString *)host
{
    // should check to make sure that the disconnect was not user initiated (example: Quit Game) !!!
    if ([self.availableServers containsObject:host]) {
        [self connectToServerWithPeerID:host];
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
    if (![self.session sendData:data toPeers:@[[self.serverPeerID copy]] withDataMode:mode error:&error]) {
        NSLog(@"Client - Send data to Server: %@ failed with Error: %@", self.serverPeerID, error);
        return NO;
    } else {
        return YES;
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
    // from docs: The error parameter can be used to inform the user of why the connection failed.
    
    // handle the errors here
    
    // this is called when an attempted connection fails
    // so when it fails naturally or the host calls denyConnectionRequest: fromPeer:
    
    // stop the spinner
    // throw up a modal to tell the user
    // return to state before the attampt was started

    
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	NSLog(@"MatchmakingServer: session failed %@", error);
    // from docs: This method is called when a serious internal error occurred in the session. Your application should disconnect the session from other peers and release the session.
    
    // handle the errors here

    

}


















@end





















