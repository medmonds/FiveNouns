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
#import "FNTeam.h"

typedef NS_ENUM(NSInteger, FNGameState) {
    FNGameStateStart,
    FNGameStateRunning,
    FNGameStateEnd,
    FNGameStatePaused,
    FNGameStateGameOver
};

@interface FNGameVC ()
@property (nonatomic, weak) NSString *currentNoun;
@property (nonatomic, strong) IBOutlet FNCountdownTimer *countDownTimer;
@property (weak, nonatomic) IBOutlet UILabel *nounLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPlayerLabel;

@property (nonatomic, strong) FNDirectionView *directionsVC;
@property (nonatomic) FNGameState gameState;

@end

@implementation FNGameVC
/*
 Juice it up!!
 Needs to make noise & maybe vibrate when time ends
 Noise when a noun is scored
 
 
 ** Save the Game State
 THINGS TO SAVE
 - the time remaining
  
 
when in observer mode:
 watch the score change
 the timer change
 when paused
 when the round changes
 get the currentPlayer from the brain
 
 
When in player mode:
 don't need to watch anything
 can make all changes instantly
 need to tell the brain:
    what the time remaining is - no send updates for events and then dead reckon on the clients
        when doing this should send the event & a timeStamp so can account for the lag getting to remote players
    when game is paused
 
*/






- (void)saveCurrentGameState
{
    self.brain.timeRemaining = self.countDownTimer.timeRemaining;
}

- (void)optionsBarButtonItemPressed
{
    [self pauseGame];
    UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"pausedNC"];
    FNPausedVC *options = (FNPausedVC *)nc.topViewController;
    options.brain = self.brain;
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}

- (void)countDownTimerExpired // turn is over
{
    self.countDownTimer.labelString = @"Next Player";
    [self setNounDisplayString:@"Next Player"];
    [self.brain returnUnplayedNoun:self.currentNoun];
    self.currentNoun = nil;
    self.gameState = FNGameStateEnd;
    self.brain.timeRemaining = 0;
}

- (void)countDownTimerReachedTime:(NSNumber *)time
{
    // refresh the countdown time left display if implemented
}

- (void)nextNoun
{
    NSString *nextNoun;
    switch (self.gameState) {
        case FNGameStatePaused:
            nextNoun = self.currentNoun;
            break;
            
        default:
            nextNoun = [self.brain nextNoun];
            break;
    }
    
    if (nextNoun) {
        self.currentNoun = nextNoun;
        [self setNounDisplayString:nextNoun];
    } else {
        // out of nouns so round ends & time stops
        [self.countDownTimer stopCountDown];
        [self roundEnded];
    }
}

// show the new noun on the screen
- (void)setNounDisplayString:(NSString *)noun
{
    if (!noun) return;
    self.nounLabel.text = noun;
    [self.nounLabel setNeedsDisplay];
}

- (void)scoreKeep
{
    if (self.currentNoun) {
        [self.brain nounScored:self.currentNoun forPlayer:self.currentPlayer];
        self.scoreLabel.text = [NSString stringWithFormat:@"Nouns: %d", [self.brain scoreForCurrentTurn]];
        [self.scoreLabel setNeedsDisplay];
        self.currentNoun = nil;
    }
}
- (void)timerPressed
{
    switch (self.gameState) {
        case FNGameStateGameOver:
            // go to the game over screen
            break;
            
        case FNGameStateEnd:
            self.gameState = FNGameStateStart;
            [self.brain turnEndedForPlayer:self.currentPlayer];
            [self.navigationController popViewControllerAnimated:YES];
            return;
            
        case FNGameStateStart:
            [self resumeGame];
            break;
            
        case FNGameStateRunning:
            [self scoreKeep];
            [self nextNoun];
            break;
            
        case FNGameStatePaused:
            [self resumeGame];
            break;
            
        default:
            break;
    }
}


- (void)roundEnded
{
    // try to start a new round & reset the nouns in the brain
    self.currentNoun = nil; // do i need to set this to nil? !!!
    if (self.brain.round < 4) {
        [self beginNewRound];
    } else {
        [self gameOver];
    }
}

- (void)showDirectionsForRound
{
    self.directionsVC = [[FNDirectionView alloc] initWithFrame:self.view.bounds];
    self.directionsVC.round = self.brain.round;
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
    [self showDirectionsForRound];
    self.countDownTimer.labelString = @"Start";
    [self setNounDisplayString:@"New Round"];
    [self.brain prepareForNewRound];
    self.gameState = FNGameStateStart;
}

- (void)setupNewTurn
{
    [self.countDownTimer resetCountdown];
    self.gameState = FNGameStateStart;
    self.scoreLabel.text = @"Nouns: 0";
    [self.scoreLabel setNeedsDisplay];
    self.countDownTimer.labelString = @"Start";
    [self setNounDisplayString:@"Get Ready!"];
}

- (void)pauseGame
{
    self.gameState = FNGameStatePaused;
    [self.countDownTimer stopCountDown];
    [self setNounDisplayString:@"Paused"];
    self.countDownTimer.labelString = @"Resume";
    // tell the brain for Multiplayer !!!
}

- (void)resumeGame
{
    [self.countDownTimer startCountDown];
    [self nextNoun];
    self.countDownTimer.labelString = @"Next";
    self.gameState = FNGameStateRunning;
    // tell the brain for Multiplayer !!!
}

- (void)gameOver
{
    self.countDownTimer.labelString = @"Game Over";
    self.gameState = FNGameStateGameOver;
    [self.brain gameOver];
    // show the game over screen
}

- (void)setCurrentPlayer:(FNPlayer *)currentPlayer
{
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
    self.gameState = FNGameStateStart;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willResignActive
{
    [self pauseGame];
}

- (void)didBecomeActive
{
    
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
    self.currentPlayerLabel.text = self.currentPlayer.name;
    [self.brain setGameStatus:FNGameStatusTurnInProgress];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end













