//
//  FNMultiplayerManager.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/14/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNMultiplayerManager.h"
#import <GameKit/GameKit.h>
#import "FNMultiplayerContainer.h"

@interface FNMultiplayerManager ()
@property (nonatomic, strong) GKLocalPlayer *authenticatedPlayer;
@property (nonatomic) BOOL matchRequested;
@property (nonatomic, strong) GKMatch *currentMatch;

@property (nonatomic, strong) FNMultiplayerContainer *multiplayerVC;
@property (nonatomic, strong) NSMutableArray *localPlayers;
@property (nonatomic, strong) NSMutableArray *connectedPlayers;
@property (nonatomic, strong) NSMutableSet *playersToInvite;
@property (nonatomic, strong) NSMutableSet *invitedPlayers;
@end


@implementation FNMultiplayerManager

// if players are requested then it will be a private game
// need methods to return my response handlers

/*
 start looking for local players
 once found add to ui
 stop looking for local players when view dismissed

 when the first local player is selected in the ui
 create a match request with that player (have to wait for a player to include in request otherwise will be a public match)
 
 to add more players check to see if a match already exists if it doesnt do the above else
 start looking for local players
 once players are found display them in the interface
 once selected call addPlayers:toMatch:matchRequest:completionHandler:
 
 */

#pragma mark - GKMatch Delegate

- (NSMutableSet *)invitedPlayers
{
    if (!_invitedPlayers) {
        _invitedPlayers = [[NSMutableSet alloc] init];
    }
    return _invitedPlayers;
}

- (NSMutableArray *)localPlayers
{
    if (!_localPlayers) {
        _localPlayers = [[NSMutableArray alloc] init];
    }
    return _localPlayers;
}

- (NSMutableArray *)connectedPlayers
{
    if (!_connectedPlayers) {
        _connectedPlayers = [[NSMutableArray alloc] init];
    }
    return _connectedPlayers;
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

- (void)displayMultiplayerMenuButtonTounched
{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
//    UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"MultiplayerNC"];
//    self.multiplayerVC = (FNMultiplayerContainer *)[nc topViewController];
//    self.multiplayerVC.multiplayerManager = self;
//    self.multiplayerVC.localPlayers = [self.localPlayers mutableCopy];
//    self.multiplayerVC.connectedPlayers = [self.connectedPlayers mutableCopy];

    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    request.inviteeResponseHandler = ^(NSString *playerID, GKInviteeResponse response) {
        // update my ui...
    };
    
    [[GKMatchmaker sharedMatchmaker] addPlayersToMatch:self.currentMatch matchRequest:request completionHandler:^(NSError *error) {
        if (error) {
            // handle the error
            // reset the state to indicate a request can be resent
        } else {
            // update UI for added players etc.
        }
    }];

    
    
    GKMatchmakerViewController *nc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    
    
    UINavigationController *rootNC = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *topVC = [rootNC topViewController];
    if ([topVC presentedViewController]) {
        UINavigationController *modalNC = (UINavigationController *)[topVC presentedViewController];
        topVC = [modalNC topViewController];
    }
    [topVC presentViewController:nc animated:YES completion:^{
        //[self startBrowsingForLocalPlayers];
    }];








}

- (void)multiplayerVCDidDisappear
{
    [self stopBrowsingForPlayers];
}

- (BOOL)isMultiplayerEnabled
{
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        return YES;
    } else {
        return NO;
    }
}

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            // need to authenticate the local player
            [self.hostViewController presentViewController:viewController animated:YES completion:nil];
        } else {
            // check to see if authentication succeeded or failed
            [self processLocalPlayerAuthenticationStatus];
        }
    };
}

- (void)processLocalPlayerAuthenticationStatus
{
    if ([GKLocalPlayer localPlayer].authenticated) {
        [self enableMultiplayerGaming];
    } else {
        self.authenticatedPlayer = nil;
        [self disableMultiplayerGaming];
    }
}

- (void)enableMultiplayerGaming
{
    // make sure that the player is the same player and not a new authd player
    self.authenticatedPlayer = [GKLocalPlayer localPlayer];
    if (!self.matchRequested) {
        //[self startBrowsingForLocalPlayers];
    }
}

- (void)disableMultiplayerGaming
{
    self.authenticatedPlayer = nil;
}

- (void)startBrowsingForLocalPlayers
{
    GKMatchmaker *maker = [GKMatchmaker sharedMatchmaker];
    [maker startBrowsingForNearbyPlayersWithReachableHandler:^(NSString *playerID, BOOL reachable) {
        if (reachable) {
            // add the player to my array of available players
            [GKPlayer loadPlayersForIdentifiers:@[playerID] withCompletionHandler:^(NSArray *players, NSError *error) {
                for (GKPlayer *player in players) {
                    [self addLocalPlayer:player];
                }
            }];
        } else {
            // remove the player from my list of available players
            for (GKPlayer *player in self.localPlayers) {
                if (playerID == player.playerID) {
                    [self removeLocalPlayer:player];
                }
            }
        }
    }];

}

- (void)addLocalPlayer:(GKPlayer *)player
{
    [self.localPlayers addObject:player];
    [self.multiplayerVC insertLocalPlayer:player];
}

