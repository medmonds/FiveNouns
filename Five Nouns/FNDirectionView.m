//
//  FNDirectionView.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/23/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNDirectionView.h"
#import "FNAppearance.h"

@interface FNDirectionView ()
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *roundLabel;
@property (nonatomic, strong) UIButton *doneButton;
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
    _roundLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
    [_roundLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    _roundLabel.backgroundColor = [UIColor redColor];
    _roundLabel.font = [FNAppearance fontWithSize:30];
    _roundLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_roundLabel];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
    [_textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.font = [FNAppearance fontWithSize:16];
    _textView.text = @"temp";
    _textView.userInteractionEnabled = NO;
    [self addSubview:_textView];
    
    _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    [_doneButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    _doneButton.backgroundColor = [UIColor blueColor];
    [self addSubview:_doneButton];
    
    self.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
    
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
                                                             multiplier:1
                                                               constant:100];
    [_roundLabel.superview addConstraints:@[labelCenterx, labelWidth, labelY]];
    
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
    NSLayoutConstraint *buttonY = [NSLayoutConstraint constraintWithItem:_doneButton
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_textView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                                constant:0];
    [_doneButton.superview addConstraints:@[buttonCenterx, buttonWidth, buttonY]];
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
//    CGRect frame = _textView.frame;
//    frame.size.height = _textView.contentSize.height;
//    _textView.frame = frame;
    [self setNeedsLayout];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
