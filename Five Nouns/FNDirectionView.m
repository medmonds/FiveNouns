//
//  FNDirectionView.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/23/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNDirectionView.h"
#import "FNAppearance.h"
#import <QuartzCore/QuartzCore.h>

@interface FNDirectionView ()
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *roundLabel;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) CALayer *contentBackground;
@end

@implementation FNDirectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _contentBackground = [[CALayer alloc] init];
    _contentBackground.backgroundColor = [UIColor whiteColor].CGColor;
    _contentBackground.cornerRadius = 3.0;
    [self.layer addSublayer:_contentBackground];
    
    _roundLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_roundLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    _roundLabel.backgroundColor = [UIColor clearColor];
    _roundLabel.font = [FNAppearance fontWithSize:30];
    _roundLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_roundLabel];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    [_textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.font = [FNAppearance fontWithSize:16];
    _textView.text = @"temp";
    _textView.userInteractionEnabled = NO;
    [self addSubview:_textView];
    
    _doneButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_doneButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_doneButton setBackgroundImage:[FNAppearance backgroundForCellWithStyle:FNTableViewCellStyleButton forPosition:FNTableViewCellPositionBottom] forState:UIControlStateNormal];
    [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
    _doneButton.titleLabel.font = [FNAppearance fontWithSize:26];
    [_doneButton setTitleColor:[FNAppearance textColorButton] forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_doneButton addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_doneButton];
    
    self.backgroundColor = [UIColor clearColor];//[UIColor colorWithWhite:.5 alpha:.5];
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self setAutolayoutConstraints];
}

- (void)setAutolayoutConstraints
{
    NSLayoutConstraint *labelCenterx = [NSLayoutConstraint constraintWithItem:_roundLabel
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_roundLabel.superview
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1
                                                                   constant:0];
    NSLayoutConstraint *labelWidth = [NSLayoutConstraint constraintWithItem:_roundLabel
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_roundLabel.superview
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:.8
                                                                   constant:0];
    NSLayoutConstraint *labelY = [NSLayoutConstraint constraintWithItem:_roundLabel
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_roundLabel.superview
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:.8
                                                               constant:0];
    NSLayoutConstraint *labelHeight = [NSLayoutConstraint constraintWithItem:_roundLabel
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:40];
    [_roundLabel.superview addConstraints:@[labelCenterx, labelWidth, labelY, labelHeight]];
    
    NSLayoutConstraint *textCenterx = [NSLayoutConstraint constraintWithItem:_textView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_textView.superview
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1
                                                                     constant:0];
    NSLayoutConstraint *textWidth = [NSLayoutConstraint constraintWithItem:_textView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_textView.superview
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:.8
                                                                   constant:0];
    NSLayoutConstraint *textY = [NSLayoutConstraint constraintWithItem:_textView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_roundLabel
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1 constant:0];
    NSLayoutConstraint *textHeight = [NSLayoutConstraint constraintWithItem:_textView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationLessThanOrEqual
                                                                     toItem:_textView.superview
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:100];
    [_textView.superview addConstraints:@[textCenterx, textWidth, textY, textHeight]];
    
    NSLayoutConstraint *buttonCenterx = [NSLayoutConstraint constraintWithItem:_doneButton
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_doneButton.superview
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1
                                                                     constant:0];
    NSLayoutConstraint *buttonWidth = [NSLayoutConstraint constraintWithItem:_doneButton
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_doneButton.superview
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:.8
                                                                   constant:0];
    NSLayoutConstraint *buttonHeight = [NSLayoutConstraint constraintWithItem:_doneButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                                constant:44];
    [_doneButton.superview addConstraints:@[buttonCenterx, buttonWidth, buttonHeight]];
}

- (void)setRound:(NSInteger)round
{
    _round = round;
    NSString *partial = @"Round ";
    if (self.round == 1) {
        partial = [partial stringByAppendingString:@"One"];
    } else if (self.round == 2) {
        partial = [partial stringByAppendingString:@"Two"];
    } else if (self.round == 3) {
        partial = [partial stringByAppendingString:@"Three"];
    } else {
        partial = [partial stringByAppendingString:@"Four"];
    }
    self.roundLabel.text = partial;
}

- (void)setDirections:(NSString *)directions
{
    _directions = directions;
    _textView.text = directions;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = _textView.frame;
    frame.size.height = _textView.contentSize.height;
    _textView.frame = frame;
    
    CGRect buttonFrame = _doneButton.frame;
    buttonFrame.origin.y = CGRectGetMaxY(_textView.frame);
    _doneButton.frame = buttonFrame;
    
    CGRect backgroundFrame = CGRectMake(CGRectGetMinX(_roundLabel.frame), CGRectGetMinY(_roundLabel.frame), CGRectGetWidth(_roundLabel.frame), CGRectGetMaxY(_doneButton.frame) - CGRectGetMinY(_roundLabel.frame));
    _contentBackground.frame =backgroundFrame;
}

- (void)donePressed:(id)sender
{
    [UIView animateWithDuration:.5 animations:^(void){
        self.alpha = 0;
    } completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
}

@end
