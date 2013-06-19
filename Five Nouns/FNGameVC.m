//
//  FNGameVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/16/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNGameVC.h"
#import "FNBrain.h"
#import "FNPlayer.h"
#import "FNScoreCard.h"
#import "FNCountdownTimer.h"
#import "FNAppearance.h"
#import "FNRoundDirectionsVC.h"

@interface FNGameVC ()
@property (nonatomic, weak) NSString *currentNoun;
@property (nonatomic, strong) FNScoreCard *currentScoreCard;
@property (nonatomic, strong) IBOutlet FNCountdownTimer *countDownTimer;
@property NSInteger currentRound;
@property NSInteger currentTurn;
@property (weak, nonatomic) IBOutlet UILabel *nounLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPlayerLabel;

@property BOOL startTimerAndRevealNoun;
@property BOOL returnToNextUpVC;
// when this gets set when game is interrupted need to set self.startTimerAndRevealNoun = YES also
@property BOOL gameWasPaused;
@property BOOL gameIsOver;

@end

@implementation FNGameVC

- (void)optionsBarButtonItemPressed
{
    // create and show the options menu
}

- (void)countDownTimerExpired
{
    self.countDownTimer.labelString = @"Next Player";
    [self.brain addScoreCard:self.currentScoreCard];
    self.currentScoreCard = nil; // not necessary but I like it
    [self.brain returnUnplayedNoun:self.currentNoun];
    self.currentNoun = nil;
    self.returnToNextUpVC = YES;
}

- (void)countDownTimerReachedTime:(NSNumber *)time
{
    // refresh the countdown time left display if implemented
}

- (void)displayNextNoun
{
    NSString *nextNoun;
    if (self.gameWasPaused) {
        nextNoun = self.currentNoun;
    } else {
        nextNoun = [self.brain noun];
    }
    if (nextNoun) {
        // show the new noun on the screen
        self.currentNoun = nextNoun;
        self.nounLabel.text = nextNoun;
    } else {
        // out of nouns so round ends & time stops
        [self.countDownTimer stopCountDown];
        [self roundEnded];
    }
}

- (void)scoreKeep
{
    if (self.currentNoun && !self.gameWasPaused) {
        [self.currentScoreCard.nounsScored addObject:self.currentNoun];
        self.scoreLabel.text = [NSString stringWithFormat:@"Nouns: %d", [self.currentScoreCard.nounsScored count]];
        [self.scoreLabel setNeedsDisplay];
        self.currentNoun = nil;
    }
}
- (void)timerPressed
{
    if (self.gameIsOver) {
        // go to a game over screen
    } else if (self.returnToNextUpVC) {
        // pop the gamevc back to the NextUpVC
        self.returnToNextUpVC = NO;
        [self.navigationController popViewControllerAnimated:YES];
        return;
    } else if (self.startTimerAndRevealNoun) {
        self.startTimerAndRevealNoun = NO;
        self.countDownTimer.labelString = @"Next";
        [self.countDownTimer startCountDown];
    }
    [self scoreKeep];
    [self displayNextNoun];
}


- (void)roundEnded
{
    // try to start a new round & reset the nouns in the brain
    self.currentNoun = nil;
    if (self.currentRound < 4) {
        [self beginNewRound];
    } else {
        [self gameOver];
    }
}

- (void)showDirectionsForRound
{
    UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"roundDirectionsNC"];
    FNRoundDirectionsVC *directions = (FNRoundDirectionsVC *)nc.topViewController;
    directions.brain = self.brain;
    directions.round = self.currentRound;
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}

- (void)beginNewRound;
{
    self.currentRound++;
    [self showDirectionsForRound];
    self.countDownTimer.labelString = @"Start";
    self.nounLabel.text = @"New Round";
    [self.nounLabel setNeedsDisplay];
    [self.brain prepareForNewRound];
    self.startTimerAndRevealNoun = YES;
}

- (void)startRoundPressed
{
    [self setupNewTurn];
    // show new turn screen with a START_TURN_BUTTON, & Timer
}

- (void)setupNewTurn
{
    self.currentTurn++;
    [self.countDownTimer resetCountdown];
    self.startTimerAndRevealNoun = YES;
    self.scoreLabel.text = [NSString stringWithFormat:@"Nouns: %d", [self.currentScoreCard.nounsScored count]];
    [self.scoreLabel setNeedsDisplay];
    self.countDownTimer.labelString = @"Start";
    // these might be unnecessary
    self.returnToNextUpVC = NO;
    self.gameWasPaused = NO;
    self.gameIsOver = NO;
}

- (void)gameOver
{
    self.countDownTimer.labelString = @"Game Over";
    self.gameIsOver = YES;
    [self.brain addScoreCard:self.currentScoreCard];
    self.currentScoreCard = nil; // not necessary but I like it

    // show the game over screen
    // add the current scoreCard to the brain
}

- (void)setCurrentPlayer:(FNPlayer *)currentPlayer
{
    _currentScoreCard = [[FNScoreCard alloc] init];
    _currentScoreCard.round = self.currentRound;
    _currentScoreCard.turn = self.currentTurn;
    _currentScoreCard.player = currentPlayer;
    [self setupNewTurn];
    _currentPlayer = currentPlayer;
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
    
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
    UIBarButtonItem *options = [FNAppearance optionsBarButtonItem];
    [options setTarget:self];
    [options setAction:@selector(optionsBarButtonItemPressed)];
    [self.navigationItem setRightBarButtonItem:options];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Five Nouns"];
    [self.navigationItem setHidesBackButton:YES];

    // Setup the timer control
    [self.countDownTimer addTarget:self action:@selector(timerPressed) forControlEvents:UIControlEventTouchUpInside];
    self.countDownTimer.delegate = self;
    self.currentRound = 1;
    self.currentTurn = 0;
    self.returnToNextUpVC = NO;
    self.gameWasPaused = NO;
    self.gameIsOver = NO;
    // might not need this !!!
    [self setupNewTurn];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.nounLabel.text = @"Get Ready!";
    self.currentPlayerLabel.text = self.currentPlayer.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end













