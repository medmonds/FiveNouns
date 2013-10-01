//
//  FNNetworkManager.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/14/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNNetworkManager.h"
#import "FNNetworkContainer.h"
#import "FNNetworkHostDelegate.h"
#import "FNNetworkClientDelegate.h"
#import "FNBrain.h"
#import "FNUpdateManager.h"
#import "Reachability.h"

#import "FNNetworkJoinVC.h" // shoul dmake this adhere to a protocol that is shared with the host VC

@interface FNNetworkManager ()
@property (nonatomic) BOOL isHost;
@property (nonatomic, strong) FNNetworkContainer *networkVC;
@property (nonatomic, strong) id <FNNetworkManagerDelegate> sessionDelegate;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSMutableSet *clients;
@property (nonatomic, strong) UIViewController <FNNetworkViewController> *viewController;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic) BOOL networkingIsUserEnabled;
@end


@implementation FNNetworkManager

/************************************* Notes ****************************************

 What to do when the server drops out of the game?
 What to do when going into background?
 What to do when coming out of background?
 
 Client
 @property FNNetworkManager *manager;
 @property (nonatomic, strong) GKSession *session;
 @property (nonatomic, strong) NSMutableArray *availableServers;
 @property (nonatomic, copy) NSString *serverPeerID;

 Server
 @property FNNetworkManager *manager;
 @property (nonatomic, strong) NSMutableArray *connectedClients;
 @property (nonatomic, strong) GKSession *session;

 
you will only be able to connect to 1 game per network until I comeup with a better idea because how can I distinguish between games and peers
 or I could have to so you went to the join game screen and that is really just a waiting room and then other other players already in a game can go and click on your name and add you to the game. when a player adds you to the game an update is sent to all of the other players in the same game to add you to the game automatically.
 
 
 Change it so that all players are peers and that the server and client are virtual and just control who information is sent to and from this way if the server drops out a new server can be picked and switched to through an update
 
 so everyone is connected to everyone
    clients only send info to the server
    servers send info to all clients
    
 so when a server is switched the GKSession is kept alive and the connected clients don't change (unless someone dropped)
    when server is switched from one client to another the 3rd client just changes its ServerPeerID and redirects its data there. Available servers also changes on it's own.
    when a client becomes the server
        the delegates are swapped from being the client delegate to the server delegate but the session is kept alive
        the new server delegate will need to get the list of connected peers (to send data too) can be done on it's own by calling self.session peersWithConnectionState:
    when a server becomes a client
        it can get the list of available 
        
 
 
 what is the real difference between a cleint and a server?
    who they send data to and who they receive data from?
 
 
 
 
 
 
 
 
************************************************************************************/


#pragma mark - FNNetworkViewControllerDataSource

- (BOOL)isNetworkEnabled
{
    // should check reachability and bluetooth here too !!!
    return self.networkingIsUserEnabled;
}

- (void)turnOnNetwork
{
    self.networkingIsUserEnabled = YES;
    [self.sessionDelegate start];
}

- (void)turnOffNetwork
{
    self.networkingIsUserEnabled = NO;
    [self.sessionDelegate stop];
}

- (NSInteger)peersCount
{
    return [self.sessionDelegate peersCount];
}

- (NSString *)displayNameForPeerAtIndex:(NSInteger)index
{
    return [self.sessionDelegate displayNameForPeerAtIndex:index];
}


- (void)viewControllerWillAppear:(id <FNNetworkViewController>)viewController
{
    
}

- (void)viewControllerWasDismissed:(id <FNNetworkViewController>)viewController
{
    self.viewController = nil;
}

- (void)connectToServerAtIndex:(NSInteger)index
{
    if ([self.sessionDelegate isKindOfClass:[FNNetworkClientDelegate class]]) {
        [self.sessionDelegate connectToServerAtIndex:index];
    } else {
        [NSException raise:@"Tried to connect to a Host while a Hosting a game" format:nil];
    }
}

- (void)delegate:(id <FNNetworkManagerDelegate>)delegate insertAvailableServerAtIndex:(NSInteger)index
{
    if (self.viewController) {
        [self.viewController insertPeerAtIndex:index];
    }
}

- (void)delegate:(id <FNNetworkManagerDelegate>)delegate deleteAvailableServerAtIndex:(NSInteger)index
{
    if (self.viewController) {
        [self.viewController deletePeerAtIndex:index];
    }
}

- (void)delegate:(id<FNNetworkManagerDelegate>)delegate connectionAttemptToPeerFailed:(NSString *)peerID
{
    NSString *displayName = [self.sessionDelegate.session displayNameForPeer:peerID]; // for the modal
    // stop the spinner
    // throw up a modal to tell the user
}


