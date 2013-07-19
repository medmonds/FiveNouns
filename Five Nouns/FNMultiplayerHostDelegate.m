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
@property (nonatomic, strong) FNMultiplayerContainer *serverVC;
@end


@implementation FNMultiplayerHostDelegate


- (instancetype)initWithManager:(FNMultiplayerManager *)manager
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.manager = manager;
    return self;
}

- (UIViewController *)viewController
{
    UINavigationController *nc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MultiplayerJoinVC"];
    self.serverVC = nc.childViewControllers[0];
    return nc;
}

- (void)viewControllerWillAppear
{
    
}

- (void)viewControllerWasDismissed
{
    
}

- (NSMutableArray *)connectedClients
{
    if (!_connectedClients) {
        _connectedClients = [[NSMutableArray alloc] init];
    }
    return _connectedClients;
}

- (NSArray *)connectedClientPeerIDs
{
    return [self.connectedClients copy];
}

- (void)stop
{
    // implement
}

- (void)start
{
    self.session = [[GKSession alloc] initWithSessionID:SESSION_ID displayName:nil sessionMode:GKSessionModeServer];
    self.session.delegate = self;
    self.session.available = YES;
    self.manager.session = self.session;
}

- (NSInteger)clientsCount
{
    return [self.connectedClients count];
}

- (NSString *)displayNameForClientAtIndex:(NSInteger)index
{
    NSString *displayName;
    if ([self.connectedClients count] > index) {
        displayName = [self.session displayNameForPeer:[self.connectedClients objectAtIndex:index]];
    }
    return displayName;
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	NSLog(@"MatchmakingServer: peer %@ changed state %d", peerID, state);
    switch (state) {
        case GKPeerStateConnected:
            if (![self.connectedClients containsObject:peerID]) {
                [self.connectedClients addObject:peerID];
                NSInteger index = [self.connectedClients indexOfObject:peerID];
                [self.serverVC insertClientAtIndex:index];
            }
            break;
            
        case GKPeerStateDisconnected:
            if ([self.connectedClients containsObject:peerID]) {
                NSInteger index = [self.connectedClients indexOfObject:peerID];
                [self.connectedClients removeObject:peerID];
                [self.serverVC deleteClientAtIndex:index];
            }
            break;
            
        default:
            break;
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    if (self.maxConnectedClients < [self.connectedClients count]) {
        NSError *error;
        if (![self.session acceptConnectionFromPeer:peerID error:&error]) {
            NSLog(@"Multiplayer Host connection request for peerID: %@ failed with error: %@", peerID, error);
        } else {
            [self.manager delegate:self didConnectToClient:peerID];
            NSLog(@"Multiplayer Host connected to peerID: %@", peerID);
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





















