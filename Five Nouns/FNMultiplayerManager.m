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

#import "FNMultiplayerJoinVC.h" // shoul dmake this adhere to a protocol that is shared with the host VC

@interface FNMultiplayerManager ()
@property (nonatomic) BOOL isHost;
@property (nonatomic, strong) FNMultiplayerContainer *multiplayerVC;
@property (nonatomic, strong) id <FNMultiplayerManagerDelegate> sessionDelegate;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSMutableSet *clients;
@property (nonatomic, strong) UIViewController <FNMultiplayerViewController> *viewController;
@end


@implementation FNMultiplayerManager




#pragma mark - FNMultiplayerViewControllerDataSource

- (BOOL)isMultiplayerEnabled
{
    
}

- (void)turnOnMultiplayer
{
    
}

- (void)turnOffMultiplayer
{
    
}

- (NSInteger)peersCount
{
    return [self.sessionDelegate peersCount];
}

- (NSString *)displayNameForPeerAtIndex:(NSInteger)index
{
    return [self.sessionDelegate displayNameForPeerAtIndex:index];
}


- (void)viewControllerWillAppear:(id <FNMultiplayerViewController>)viewController
{
    
}

- (void)viewControllerWasDismissed:(id <FNMultiplayerViewController>)viewController
{
    self.viewController = nil;
}

- (void)connectToServerAtIndex:(NSInteger)index
{
    if ([self.sessionDelegate isKindOfClass:[FNMultiplayerClientDelegate class]]) {
        [self.sessionDelegate connectToServerAtIndex:index];
    } else {
        [NSException raise:@"Tried to connect to a Host while a Hosting a game" format:nil];
    }
}

- (void)delegate:(id <FNMultiplayerManagerDelegate>)delegate insertAvailableServerAtIndex:(NSInteger)index
{
    if (self.viewController) {
        [self.viewController insertPeerAtIndex:index];
    }
}

- (void)delegate:(id <FNMultiplayerManagerDelegate>)delegate deleteAvailableServerAtIndex:(NSInteger)index
{
    if (self.viewController) {
        [self.viewController deletePeerAtIndex:index];
    }
}

- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate connectionAttemptToPeerFailed:(NSString *)peerID
{
    NSString *displayName = [self.sessionDelegate.session displayNameForPeer:peerID]; // for the modal
    // stop the spinner
    // throw up a modal to tell the user
}







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
    self.viewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MultiplayerJoinVC"];
    self.viewController.dataSource = self;
    return self.viewController;
}

- (UIViewController *)hostViewController
{
    UINavigationController *nc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MultiplayerNC"];
    self.viewController = nc.childViewControllers[0];
    self.viewController.dataSource = self;
    return nc;
}


+ (SEL)selectorForMultiplayerView
{
    return @selector(displayMultiplayerMenuButtonTouched);
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
    self.isHost = NO;
}

- (void)browseForGames
{
    self.isHost = NO;
    self.sessionDelegate = [[FNMultiplayerClientDelegate alloc] initWithManager:self];
    [self.sessionDelegate start];
}

- (void)displayMultiplayerMenuButtonTouched
{
    // not sure how I should respond to this if I have joined a game as a client !!!
    if (self.isHost) {
        UINavigationController *rootNC = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        UIViewController *topVC = [rootNC topViewController];
        if ([topVC presentedViewController]) {
            UINavigationController *modalNC = (UINavigationController *)[topVC presentedViewController];
            topVC = [modalNC topViewController];
        }
        [topVC presentViewController:[self hostViewController] animated:YES completion:nil];
    }
}

- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didConnectToClient:(NSString *)clientPeerID
{
    // update the ui if it is on screen
    
    // tell the brain that a new client just joined the game so it can get it on the same page
    [self.clients addObject:clientPeerID];
    [self.brain didConnectToClient:clientPeerID];
}

- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didDisconnectFromClient:(NSString *)clientPeerID
{
    // update the ui if it is on screen
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

- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate sessionFailedWithError:(NSError *)error
{
    // depending on the error should either tell the user to turn on bluetooth or wifi or
    // should present the options: Attempt Reconnect, Become Host in new Game, Quit Game if the client or
    // if the host should tell the user an error occured and connected players (if there were any) should rejoin a new session and then create a new session to continue the game from the current state
}




#pragma mark - Private Methods
















@end











