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
#import "FNScoreViewCell.h"
#import "FNAppearance.h"
#import "FNRoundDirectionsVC.h"
#import "FNGameVC.h"

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
// Game Screen (need to keep a reference to it when it is popped off the nav stack
@property (nonatomic, strong) FNGameVC *gameVC;
// if this is the beginning of the game then can go back to teams vc otherwise can't
@property (nonatomic) BOOL gameHasNotStarted;
@end

@implementation FNNextUpVC

/*

 
*/

#pragma mark - Navigation

- (void)optionsBarButtonItemPressed
{
    // create and show the options menu
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
    
    // if this is the 1st turn for the 1st round show the coresponding directions
    if (self.gameHasNotStarted) {
        [self showDirectionsForRound];
    }
    self.roundLabel.text = [NSString stringWithFormat:@"Round %d", self.round];

    // setup the score view / refresh it
    self.scoreVC.brain = self.brain;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.scoreVC willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
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

    self.scoreVC = [[FNScoreVC alloc] init];
    self.scoreVC.mainScoreBoard = self.mainScoreBoard;
    self.scoreVC.headerScoreBoard = self.headerScoreBoard;
    self.scoreVC.footerScoreBoard = self.footerScoreBoard;
    self.scoreVC.brain = self.brain;
    self.gameHasNotStarted = YES;
    self.round = 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end












