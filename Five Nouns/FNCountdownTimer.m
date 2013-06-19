//
//  FNCountdownTimer.m
//  Test
//
//  Created by Matthew Edmonds on 6/3/13.
//  Copyright (c) 2013 Edmonds. All rights reserved.
//

#import "FNCountdownTimer.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "FNAppearance.h"

#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )


NSString * const FNCDTTextLabelText = @"Start";

@interface FNCountdownTimer ()

@property (nonatomic, strong) NSTimer *timer;
@property NSInteger timeLeft;
@property BOOL isCountingDown;
@property BOOL useClientText;

@property (nonatomic) CGFloat angle;
@property (nonatomic, strong) CATextLayer *textLayer;
@property (nonatomic, strong) CAShapeLayer *indicatorLayer;
@property (nonatomic, strong) CAShapeLayer *touchCatcherLayer;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) NSString *text;

@end

@implementation FNCountdownTimer

@synthesize font = _font;
@synthesize text = _text;
@synthesize textColor = _textColor;
@synthesize timeElapsedColor = _timeElapsedColor;
@synthesize timeRemainingColor = _timeRemainingColor;
@synthesize centerColor = _centerColor;
@synthesize labelString = _labelString;


- (UIFont *)font
{
    if (!_font) {
        _font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
    }
    return _font;
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    
    // Don't animate the font change
    self.textLayer.font = CGFontCreateWithFontName((__bridge CFStringRef)[font fontName]);
    self.textLayer.frame = [self textLayerFrame];
    self.textLayer.fontSize = [self fontSize];
}

// Client controlled string
- (void)setLabelString:(NSString *)labelString
{
    _labelString = labelString;
    self.useClientText = YES;
    self.text = labelString;
}

- (NSString *)labelString
{
    if (!_labelString) {
        _labelString = self.text;
    }
    return _labelString;
}

- (NSString *)text
{
    if (!_text) {
        _text = FNCDTTextLabelText;
    }
    return _text;
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    // the client has set the text so do not use the default Start & Stop Strings
    
    // Animate the string change
    [CATransaction begin];
    [CATransaction setCompletionBlock:^(void){
        // to kill the implicit animation triggered by changing the string
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.textLayer.string = text;
        [CATransaction commit];
        CABasicAnimation *increase = [CABasicAnimation animationWithKeyPath:@"opacity"];
        increase.toValue = @(1.0);
        increase.duration = 0.3;
        self.textLayer.opacity = 1.0;
        [self.textLayer addAnimation:increase forKey:nil];
    }];
    CABasicAnimation *decrease = [CABasicAnimation animationWithKeyPath:@"opacity"];
    decrease.toValue = @(0.0);
    decrease.duration = 0.2;
    self.textLayer.opacity = 0.0;
    [self.textLayer addAnimation:decrease forKey:nil];
    [CATransaction commit];
}

- (UIColor *)textColor
{
    if (!_textColor) {
        _textColor = [FNAppearance textColorButton];
    }
    return _textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    // redraw the text layer
    self.textLayer.foregroundColor = textColor.CGColor;
}

- (UIColor *)timeElapsedColor
{
    if (!_timeElapsedColor) {
        _timeElapsedColor = [FNAppearance textColorButton];
    }
    return _timeElapsedColor;
}

- (void)setTimeElapsedColor:(UIColor *)timeElapsedColor
{
    _timeElapsedColor = timeElapsedColor;
    //redraw the indicator layer
    self.indicatorLayer.strokeColor = timeElapsedColor.CGColor;
}

- (UIColor *)timeRemainingColor
{
    if (!_timeRemainingColor) {
        _timeRemainingColor = [FNAppearance backgroundColorAccent];
    }
    return _timeRemainingColor;
}

- (void)setTimeRemainingColor:(UIColor *)timeRemainingColor
{
    _timeRemainingColor = timeRemainingColor;
    // redraw the background layer
    self.backgroundLayer.strokeColor = timeRemainingColor.CGColor;
}

- (UIColor *)centerColor
{
    if (!_centerColor) {
        _centerColor = [FNAppearance tableViewBackgroundColor];
    }
    return _centerColor;
}

