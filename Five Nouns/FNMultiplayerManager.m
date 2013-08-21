//
//  FNMultiplayerManager.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/14/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNMultiplayerManager.h"
#import "FNMultiplayerContainer.h"
#import "FNMultiplayerHostDelegate.h"
#import "FNMultiplayerClientDelegate.h"
#import "FNBrain.h"
#import "FNUpdate.h"

@interface FNMultiplayerManager ()
@property (nonatomic) BOOL isHost;
@property (nonatomic, strong) FNMultiplayerContainer *multiplayerVC;
@property (nonatomic, strong) id <FNMultiplayerManagerDelegate> sessionDelegate;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSMutableSet *clients;
@end


@implementation FNMultiplayerManager

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    return self;
}

- (NSMutableSet *)clients
{
    if (!_clients) {
        _clients = [[NSMutableSet alloc] initWithCapacity:3]; // the maximum connected clients...!!!
    }
    return _clients;
}

- (UIViewController *)joinViewController
{
    [self stopServingGame];
    [self browseForGames];
    return [self.sessionDelegate viewController];
}

+ (FNMultiplayerManager *)sharedMultiplayerManager
{
    static FNMultiplayerManager *sharedMultiplayerManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMultiplayerManager = [[self alloc] init];
    });
    return sharedMultiplayerManager;
}

+ (SEL)selectorForMultiplayerView
{
    return @selector(displayMultiplayerMenuButtonTounched);
}

- (void)startServingGame
{
    self.isHost = YES;
    if (![self.sessionDelegate isKindOfClass:[FNMultiplayerHostDelegate class]]) {
        self.sessionDelegate = [[FNMultiplayerHostDelegate alloc] initWithManager:self];
    }
    [self.sessionDelegate start];
}

- (void)stopServingGame
{
    [self.sessionDelegate stop];
    self.session = nil;
    self.isHost = NO;
}

- (void)browseForGames
{
    self.isHost = NO;
    self.sessionDelegate = [[FNMultiplayerClientDelegate alloc] initWithManager:self];
    [self.sessionDelegate start];
}

- (void)displayMultiplayerMenuButtonTounched
{
    UIViewController *serverVC = [self.sessionDelegate viewController];
    UINavigationController *rootNC = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *topVC = [rootNC topViewController];
    if ([topVC presentedViewController]) {
        UINavigationController *modalNC = (UINavigationController *)[topVC presentedViewController];
        topVC = [modalNC topViewController];
    }
    [topVC presentViewController:serverVC animated:YES completion:^{
        //[self startBrowsingForLocalPlayers];
    }];
}

- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didConnectToClient:(NSString *)clientPeerID
{
    // tell the brain that a new client just joined the game so it can get it on the same page
    [self.clients addObject:clientPeerID];
    [self.brain didConnectToClient:clientPeerID];
}

- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didDisconnectFromClient:(NSString *)clientPeerID
{
    [self.clients removeObject:clientPeerID];
    [self.brain didDisconnectFromClient:clientPeerID];
}

- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didConnectToServer:(NSString *)serverPeerID
{
#warning Incomplete Implementation - Should do more here
    self.server = serverPeerID;
}

- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didDisconnectFromServer:(NSString *)serverPeerID
{
#warning Incomplete Implementation - Should do more here
    self.server = nil;
}

- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didRecieveData:(NSData *)data
{
    [self.brain handleUpdate:[FNUpdate updateForData:data]];
}

- (BOOL)sendUpdate:(FNUpdate *)update
{
    if ([self.clients count] == 0 && !self.server) {
        return YES;
    }
    return [self.sessionDelegate sendData:[FNUpdate dataForUpdate:update] withDataMode:GKSendDataReliable];
}

- (BOOL)sendUpdate:(FNUpdate *)update toClient:(NSString *)peerID
{
    return [self.sessionDelegate sendData:[FNUpdate dataForUpdate:update] withDataMode:GKSendDataReliable toPeer:peerID];
}





#pragma mark - Private Methods
















@end











