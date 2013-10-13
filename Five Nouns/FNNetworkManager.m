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

#import "FNNetworkJoinVC.h" // should make this adhere to a protocol that is shared with the host VC

@interface FNNetworkManager ()
// this should be a test not a property
@property (nonatomic, strong) FNNetworkContainer *networkVC;
@property (nonatomic, strong) id <FNNetworkManagerDelegate> sessionDelegate;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) UIViewController <FNNetworkViewController> *viewController;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic) BOOL networkingIsUserEnabled;
@property (nonatomic, strong) GKSession *session;
@end


@implementation FNNetworkManager

#define SESSION_ID @"FiveNouns"

/************************************* Notes ****************************************


 
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
    [self beginSession];
    [self startServingGame];
}

- (void)turnOffNetwork
{
    self.networkingIsUserEnabled = NO;
    [self.sessionDelegate stop];
    [self endSession];
}

- (NSInteger)peersCount
{
    return [self.connectedPeerIDs count];
}

- (NSString *)displayNameForPeerAtIndex:(NSInteger)index
{
    NSString *displayName;
    if ([self.connectedPeerIDs count] > index) {
        displayName = [self.session displayNameForPeer:[self.connectedPeerIDs objectAtIndex:index]];
    }
    return displayName;
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

- (void)delegate:(id <FNNetworkManagerDelegate>)delegate addAvailablePeer:(NSString *)peerID
{
    if (![self.availablePeerIDs containsObject:peerID]) {
        [self.availablePeerIDs addObject:peerID];
        if (self.viewController) {
           // [self.viewController insertPeerAtIndex:[self.availablePeerIDs indexOfObject:peerID]];
        }
    }
}

- (void)delegate:(id <FNNetworkManagerDelegate>)delegate deleteAvailablePeer:(NSString *)peerID
{
    if ([self.availablePeerIDs containsObject:peerID]) {
        NSInteger index = [self.availablePeerIDs indexOfObject:peerID];
        [self.availablePeerIDs removeObject:peerID];
        if (self.viewController) {
            //[self.viewController deletePeerAtIndex:index];
        }
    }
}

- (void)delegate:(id<FNNetworkManagerDelegate>)delegate connectionAttemptToPeerFailed:(NSString *)peerID
{
    NSString *displayName = [self.session displayNameForPeer:peerID];
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
    // need to immediately hand off server and become a client
    if (![self isHost]) {
        [self.sessionDelegate stop];
        self.sessionDelegate = nil;
        [self endSession];
    }
}

- (void)didBecomeActive
{
    [self beginSession];
    self.sessionDelegate = [[FNNetworkClientDelegate alloc] initWithManager:self forSession:self.session];
    [self.sessionDelegate attemptReconnectToTrustedPeersWithCompletion:^(NSError *error) {
        if (error) {
            // reconnect attempt failed
        } else {
            // success
        }
    }];
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

- (NSMutableArray *)availablePeerIDs
{
    if (!_availablePeerIDs) {
        _availablePeerIDs = [[NSMutableArray alloc] init];
    }
    return _availablePeerIDs;
}

- (NSMutableArray *)connectedPeerIDs
{
    if (!_connectedPeerIDs) {
        _connectedPeerIDs = [[NSMutableArray alloc] initWithCapacity:MAX_CONNECTED_PEERS];
    }
    return _connectedPeerIDs;
}

- (NSMutableSet *)trustedPeerDisplayNames
{
    if (!_trustedPeerDisplayNames) {
        _trustedPeerDisplayNames = [[NSMutableSet alloc] initWithCapacity:MAX_CONNECTED_PEERS];
    }
    return _trustedPeerDisplayNames;
}

- (GKSession *)session
{
    if (!_session) {
        _session = [[GKSession alloc] initWithSessionID:SESSION_ID displayName:nil sessionMode:GKSessionModePeer];
    }
    return _session;
}

- (UIViewController *)joinViewController
{
    [self stopServingGame];
    [self beginSession];
    self.sessionDelegate = [[FNNetworkClientDelegate alloc] initWithManager:self forSession:self.session];
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
        [self beginSession];
        self.sessionDelegate = [[FNNetworkHostDelegate alloc] initWithManager:self forSession:self.session];
    }
}

- (void)stopServingGame
{
    [self.sessionDelegate stop];
    self.sessionDelegate = nil;
    [self endSession];
}

- (void)displayNetworkMenuButtonTouched
{
    // can I just tell the window to present the view or does the NC have to be root at alltimes or something? !!!
    // this should be presented everytime not just when host
    if ([self isHost]) {
        UINavigationController *rootNC = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        UIViewController *topVC = [rootNC topViewController];
        if ([topVC presentedViewController]) {
            UINavigationController *modalNC = (UINavigationController *)[topVC presentedViewController];
            topVC = [modalNC topViewController];
        }
        [topVC presentViewController:[self hostViewController] animated:YES completion:nil];
    }
}

- (void)delegate:(id<FNNetworkManagerDelegate>)delegate didConnectToPeer:(NSString *)peerID
{
    // update the ui if it is on screen
    [self.trustedPeerDisplayNames addObject:[self.session displayNameForPeer:peerID]];
    
    if (![self.connectedPeerIDs containsObject:peerID]) {
        [self.connectedPeerIDs addObject:peerID];
    }
    // either way the peer will need an update
    [[FNUpdateManager sharedUpdateManager] didConnectToClient:peerID];
}

- (void)delegate:(id<FNNetworkManagerDelegate>)delegate didDisconnectFromPeer:(NSString *)peerID
{
    // update the ui if it is on screen
    if ([self.connectedPeerIDs containsObject:peerID]) {
        [self.connectedPeerIDs removeObject:peerID];
        [[FNUpdateManager sharedUpdateManager] didDisconnectFromClient:peerID];
    }
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
    [[FNUpdateManager sharedUpdateManager] receiveUpdate:data];
}

//this check should be moved to the delegate
- (BOOL)sendData:(NSData *)data
{
    if ([self isHost]) {
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


- (void)beginSession
{
    [self endSession];
    self.session = [[GKSession alloc] initWithSessionID:SESSION_ID displayName:nil sessionMode:GKSessionModePeer];
}

- (void)endSession
{
    self.session.available = NO;
    [self.session disconnectFromAllPeers];
    self.session.delegate = nil;
    self.session = nil;
    [self.connectedPeerIDs removeAllObjects];
    [self.availablePeerIDs removeAllObjects];
    // need to figure out where/when to empty the trusted peer ids
}

- (BOOL)isHost
{
    return [self.sessionDelegate isKindOfClass:[FNNetworkHostDelegate class]];
}







@end





/*

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
 
 
 
 // now since the server is not tied to the GKSession object it can be switched with an update
 //    the updateManager should check to make sure that it can become the server before it requests it of the networkManager
 //        this check would be to make sure that it was up to date with the TRUTH and that the request made sense in the context of the game
 //        the current server updateManager might also want to inform all other peers of the change about to occur so they don't try to send anyother updates
 //
 //    so the updateManager tells the networkManager that it wants to become the server
 //    if the network manager is already the server it does nothing
 //    if not then
 //        the network manager sends a request to the current server requesting to become the server
 //        the current server then sends a message to all connected clients informing them that the new server is the requesting server
 //            the current server then switches its delegate to be the clientModeDelegate
 //            the message both informs the other peers who to send their updates to now and also confirms with the requesting server that it is now the server
 //            when the requesting server receives the confirmation it switches its delegate to the serverModeDelegate
 
 
 
 
 
 so clientB wants to become the server
 clientB updateManager sends an update requesting becoming the server
 clientA validates clientsB's request in the regular way
 if it passes validation clientA forwards the update to all clients just like the regular way
 when clientC receives this update DO I REALLY NEED TO DO THIS?? (which will invalidate anyother in flight request updates) it will stop all other requests (this logic will have to be in the brain and will look like all other navigation logic like that game started, game ended, and the everything you just joinded the game logic I will need a custom navController to enfore the no navigation logic (remembe to block the add player in the pausedvc too))
 when clientB receives this it will then proceed to request becoming the server of the networkManager
 if the network manager is already the server it does nothing
 if not then
 the network manager sends a request to the current server requesting to become the server
 the current server then forwards the message to all connected clients informing them that the new server is the requesting server
 the current server then switches its delegate to be the clientModeDelegate
 the message both informs the other peers who to send their updates to now and also confirms with the requesting server that it is now the server
 when the requesting server receives the confirmation it switches its delegate to the serverModeDelegate
 it then DO I REALLY NEED TO DO THIS TOO informs the update manager that the server swap completed
 the update manager would then convey this to all other updatemanagers too to resume normal game play (I think the regular ways of validating requests might take care of this even if they require a little massaging)
 
 
 
 
 The two UIs:
 the joinVC:
 will be run by the networkManager
 what can it display?
 wether or not there are other players out there but not how many other games there are out there there is no way to tell if players = 1 or 2 or however many different games
 until a connection is attempted it can say searching for games
 that it is attempting to connect to another game when it is picked by a host
 that it is connected to a game (will also be shown through the segue)
 
 the MultiplayerDropDownVC
 will be run by the network manager because this vc needs to be available (and show the same info) when both in client and host modes
 can't show available peers when available = no so how will the host & cleint vcs show the same info
 will display the available peers (can only do this when host should confirm this with testing)
 will display the connected peers
 will have the option to turn multiplayer off & on
 
 
 Delegates:
 Both needed:
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
 if the connection request fails then attempt it again
 if a connection request is received and I don't have a serverID yet then accept the connection
 visually the client just sits in a waiting room waiting to be picked (maybe sees some info but can't really do anything)
 set available = NO; this could take care of the host trying to connect to a client who chose a differnt game issue in the host as well
 
 whenever a peer joins the session all peers add the peer's DisplayName to the trustedPeers array
 this array of trusted peers is only locally purged when a peer quits the game or otherwise returns to the main menu
 
 now the client drops from the game (takes a call) and returns to the foreground
 client will then find the available server and check its displayName againts the trustedPeers array and if it matches will automatically try to reconnect
 this method will allow a player to automatically reconnect to any peer that is now acting as server as long as that peer was around before clientB disconnected!
 
 
 
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
 when host receives a connection request from a client the host adds them to a list of availablePeers for the UI (makes this info available to the NM)
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
 
 
 
 
 
 
 
 
 
 

*/

