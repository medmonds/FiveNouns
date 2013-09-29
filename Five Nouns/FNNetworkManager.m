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

#import "FNNetworkJoinVC.h" // shoul dmake this adhere to a protocol that is shared with the host VC

@interface FNNetworkManager ()
@property (nonatomic) BOOL isHost;
@property (nonatomic, strong) FNNetworkContainer *networkVC;
@property (nonatomic, strong) id <FNNetworkManagerDelegate> sessionDelegate;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSMutableSet *clients;
@property (nonatomic, strong) UIViewController <FNNetworkViewController> *viewController;
@end


@implementation FNNetworkManager

/************************************* Notes ****************************************

Goals:
 Needs to be as flexible as possible
 
 Users request changes with updates and the updates pass along the model version number
 upon acceptance of a change the model version number is incremented by the server then that is forwarded back to all users and the models are updated
    but then if two completely different parts of the model are being touched but arnt in sync (no conficts would occur) the changes are still disgarded it needs to be smarter
 what if I assign version numbers to the different silos of model editing
    potential silos:
        players - just players (not their attributes)
        player - team assignment
        teams - just the teams (not their attributes) & team order
        team - name
        team - players
 yeah kinda the right idea but fuck the version numbers and the siloa they are to much bookkeeping & may not really capture everything anyway
 instead how about I just send along the object to be modified in its before state and the change I want applied
    then the object to be changed can be compared againt the existing model object in the server
        if they are the same in the before states then the change can be processed without conflict
        if they are different then discard the change

 WHERE DO I PUT ALL OF THIS LOGIC????
    it could go in each brain when it accepts changes even though it only really needs to be in the server
        the clients will do more work then neccessry but is that really a big deal?
        its not that elegant but is more straight forward and then the brains dont have to know that they are 
            wait does this really work??
 
 if it do it this way then why do I even need a server
    network effieiency?? really is this the whole reason??
    the server would hold the "Truth" but what doe this really mean just that it is the most update i mean what is more "truth" if 2 users have the exact same info
        what about when a new user enters the game who does this user get their info from??
            expanding on this what about anytime info is requested
            is the request just sent out to everyone in the game
                if so then what the user receives the info with an update number or something and then the response with the highest number (while still being higher then the local number) is accepted
 no i need a server other wise the users will just make changes and diverge from eachother bc there is nothing to keep them on the same page
 
 
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 how about I just send along the object to be modified in its before state and the change I want applied
    then the object to be changed can be compared againt the existing model object in the server
        if they are the same in the before states then the change can be processed without conflict
        if they are different then discard the change
 
 ok so the interface requsts a change to the brain
 the brain creates the update object and passes it to the multiplayerManager
 if server then the multiplayer manager sends the update right back to itself's brain & then to everyone else
 if client then the update is sent to the server
    the server then asks its brain to validate the update (using the compare before state to server brain's current state method from above)
        if the update is validated then the change is sent to the server brain and then to all clients
            then clients automatically (they could validate it but it should pass evertime right?) accept the change and pass it to the brain to process
        if it fails then it is just killed and goes nowhere
 
 Ok good so far but how do I handle when a user elects to play the turn
    this user will need to be able to instantly process changes in step with its UI like the server can but also need to make sure the server is receiving all of the info from the turn as well at near real time
    should the user become the server I mean I will need a way to pass around "server" anyway right I mean what if the server walks out of the room or quits the game. that should not force everyone to quit
        maybe when a user trys to start a turn they request to become server and only actually start the turn whrn that request is accepted and the update is returned to them like all other requests
        how hard is it to change who the server is at the gksession level?? Maybe "Server" should be something I implement & the session is really a peer to peer session - lets put a pin in that.
 
 I need a way to compare all of the models easily to make sure they are all the same
    maybe the server that validates the changes, when it accepts the changes will set a version number on the update.
        then, when an update is received (both by the server & clients), the brain updates its verion number to that of the update
                    this could even be used by the clients to signal when they are out of sync and need to fix the issue
                    hell the numbers could encode some kind of info about the kinds of updates that got the brain to the current version like a 1.4.3.7 or hell an object with detailed info.
 
 What if I make the brain do the optimistic behavior and change its local state as soon as a controller requests it (so everything carries on instantly) and wait to see if it is validated.
    if it is validated then great the optimisim paid off
    if not then the brain switches back (undoes its change) and the viewController automatically undo themselves too. Now there is no need to have this code in all of the VCs.
        no the brain doesn't need to switch back per say. maybe when a remote brain requests a change and the change fails validation with the server the server should just return the good state "truth" and the remote brain that requested the change will set that as its model and be in the proper state which will undo the vc and do one better of putting it in the right state as well!
 
 ok i like this idea but i still have to handle the dragging behavior because I think it will blow up if a change comes in from the server while the cell is being dragged b/c the model is dirty.
 
 the updates shouldnt be commands like move the 4th team to the 2nd position because that relies on the assumption that the local model is in sync with the server model. Instead the updates should just be the state from the server's brain model objects like the teams array.
    but how will this work  with like changing a team name it would be impractical to pass the whole teams array but I guess I could just validate the updates coming in from the server to the remotes and if it failed validation send an "remote is out of sync alert" or something
 
 
 
 
 ok if I just match the before state with the server state and reject when the before state does not match the current server state then whenever there is a race condition the 2nd update will fail example of adding a team from 2 different devices at the same time.
 the alternative would be to be more intelligent. Not just check to see if the passed state was the same as local but instead to see if it was in conflict or then change just did not make sense anymore like trying to remove a team twice. This will get very complicated though so lets put a pin in it.
 
 Ok so lets say I make a local change optimisticaly in the brain and the change fails in the server and a fail is passed back to me how do I rectify this and what happens if I have made a 2nd change in the mean time
    should the 2nd change automatically fail as well? What if the 2nd changes is not dependent on the 1st so it could possibly pass in the server. No it should not automatically fail it should be validated and if it passes then it passes.
 ok so in the race condition I add a team just after the other guy. By the time my change goes to the brain and makes it back to me with its failed condition I will have received the added team from the other guy.
 
 
 
 
 
 
 
 Ok: I can be optimistic in the brain but I can't ever be out of sync (w/ possible exception of team name changes & maybe scoreCards)
    by this I mean that the local brain will receive a request to add a team from the UI.
        the model will be saved off.
        the change will be processed locally
        the update will go out to the server and will expect a response update letting it know if the change was accepted or not
            if the next update received is a change accepted update then good
            if the next update received is a change not accepted (don't know why this would happen) then roll it back
            if the next update received is a different change update not a response to the sent update then roll it back
                then apply the received update
        these update requests can be queued and as long as update accepted respones are received in the order in which updates are requested then everything is fine and good
            if i have update requests queued and a update change comes in (not a response) then throw away the queue and roll bck the model and then apply the incoming update
 
 how to validate updates at the server
    will need a way to make sure that the remote before change state matches the server before change state
        passing the whole model is stupid need a better way to capture t                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       he model state how about a version number
        ok so the server will increment its version number when it accepts a request
        the remote brain will increment its version number after it saves its before change state and sends the update(request)
            so when a remote requests a change it will send the requested change along with the version number
            then being optimistic the local brain will apply the change and increment its version number
                this way if two requested changes are on in route the 2nd request will have the version number of the brain that matches with the assumption that the 1st request was accepted
                    wait this will fail with simple incrementing b/c a different remote
                        lets say remoteA requests a change (with version number 4) and sends another optimistic change right behind it (w/ version number 5) to the server
                        just before this remoteB sends a request out (with version number 4)
                        the server accepts remoteBs request and Increments its version number to 5
                        then remoteA request with version number 5 comes in. the server would see that the number match and accepted it but that would be wrong
                            remote a would through out its change 5 bu the brain would process it and send it to everyone else
                    this means that the version number should capture the remote that makes the change somehow and not just the remote but the server and they should not make the distinction btwn server and remote b/c server and reomtes can change
    
 
 
 

************************************************************************************/
 
#pragma mark - FNNetworkViewControllerDataSource

- (BOOL)isNetworkEnabled
{
    
}

- (void)turnOnNetwork
{
    
}

- (void)turnOffNetwork
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
    self.isHost = YES;
    if (![self.sessionDelegate isKindOfClass:[FNNetworkHostDelegate class]]) {
        self.sessionDelegate = [[FNNetworkHostDelegate alloc] initWithManager:self];
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
            [self sendData:data];
        }
    } else {
        [[FNUpdateManager sharedUpdateManager] receiveUpdate:data];
    }
}

- (BOOL)sendData:(NSData *)data;
{
    if ([self.clients count] == 0 && !self.server) { // what ? !!! when does this make sense?
        return YES;
    }
    return [self.sessionDelegate sendData:data withDataMode:GKSendDataReliable];
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











