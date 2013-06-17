//
//  FNCountdownTimer.h
//  Test
//
//  Created by Matthew Edmonds on 6/3/13.
//  Copyright (c) 2013 Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol FNCountdownTimerDelegate <NSObject>

@optional
- (void)countDownTimerReachedTime:(NSNumber *)time; // called every second
- (void)countDownTimerExpired;
@end

@interface FNCountdownTimer : UIControl

@property (nonatomic, strong) UIFont *font;
// If text is set all other default behavior is overridden; you must manually set the text
@property (nonatomic, strong) NSString *labelString;
@property (nonatomic, strong) NSString *stringForStart;
@property (nonatomic, strong) NSString *stringForStop;
@property (nonatomic, strong) UIColor *timeRemainingColor;
@property (nonatomic, strong) UIColor *timeElapsedColor;
@property (nonatomic, strong) UIColor *centerColor;
@property (nonatomic, strong) UIColor *textColor;


+ (FNCountdownTimer *)newCountDownTimerWithDelegate:(id <FNCountdownTimerDelegate>)delegate;
@property (nonatomic, weak) id <FNCountdownTimerDelegate> delegate;
- (NSInteger)timeRemaining;
- (void)startCountDown;
- (void)stopCountDown;
- (void)resetCountdown;
@end
