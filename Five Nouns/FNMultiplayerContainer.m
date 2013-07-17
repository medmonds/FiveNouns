//
//  FNMultiplayerContainer.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/15/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNMultiplayerContainer.h"
#import "FNMultiPlayerVC.h"
#import "FNMultiplayerManager.h"

@interface FNMultiplayerContainer ()
@property (nonatomic, strong) FNMultiPlayerVC *childVC;
@end


@implementation FNMultiplayerContainer

@synthesize localPlayers = _localPlayers;
@synthesize connectedPlayers = _connectedPlayers;


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

- (void)setMultiplayerManager:(FNMultiplayerManager *)multiplayerManager
{
    _multiplayerManager = multiplayerManager;
    self.childVC.multiplayerManager = multiplayerManager;
}

- (void)setConnectedPlayers:(NSMutableArray *)connectedPlayers
{
    _connectedPlayers = connectedPlayers;
    self.childVC.connectedPlayers = connectedPlayers;
}

- (void)setLocalPlayers:(NSMutableArray *)localPlayers
{
    _localPlayers = localPlayers;
    self.childVC.localPlayers = localPlayers;
}

- (void)insertLocalPlayer:(GKPlayer *)player
{
    [self.localPlayers addObject:player];
    [self.childVC insertLocalPlayer:player];
}

- (void)deleteLocalPlayer:(GKPlayer *)player
{
    [self.localPlayers removeObject:player];
    [self.childVC deleteLocalPlayer:player];
}

- (void)insertConnectedPlayer:(GKPlayer *)player
{
    [self.connectedPlayers addObject:player];
    [self.childVC insertConnectedPlayer:player];
}

- (void)deleteConnectedPlayer:(GKPlayer *)player
{
    [self.connectedPlayers removeObject:player];
    [self.childVC deleteConnectedPlayer:player];
}

- (IBAction)showLocalPlayersPressed:(id)sender
{
    [self.childVC showLocalPlayersPressed];
}

- (void)donePressed
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self.multiplayerManager multiplayerVCDidDisappear];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.childVC.multiplayerManager = self.multiplayerManager;
    self.childVC.connectedPlayers = self.connectedPlayers;
    self.childVC.localPlayers = self.localPlayers;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIView *navTitle = [FNAppearance navBarTitleWithText:@"Remote Players" forOrientation:self.interfaceOrientation];
    // need to change the color too !!!
    [navTitle setUserInteractionEnabled:NO];
    self.navigationItem.titleView = navTitle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *navTitle = [FNAppearance navBarTitleWithText:@"Remote Players" forOrientation:self.interfaceOrientation];
    // need to change the color too !!!
    [navTitle setUserInteractionEnabled:NO];
    self.navigationItem.titleView = navTitle;
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
    UIBarButtonItem *done = [FNAppearance barButtonItemDismiss];
    [done setTarget:self];
    [done setAction:@selector(donePressed)];
    [self.navigationItem setRightBarButtonItem:done];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
