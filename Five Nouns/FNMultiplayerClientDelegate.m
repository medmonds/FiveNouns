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
@property (nonatomic, strong) FNMultiplayerJoinVC *joinVC;
@property BOOL isLookingForServers;
@end


@implementation FNMultiplayerClientDelegate

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

- (UIViewController *)viewController
{
    self.joinVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MultiplayerJoinVC"];
    self.joinVC.dataSource = self;
    return self.joinVC;
}

- (void)viewControllerWillAppear
{
    [self start];
}

- (void)viewControllerWasDismissed
{
    
}

- (NSInteger)availableServersCount
{
    return [self.availableServers count];
}

- (NSString *)displayNameForServerAtIndex:(NSInteger)index;
{
    NSString *displayName;
    if (index < [self.availableServers count]) {
        displayName = [self.session displayNameForPeer:[self.availableServers objectAtIndex:index]];
    }
    return displayName;
}

- (NSString *)nameForConnectedServer
{
    return [self.session displayNameForPeer:self.serverPeerID];
}

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
    self.session = [[GKSession alloc] initWithSessionID:SESSION_ID displayName:nil sessionMode:GKSessionModeClient];
    self.session.delegate = self;
    self.session.available = YES;
    self.manager.session = self.session;
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
    self.serverPeerID = peerID;
    [self stop];
    self.session.available = NO;
    [self.manager delegate:self didConnectToServer:peerID];
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	NSLog(@"MatchmakingServer: peer %@ changed state %d", peerID, state);
    switch (state) {
        case GKPeerStateAvailable:
            if (![self.availableServers containsObject:peerID]) {
                [self.availableServers addObject:peerID];
                NSInteger index = [self.availableServers indexOfObject:peerID];
                [self.joinVC insertAvailableServerAtIndex:index];
            }
            break;
            
        case GKPeerStateUnavailable:
            if ([self.availableServers containsObject:peerID]) {
                NSInteger index = [self.availableServers indexOfObject:peerID];
                [self.availableServers removeObject:peerID];
                [self.joinVC deleteAvailableServerAtIndex:index];
            }
            break;
            
        case GKPeerStateConnected:
            [self didConnectToPeer:peerID];
            break;
            
        case GKPeerStateDisconnected:
            // stop sending data etc...
            break;
            
        default:
            break;
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	NSLog(@"MatchmakingServer: connection request from peer %@", peerID);
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





















