//
//  FNCountDownTimer.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNCountDownTimer.h"

@interface FNCountDownTimer ()
@property (nonatomic, weak) id <FNCountDownTimerDelegate> delegate;
@property (nonatomic, strong) NSTimer *timer;
@property NSInteger timeLeft;
@end

@implementation FNCountDownTimer

+ (void)newCountDownTimerWithDelegate:(id <FNCountDownTimerDelegate>)delegate;
{
    FNCountDownTimer *countDownTimer = [[FNCountDownTimer alloc] init];
    countDownTimer.delegate = delegate;
    countDownTimer.timeLeft = 60;
}

- (NSNumber *)timeRemaining
{
    return [NSNumber numberWithInteger:self.timeLeft];
}

- (void)timerFired
{
    self.timeLeft--;
    [self.delegate countDownTimerReachedTime:[NSNumber numberWithInteger:self.timeLeft]];
    if (self.timeLeft <= 0) {
        [self.timer invalidate];
    }
}

- (void)startCountDown
{
    if (self.timeLeft > 0 && !self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    }
}

- (void)stopCountDown
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc
{
    [self.timer invalidate];
}

@end