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
#import "FNGameManager.h"
#import "FNRoundDirectionsVC.h"

#import "FNScoreVC.h"

@interface FNNextUpVC ()
@property (nonatomic, weak) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *nextPlayerLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;
// Score View
@property (nonatomic, strong) FNScoreVC *scoreVC;
// Direction modal
@property (nonatomic, strong) FNRoundDirectionsVC *directionsVC;
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
    [self assignTeamsToPlayers];
    // do the rest of the stuff to show the main game screen
}

- (void)showDirectionsForRound
{
    // put up the directions view
    [self performSegueWithIdentifier:@"roundDirections" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *nc = segue.destinationViewController;
    self.directionsVC = (FNRoundDirectionsVC *)nc.topViewController;
    self.directionsVC.brain = self.brain;
    self.directionsVC.round = self.round;
}

- (void)assignTeamsToPlayers
{
    // if this is the start of the first round then set team assignments both ways
    // destroying the distinction btwn game & user assigned teams
    if (self.round == 0) {
        for (FNTeam *team in self.brain.allTeams) {
            for (FNPlayer *player in team.players) {
                player.team = team;
            }
        }
    }
}

#pragma mark - Life Cycle

- (void)setup
{
    if (!self.player) {
        FNTeam *firstTeam = self.brain.allTeams[0];
        self.player = firstTeam.players[0];
    }    
    if (!self.round) {
        self.round = 1;
        [self showDirectionsForRound];
    }
    self.nextPlayerLabel.text = self.player.name;
    self.roundLabel.text = [NSString stringWithFormat:@"Round %d", self.round];
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
    
    if (self.navigationController) {
        // have not started yet so can go back to teams view
        UIBarButtonItem *back = [FNAppearance backBarButtonItem];
        [back setTarget:self.navigationController];
        [back setAction:@selector(popViewControllerAnimated:)];
        [self.navigationItem setLeftBarButtonItem:back];

    }    
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
    self.shouldShowDirections = YES;    
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












