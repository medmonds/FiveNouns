//
//  FNNextUpVC.m
//  Five Nouns
//
//  Created by Jill on 5/22/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNNextUpVC.h"
#import "FNScoreCard.h"
#import "FNBrain.h"
#import "FNPlayer.h"
#import "FNTeam.h"
#import "FNAppearance.h"
#import "FNRoundDirectionsVC.h"
#import "FNGameVC.h"
#import "FNPausedVC.h"
#import "FNScoreVC.h"

@interface FNNextUpVC ()
@property (nonatomic, weak) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *nextPlayerLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;
// the next up player to be passed to the gameVC
@property (nonatomic, weak) FNPlayer *nextPlayer;
// Score View
@property (nonatomic, strong) FNScoreVC *scoreVC;
// Direction modal
@property (nonatomic, strong) FNRoundDirectionsVC *directionsVC;
// Paused (Options) modal
@property (nonatomic, strong) FNPausedVC *pausedVC;
// Game Screen (need to keep a reference to it when it is popped off the nav stack
@property (nonatomic, strong) FNGameVC *gameVC;
// if this is the beginning of the game then can go back to teams vc otherwise can't
@property (nonatomic) BOOL gameHasNotStarted;
@property (nonatomic) BOOL showDirections;
@end

@implementation FNNextUpVC

/*

 
*/

#pragma mark - Navigation

- (void)optionsBarButtonItemPressed
{
    UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"pausedNC"];
    FNPausedVC *options = (FNPausedVC *)nc.topViewController;
    options.brain = self.brain;
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}

- (IBAction)startPressed:(UIButton *)sender
{
    if (self.gameHasNotStarted) [self beginGame];
    self.gameVC.currentPlayer = self.nextPlayer;
    [self.navigationController pushViewController:self.gameVC animated:YES];
}

- (void)showDirectionsForRound
{
    UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"roundDirectionsNC"];
    FNRoundDirectionsVC *directions = (FNRoundDirectionsVC *)nc.topViewController;
    directions.brain = self.brain;
    directions.round = self.round;
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}

- (void)beginGame
{
    [self assignTeamsToPlayers];
    // remove the back button
    [self.navigationItem setLeftBarButtonItem:nil];
    // remove the previous view controllers from the stack because we dont want to go back to them anymore
    self.navigationController.viewControllers = @[self.navigationController.visibleViewController];
    // do the rest of the stuff to show the main game screen
    if (!self.gameVC) {
        self.gameVC = [self.storyboard instantiateViewControllerWithIdentifier:@"gameVC"];
        self.gameVC.brain = self.brain;
    }
    self.gameHasNotStarted = NO;
}

- (void)assignTeamsToPlayers
{
    // if this is the start of the first round then set team assignments both ways
    // destroying the distinction btwn game & user assigned teams
    for (FNTeam *team in self.brain.allTeams) {
        for (FNPlayer *player in team.players) {
            player.team = team;
        }
    }
}

#pragma mark - Life Cycle

- (void)setup
{
    // get and show the next player up
    self.nextPlayer = [self.brain nextPlayer];
    self.nextPlayerLabel.text = self.nextPlayer.name;

    self.roundLabel.text = [NSString stringWithFormat:@"Round %d", self.round];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *back = [FNAppearance backBarButtonItem];
    [back setTarget:self.navigationController];
    [back setAction:@selector(popViewControllerAnimated:)];
    [self.navigationItem setLeftBarButtonItem:back];
    
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
    UIBarButtonItem *options = [FNAppearance optionsBarButtonItem];
    [options setTarget:self];
    [options setAction:@selector(optionsBarButtonItemPressed)];
    [self.navigationItem setRightBarButtonItem:options];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Next Up"];

    self.scoreVC = self.childViewControllers[0];
    self.scoreVC.brain = self.brain;
    self.gameHasNotStarted = YES;
    self.showDirections = YES;
    self.round = 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // this is broken because when the directions disappear it changes the next player !!!
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // if this is the 1st turn for the 1st round show the coresponding directions
    if (self.showDirections) {
        [self showDirectionsForRound];
        self.showDirections = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end