- (void)startReachabilityNotifications
{
    self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
    self.reachability.reachableOnWWAN = NO;
    // Here we set up a NSNotification observer. The Reachability that caused the notification is passed in the object parameter

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [self.reachability startNotifier];
}

- (void)endReachabilityNotifications
{
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)reachabilityChanged
{
    NSLog(@"IS REACHABLE OVER WIFI: %d", [self.reachability isReachableViaWiFi]);
}

- (void)startNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)willResignActive
{
    [self.sessionDelegate stop];
}

- (void)didBecomeActive
{
    [self.sessionDelegate start];
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    [self startNotifications];
    [self startReachabilityNotifications];
    self.networkingIsUserEnabled = YES;
    
    return self;
}

- (void)dealloc
{
    [self endReachabilityNotifications];
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


+ (SEL)selectorForNetworkView
{
    return @selector(displayNetworkMenuButtonTouched);
}

+ (FNNetworkManager *)sharedNetworkManager
{
    static FNNetworkManager *sharedNetworkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNetworkManager = [[self alloc] init];
    });
    return sharedNetworkManager;
}

- (void)startServingGame
{
    if (self.networkingIsUserEnabled) {
        self.isHost = YES;
        if (![self.sessionDelegate isKindOfClass:[FNNetworkHostDelegate class]]) {
            self.sessionDelegate = [[FNNetworkHostDelegate alloc] initWithManager:self];
        }
        [self.sessionDelegate start];
    }
}

- (void)stopServingGame
{
    [self.sessionDelegate stop];
    self.isHost = NO;
}

- (void)browseForGames
{
    self.isHost = NO;
    self.sessionDelegate = [[FNNetworkClientDelegate alloc] initWithManager:self];
    [self.sessionDelegate start];
}

- (void)displayNetworkMenuButtonTouched
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

- (void)delegate:(id<FNNetworkManagerDelegate>)delegate didConnectToClient:(NSString *)clientPeerID
{
    // update the ui if it is on screen
    
    // tell the brain that a new client just joined the game so it can get it on the same page
    [self.clients addObject:clientPeerID];
    [[FNUpdateManager sharedUpdateManager] didConnectToClient:clientPeerID];
}

- (void)delegate:(id<FNNetworkManagerDelegate>)delegate didDisconnectFromClient:(NSString *)clientPeerID
{
    // update the ui if it is on screen
    [self.clients removeObject:clientPeerID];
    [[FNUpdateManager sharedUpdateManager] didDisconnectFromClient:clientPeerID];
}

- (void)delegate:(id<FNNetworkManagerDelegate>)delegate didConnectToServer:(NSString *)serverPeerID
{
#warning Incomplete Implementation - Should do more here
    self.server = serverPeerID;
}

- (void)delegate:(id<FNNetworkManagerDelegate>)delegate didDisconnectFromServer:(NSString *)serverPeerID
{
#warning Incomplete Implementation - Should do more here
    self.server = nil;
}

- (void)delegate:(id<FNNetworkManagerDelegate>)delegate didRecieveData:(NSData *)data
{
    if (self.isHost) {
        if ([[FNUpdateManager sharedUpdateManager] isUpdateValid:data]) {
            [[FNUpdateManager sharedUpdateManager] receiveUpdate:data];
            BOOL success = [self.sessionDelegate sendData:data withDataMode:GKSendDataReliable];
        }
    } else {
        [[FNUpdateManager sharedUpdateManager] receiveUpdate:data];
    }
}

- (BOOL)sendData:(NSData *)data
{
    if (self.isHost) {
        if ([[FNUpdateManager sharedUpdateManager] isUpdateValid:data]) {
            [[FNUpdateManager sharedUpdateManager] receiveUpdate:data];
            return [self.sessionDelegate sendData:data withDataMode:GKSendDataReliable];
        }
        return NO;
    } else {
        return [self.sessionDelegate sendData:data withDataMode:GKSendDataReliable];
    }
}

- (BOOL)sendData:(NSData *)data toClient:(NSString *)peerID;
{
    return [self.sessionDelegate sendData:data withDataMode:GKSendDataReliable toPeer:peerID];
}

- (void)delegate:(id<FNNetworkManagerDelegate>)delegate sessionFailedWithError:(NSError *)error
{
    // depending on the error should either tell the user to turn on bluetooth or wifi or
    // should present the options: Attempt Reconnect, Become Host in new Game, Quit Game if the client or
    // if the host should tell the user an error occured and connected players (if there were any) should rejoin a new session and then create a new session to continue the game from the current state
}




#pragma mark - Private Methods
















@end











