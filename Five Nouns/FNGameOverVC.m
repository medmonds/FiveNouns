//
//  FNGameOverVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 9/18/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNGameOverVC.h"
#import "FNScoreVC.h"
#import "FNButtonRect.h"
#import "FNBrain.h"
#import "FNScoreCard.h"
#import "FNTeam.h"
#import "FNNewGameVC.h"

@interface FNGameOverVC ()
@property (weak, nonatomic) IBOutlet UILabel *winnerLabel;
@property (weak, nonatomic) IBOutlet FNButtonRect *endGameButton;
@property (nonatomic, strong) FNScoreVC *scoreVC;
@end

@implementation FNGameOverVC

/*************************************** Notes ********************************************
 
 - show the winner
 - show the scores
 - have a way to return to the Main Menu
 - roll credits?
 
 should have the scorevc show the teams in ranked order not turn order in this view
 
******************************************************************************************/

- (void)setTableView:(UITableView *)tableView
{
    tableView.dataSource = self;
    tableView.delegate = self,
    self.tableView = tableView;
}

- (IBAction)endGamePressed:(id)sender
{
    // should prob subclass a navcontroller for all navigation and then have it handle this logic
    
    // instaniate the main menu controller & push it on the stack
    FNNewGameVC *mainMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGameVC"];
    [self.navigationController setViewControllers:@[mainMenu] animated:YES];
}

- (void)displayWinnersName
{
    self.winnerLabel.text = [self winnersName];
}

- (NSString *)winnersName
{
    NSMutableArray *teams = [[self.brain orderOfTeams] mutableCopy];
    [teams sortUsingComparator:^NSComparisonResult(FNTeam *team1, FNTeam *team2) {
        if ([self scoreForTeam:team2] > [self scoreForTeam:team1]) {
            return NSOrderedDescending;
        } else if ([self scoreForTeam:team1] > [self scoreForTeam:team2]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    return ((FNTeam *)teams[0]).name;
}

- (NSInteger)scoreForTeam:(FNTeam *)team
{
    NSInteger score = 0;
    NSArray *scoreCardsForTeam = [self.brain scoreCardsForTeam:team];
    for (FNScoreCard *card in scoreCardsForTeam) {
        score += [card.nounsScored count];
    }
    return score;
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
    [self.navigationItem setHidesBackButton:YES];
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Game Over" forOrientation:self.interfaceOrientation];
    self.scoreVC = self.childViewControllers[0];
    self.scoreVC.brain = self.brain;
    [self.scoreVC orderTeamsByScore];
    [self displayWinnersName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
