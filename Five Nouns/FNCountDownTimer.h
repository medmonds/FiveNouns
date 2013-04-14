//
//  FNCountDownTimer.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol FNCountDownTimerDelegate <NSObject>

- (void)countDownTimerReachedTime:(NSNumber *)time; // called every second

@end


@interface FNCountDownTimer : NSObject

+ (FNCountDownTimer *)newCountDownTimerWithDelegate:(id <FNCountDownTimerDelegate>)delegate;
- (NSNumber *)timeRemaining;
- (void)startCountDown;
- (void)stopCountDown;

@end