- (void)setCenterColor:(UIColor *)centerColor
{
    _centerColor = centerColor;
    // redraw the background layer
    self.backgroundLayer.fillColor = centerColor.CGColor;
}

+ (FNCountdownTimer *)newCountDownTimerWithDelegate:(id <FNCountdownTimerDelegate>)delegate;
{
    FNCountdownTimer *countDownTimer = [[FNCountdownTimer alloc] init];
    countDownTimer.delegate = delegate;
    countDownTimer.timeLeft = 600;
    return countDownTimer;
}

- (NSInteger)timeRemaining
{
    return self.timeLeft;
}

- (void)animateIndicatorSweep
{
    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    basic.toValue = @(self.angle);
    basic.duration = .1f;
    basic.autoreverses = NO;
    self.indicatorLayer.strokeEnd = self.angle;
    [self.indicatorLayer addAnimation:basic forKey:nil];
}

- (void)timerFired
{
    self.timeLeft--;
    if ([self.delegate respondsToSelector:@selector(countDownTimerReachedTime:)]) {
        [self.delegate countDownTimerReachedTime:[NSNumber numberWithInteger:self.timeLeft]];
    }
    // compute the new angle for the indicator
    self.angle = 1.0f - (self.timeLeft / 600.0F);
    [self animateIndicatorSweep];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    if (self.timeLeft <= 0) {
        [self.timer invalidate];
        if ([self.delegate respondsToSelector:@selector(countDownTimerExpired)]) {
            [self.delegate countDownTimerExpired];
        }
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    if (CGPathContainsPoint(self.touchCatcherLayer.path, nil, touchPoint, NO)) {
        [super beginTrackingWithTouch:touch withEvent:event];
        return YES;
    }
    return NO;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    //    if (self.touchInside) {
    //        if (self.isCountingDown) {
    //            [self stopCountDown];
    //        } else {
    //            [self startCountDown];
    //        }
    //    }
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)startCountDown
{
    if (self.timeLeft > 0 && !self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
        self.isCountingDown = YES;
        if (!self.useClientText) {
            self.text = self.stringForStop ? self.stringForStop : @"Stop";
        }
    }
}

- (void)stopCountDown
{
    [self.timer invalidate];
    self.timer = nil;
    self.isCountingDown = NO;
    if (!self.useClientText) {
        self.text = self.stringForStart ? self.stringForStart : @"Start";
    }
}

- (void)resetCountdown
{
    self.timeLeft = 50;
    self.angle = 0.0;
    [self.timer invalidate];
    self.timer = nil;
    self.text = nil;
    self.useClientText = NO;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.indicatorLayer.strokeEnd = 0.0;
    [CATransaction commit];
}

- (void)dealloc
{
    [self.timer invalidate];
}

- (NSInteger)outerRadius
{
    return (MIN(self.frame.size.width, self.frame.size.height) / 2);
}

- (NSInteger)indicatorRadius
{
    return [self outerRadius] - ([self lineWidth] / 2);
}

- (NSInteger)lineWidth
{
    return [self outerRadius] * .4;
}

- (UIBezierPath *)timerPath
{
    NSInteger outerRadius = [self outerRadius];
    NSInteger lineWidth = [self lineWidth];
    NSInteger arcRadius = outerRadius - (lineWidth / 2);
    CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
    return [UIBezierPath bezierPathWithArcCenter:centerPoint radius:arcRadius startAngle:ToRad(-90) endAngle:ToRad(270) clockwise:YES];
}

- (UIBezierPath *)touchCatcherPath
{
    NSInteger outerRadius = [self outerRadius];
    CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
    return [UIBezierPath bezierPathWithArcCenter:centerPoint radius:outerRadius startAngle:ToRad(-90) endAngle:ToRad(270) clockwise:YES];
}

- (NSInteger)fontSize
{
    NSInteger heigthTimesWidth = 0;
    NSInteger fontSize = 0;
    NSInteger innerRadiusSquared = SQR([self indicatorRadius] - ([self lineWidth] / 2.0f));
    CGSize titleSize;
    UIFont *font;
    while (heigthTimesWidth <= innerRadiusSquared) {
        fontSize ++;
        font = [UIFont fontWithName:[[self font] fontName] size:fontSize];
        titleSize = [self.text sizeWithFont:font];
        heigthTimesWidth = (SQR(titleSize.height / 2) + SQR(titleSize.width / 2));
    }
    // The last loop will make it too big.
    return fontSize--;
}

- (CGRect)textLayerFrame
{
    NSInteger heigthTimesWidth = 0;
    NSInteger fontSize = 0;
    NSInteger innerRadiusSquared = SQR([self indicatorRadius] - ([self lineWidth] / 2.0f));
    CGSize titleSize;
    UIFont *font;
    while (heigthTimesWidth <= innerRadiusSquared) {
        fontSize ++;
        font = [UIFont fontWithName:[[self font] fontName] size:fontSize];
        titleSize = [self.text sizeWithFont:font];
        heigthTimesWidth = (SQR(titleSize.height / 2) + SQR(titleSize.width / 2));
    }
    // The last loop will make the font too big.
    titleSize = [self.text sizeWithFont:[font fontWithSize:fontSize--]];
    return CGRectMake(((self.frame.size.width - titleSize.width) / 2), ((self.frame.size.height - titleSize.height) / 2), titleSize.width, titleSize.height);
}

- (CAShapeLayer *)backgroundLayer
{
    if (!_backgroundLayer) {
        CAShapeLayer *background = [[CAShapeLayer alloc] init];
        background.path = [self timerPath].CGPath;
        background.lineWidth = [self lineWidth];
        background.strokeColor = [self timeRemainingColor].CGColor;
        background.fillColor = [self centerColor].CGColor;
        _backgroundLayer = background;
    }
    return _backgroundLayer;
}

- (CAShapeLayer *)indicatorLayer
{
    if (!_indicatorLayer) {
        CAShapeLayer *indicator = [[CAShapeLayer alloc] init];
        indicator.path = [self timerPath].CGPath;
        indicator.lineWidth = [self lineWidth] - 2;
        indicator.strokeColor = [self timeElapsedColor].CGColor;
        indicator.strokeStart = 0;
        indicator.strokeEnd = 0;
        indicator.fillColor = [UIColor clearColor].CGColor;
        _indicatorLayer = indicator;
    }
    return _indicatorLayer;
}

- (CAShapeLayer *)touchCatcherLayer
{
    if (!_touchCatcherLayer) {
        CAShapeLayer *touchCatcher = [[CAShapeLayer alloc] init];
        touchCatcher.path = [self touchCatcherPath].CGPath;
        touchCatcher.strokeColor = [UIColor clearColor].CGColor;
        touchCatcher.backgroundColor = [UIColor clearColor].CGColor;
        touchCatcher.fillColor = [UIColor clearColor].CGColor;
        _touchCatcherLayer = touchCatcher;
    }
    return _touchCatcherLayer;
}

- (CATextLayer *)textLayer
{
    if (!_textLayer) {
        CATextLayer *layer = [[CATextLayer alloc] init];
        layer.frame = [self textLayerFrame];
        layer.backgroundColor = [UIColor clearColor].CGColor;
        layer.foregroundColor = [self textColor].CGColor;
        layer.alignmentMode = kCAAlignmentCenter;
        layer.string = self.text;
        layer.font = CGFontCreateWithFontName((__bridge CFStringRef)[[self font] fontName]);
        layer.fontSize = [self fontSize];
        layer.contentsScale = [[UIScreen mainScreen] scale];
        _textLayer = layer;
    }
    return _textLayer;
}

- (void)commonInit
{
    self.timeLeft = 50;
    self.angle = 0.0;
    self.opaque = NO;
    [self.layer addSublayer:self.backgroundLayer];
    [self.layer addSublayer:self.indicatorLayer];
    [self.layer addSublayer:self.touchCatcherLayer];
    [self.layer addSublayer:self.textLayer];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    self.indicatorLayer.path = [self timerPath].CGPath;
    self.indicatorLayer.lineWidth = [self lineWidth] - 2;
    self.backgroundLayer.path = [self timerPath].CGPath;
    self.backgroundLayer.lineWidth = [self lineWidth];
    self.touchCatcherLayer.path = [self touchCatcherPath].CGPath;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.textLayer.frame = [self textLayerFrame];
    self.textLayer.fontSize = [self fontSize];
    [CATransaction commit];
}

@end















