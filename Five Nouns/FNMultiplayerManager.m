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
    [self.brain didConnectToClient:clientPeerID];
}

- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didConnectToServer:(NSString *)serverPeerID
{
    
}

- (void)delegate:(id<FNMultiplayerManagerDelegate>)delegate didRecieveData:(NSData *)data
{
    // for debug !!!
    [self displayMultiplayerMenuButtonTounched];
}

- (BOOL)sendUpdate:(FNUpdate *)update
{
    return [self.sessionDelegate sendData:[FNUpdate dataForUpdate:update] withDataMode:GKSendDataReliable];
}





#pragma mark - Private Methods
















@end











