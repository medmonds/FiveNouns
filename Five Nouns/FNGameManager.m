//
//  FNGameManager.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/12/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNGameManager.h"
#import "FNBrain.h"
#import "FNPlayer.h"
#import "FNScoreCard.h"

@interface FNGameManager ()
@property (nonatomic, strong) FNBrain *brain;
@property (nonatomic, weak) FNPlayer *currentPlayer;
@property (nonatomic, weak) NSString *currentNoun;
@property (nonatomic, weak) FNScoreCard *currentScoreCard;
@property NSInteger currentRound;
@property NSInteger currentTurn;
@end

@implementation FNGameManager


- (void)newGame
{
    self.currentRound = 0;
    self.currentTurn = 0;
    [self beginNewRound];
}

- (void)startTurnPressed
{
    // start timer
    // reveal first noun
}

- (void)nextNounPressed
{
    [self.currentScoreCard.nounsScored addObject:self.currentNoun];
    NSString *nextNoun = [self askBrainForNoun];
    if (nextNoun) {
        // show the new noun on the screen
    } else {
        // pause the timer
        [self roundEnded];
    }
}

- (NSString *)askBrainForNoun
{
    NSString *noun = [self.brain noun];
    if (noun) {
        return noun;
    } else {
        return nil;
    }
}

- (void)roundEnded
{
    // try to start a new round & reset the nouns in the brain
    if (self.currentRound < 4) {
        [self beginNewRound];
    } else {
        [self gameOver];
    }
}

- (void)beginNewRound;
{
    self.currentRound++;
    // show new round screen with directions & START_ROUND_BUTTON
}

- (void)startRoundPressed
{
    [self setupNewTurn];
    // show new turn screen with a START_TURN_BUTTON, & Timer
}

- (void)timeEnded
{
    // set the current timer to nil
    [self.brain addScoreCard:self.currentScoreCard];
    self.currentScoreCard = nil; // not necessary but I like it
    [self.brain returnUnplayedNoun:self.currentNoun];
    self.currentNoun = nil;
    // show next player button on current screen with expired time
}

- (void)setupNewTurn
{
    self.currentTurn++;
    self.currentPlayer = [self.brain player];
    NSString *noun = [self askBrainForNoun];
    // show the new turn screen with noun, timer, & NEXT_NOUN_BUTTON
    
}

- (void)gameOver
{
    
}

- (void)setCurrentPlayer:(FNPlayer *)currentPlayer
{
    FNScoreCard *newCard = [[FNScoreCard alloc] init];
    newCard.round = self.currentRound;
    newCard.turn = self.currentTurn;
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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