- (void)removeLocalPlayer:(GKPlayer *)player
{
    [self.localPlayers removeObject:player];
    [self.multiplayerVC deleteLocalPlayer:player];
}

// called when a user selects a player to add
- (void)invitePlayerToMatch:(GKPlayer *)player
{
    NSString *playerID = player.playerID;
    if (!self.matchRequested) {
        // start a match
        [self newMatchWithPlayerID:playerID];
    } else if (self.currentMatch && [self.invitedPlayers count] < 3) {
        // add the player to the existing match
        [self invitePlayerToCurrentMatch:playerID];
    } else {
        // hold until matchRequest returns with the match
        [self.playersToInvite addObject:playerID];
    }
}

- (void)invitePlayerToCurrentMatch:(NSString *)playerID;
{
    if ([self.invitedPlayers containsObject:playerID]) {
        // already invited the player
        return;
    }
    [self.invitedPlayers addObject:playerID];
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    request.playersToInvite = @[playerID];
    request.inviteeResponseHandler = ^(NSString *playerID, GKInviteeResponse response) {
        // update my ui...
    };
    
    [[GKMatchmaker sharedMatchmaker] addPlayersToMatch:self.currentMatch matchRequest:request completionHandler:^(NSError *error) {
        if (error) {
            // handle the error
            // reset the state to indicate a request can be resent
        } else {
            // update UI for added players etc.
        }
    }];
}

- (void)inviteQueuedPlayers
{
    // make sure I'm not double inviting
    [self.playersToInvite minusSet:self.invitedPlayers];
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    request.playersToInvite = [self.playersToInvite allObjects];
    request.inviteeResponseHandler = ^(NSString *playerID, GKInviteeResponse response) {
        // update my ui...
    };
    
    [[GKMatchmaker sharedMatchmaker] addPlayersToMatch:self.currentMatch matchRequest:request completionHandler:^(NSError *error) {
        if (error) {
            // handle the error
            // reset the state to indicate a request can be resent
        } else {
            // update UI for added players etc.
        }
    }];
    [self.invitedPlayers unionSet:self.playersToInvite];
    self.playersToInvite = nil;
}

- (void)newMatchWithPlayerID:(NSString *)playerID
{
    // add the player to a set that holds invited players
    [self.invitedPlayers addObject:playerID];
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    request.playersToInvite = @[playerID];
    request.inviteeResponseHandler = ^(NSString *playerID, GKInviteeResponse response) {
        // update my ui...
    };
    
    [[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch *match, NSError *error) {
        if (error) {
            // handle the error
            // reset the state to create a new match when a player is selected
        } else if (match) {
            self.currentMatch = match;
            [self inviteQueuedPlayers];
        }
    }];
}


- (void)stopBrowsingForPlayers
{
    [[GKMatchmaker sharedMatchmaker] stopBrowsingForNearbyPlayers];
}


















@end



/*
 
 step 1:
 athenticate local player in applicationDidFinishLaunchingWithOptions:
 {
 GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
 localPlayer.authenticationHandler = // handle the callback
 [localPlayer authenticate];
 }
 
 step 2: handle the callback
 
 localPlayer.authenticationHandler = ^(UIVIewController *loginVC, NSError *error) {
 if ([GKLOcalPlayer localPlayer].authenticated) {
 // auth was successful
 [self enableGameCenterForPlayer:[GKLocalPlayer localPlayer]];
 } else if (loginVC) {
 //player not yet loggedin, present the VC
 [self pauseGame];
 [self presentLoginVC:loginVC];
 } else {
 // auth failed provide graceful fallback
 [self disableGameCenter];
 }
 };
 
 ----
 
 pick players -- invite or nearby players
 entry points -- In Game, User Accepted Invite, Hit "Play" in Game Center
 
 In Game - Button that says play multiplayer
 Invite Players - If user accepts the invite will be brought into the game
 
 To Pick Players: (Match Making UI)
 1) Make a GKMatchRequest - specifiy number of players
 GKMatchRequest *request = [GKMatchRerquest alloc] init];
 request.minPlayer = 1;
 request.maxPlayers = 4;
 ...
 2) Pass that to the MatchMackerVC. this interacts with the sigleton matchmaker under covers which produces the GKMatch for you
 // create the VC
 GKMatchmakerViewController *controller = [[GKMatchmakerViewController alloc] initWithMatchRequest:matchRequest];
 // set the delegate
 controller.matchmakerDelegate = self;
 
 // show it
 [self.viewController presentVC...]
 
 
 3) the GKMatch is the channel for communications
 
 
 
 Get set -- Wait for players & setup
 Game Code -- didChangeState
 
 G0 -- Play
 game Data -- send data recieve data
 
 
 -- To Add players to an existing game:
 get the existing matchRequest
 create the viewcontroller
 then call [controller addPlayersToMatch:self.currentMatch];
 
 Programmatic MatchMaking:
 make the GKMatchRequest
 call the GKMatchMaker singleton directly with my matchRequest
 then it will return my match
 all the code I need:
 GKMatchMaker
 
 
 */
