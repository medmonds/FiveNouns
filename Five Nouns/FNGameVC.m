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
#import "FNPausedVC.h"
#import "FNTurnData.h"
#import "FNTeam.h"

typedef NS_ENUM(NSInteger, FNGameState) {
    FNGameStateStart,
    FNGameStateEnd,
    FNGameStatePaused,
    FNGameStateGameOver
};

@interface FNGameVC ()
@property (nonatomic, weak) NSString *currentNoun;
@property (nonatomic, strong) FNScoreCard *currentScoreCard;
@property (nonatomic, strong) IBOutlet FNCountdownTimer *countDownTimer;
@property NSInteger currentRound;
@property NSInteger currentTurn;
@property (weak, nonatomic) IBOutlet UILabel *nounLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPlayerLabel;

@property (nonatomic, strong) FNDirectionView *directionsVC;
@property (nonatomic) FNGameState gameState;


//@property BOOL startTimerAndRevealNoun;     //                                          timerPressed    beginNewRound   setupNewTurn
//@property BOOL returnToNextUpVC;            // countDownTimerExpired                    timerPressed                    setupNewTurn            commonInit
// when this gets set when game is interrupted need to set self.startTimerAndRevealNoun = YES also
//@property BOOL gameWasPaused;               // displayNextNoun scoreKeep                                                setupNewTurn            commonInit
//@property BOOL gameIsOver;                  //                                          timerPressed                    setupNewTurn gameOver   commonInit

@end

@implementation FNGameVC
/*
 Juice it up!!
 Needs to make noise & maybe vibrate when time ends
 Noise when a noun is scored
 
 Make the timer flash when time expires
 
 ** Save the Game State
 THINGS TO SAVE
 - the current noun
 - the time remaining
 
 - the current score card
 - current round score
 - current round
 - current turn
 - current player
 
 
 
 
*/






- (void)saveCurrentGameState
{
    // send it to the brain the brain will handle the actual persistance
    // should probably be an object that way I can take this obj and start a turn on the fly with it too
    FNTurnData *turnData = [[FNTurnData alloc] init];
    turnData.noun = self.currentNoun;
    turnData.timeRemaining = self.countDownTimer.timeRemaining;
    turnData.scoreCard = self.currentScoreCard;
    turnData.round = self.currentRound;
    turnData.turn = self.currentTurn;
    turnData.player = self.currentPlayer;
    [self.brain saveCurrentTurn:turnData];
}

- (void)optionsBarButtonItemPressed
{
    UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"pausedNC"];
    FNPausedVC *options = (FNPausedVC *)nc.topViewController;
    options.brain = self.brain;
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}

- (void)countDownTimerExpired // turn is over
{
    self.countDownTimer.labelString = @"Next Player";
    self.nounLabel.text = @"Next Player";
    [self.currentPlayer.team addScoreCard:self.currentScoreCard];
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
        self.currentPlayer = [self.brain nextPlayer];
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
    self.directionsVC = [[FNDirectionView alloc] initWithFrame:self.view.bounds];
    self.directionsVC.round = self.currentRound;
    self.directionsVC.alpha = 0.0;
    self.directionsVC.presenter = self;
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    [self.view addSubview:self.directionsVC];
    [UIView animateWithDuration:0.3 animations:^(void){
        self.directionsVC.alpha = 1.0;
    }];
}

- (void)directionViewWasDismissed:(FNDirectionView *)view
{
    [self.navigationItem setRightBarButtonItem:[self optionsButton] animated:YES];
}

- (void)beginNewRound;
{
    self.currentRound++;
    self.currentScoreCard.round = self.currentRound;
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
    [self.currentPlayer.team addScoreCard:self.currentScoreCard];
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Players" forOrientation:toInterfaceOrientation];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit
{
    self.currentRound = 1;
    self.currentTurn = 0;
    self.returnToNextUpVC = NO;
    self.gameWasPaused = NO;
    self.gameIsOver = NO;
}

- (UIBarButtonItem *)optionsButton
{
    UIBarButtonItem *options = [FNAppearance optionsBarButtonItem];
    [options setTarget:self];
    [options setAction:@selector(optionsBarButtonItemPressed)];
    return options;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
    [self.navigationItem setRightBarButtonItem:[self optionsButton]];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Five Nouns" forOrientation:self.interfaceOrientation];
    [self.navigationItem setHidesBackButton:YES];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(timerPressed)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.nounLabel addGestureRecognizer:swipe];

    // Setup the timer control
    [self.countDownTimer addTarget:self action:@selector(timerPressed) forControlEvents:UIControlEventTouchUpInside];
    self.countDownTimer.delegate = self;
    self.countDownTimer.backgroundColor = [FNAppearance tableViewBackgroundColor];
    // might not need this !!!
    [self setupNewTurn];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.nounLabel.text = @"Get Ready!";
    self.currentPlayerLabel.text = self.currentPlayer.name;
    [self.brain setGameStatus:FNGameStatusTurnInProgress];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end













