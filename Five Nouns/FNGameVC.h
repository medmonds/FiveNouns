//
//  FNGameVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/16/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNCountdownTimer.h"

@class FNPlayer;
@class FNBrain;

@interface FNGameVC : UIViewController <FNCountdownTimerDelegate>

@property (nonatomic, strong) FNBrain *brain;
@property (nonatomic, weak) FNPlayer *currentPlayer;

- (void)newGame;

- (void)countDownTimerReachedTime:(NSNumber *)time; // called every second
- (void)countDownTimerExpired;

@end