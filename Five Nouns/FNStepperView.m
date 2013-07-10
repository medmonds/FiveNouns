//
//  FNStepperView.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/9/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNStepperView.h"
#import "FNAppearance.h"

@interface FNStepperView ()

@property UILabel *numberOfTeams;

@end


@implementation FNStepperView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)setMaxTeams:(NSInteger)maxTeams
{
    _maxTeams = maxTeams;
    self.stepper.maximumValue = maxTeams;
}

- (void)stepperDidStep:(UIStepper *)stepper
{
    self.numberOfTeams.text = [NSString stringWithFormat:@"%d", [@(stepper.value) integerValue]];
}

- (void)commonInit
{
    self.title = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.title setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.title.font = [FNAppearance fontWithSize:32];
    self.title.textColor = [FNAppearance textColorLabel];
    self.title.backgroundColor = [FNAppearance tableViewBackgroundColor];
    [self addSubview:self.title];

    self.numberOfTeams = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.numberOfTeams setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.numberOfTeams.font = [FNAppearance fontWithSize:32];
    self.numberOfTeams.textColor = [FNAppearance textColorLabel];
    self.numberOfTeams.text = @"0";
    self.numberOfTeams.backgroundColor = [FNAppearance tableViewBackgroundColor];
    [self addSubview:self.numberOfTeams];

    self.stepper = [[UIStepper alloc] initWithFrame:CGRectMake(0, 0, 94, 27)];
    [self.stepper setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.stepper.wraps = YES;
    [self.stepper addTarget:self action:@selector(stepperDidStep:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.stepper];
    
    self.backgroundColor = [FNAppearance tableViewBackgroundColor];
    
    // the proxy in apperance.m does not set the increment & decrement images !!!
    [self.stepper setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    [self.stepper setIncrementImage:[UIImage imageNamed:@"incrementImage.png"] forState:UIControlStateNormal];
    [self.stepper setDecrementImage:[UIImage imageNamed:@"decrementImage.png"] forState:UIControlStateNormal];
    [self.stepper setDividerImage:[[UIImage alloc] init] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal];
    [self setupConstraints];
}

- (void)setupConstraints
{
    NSLayoutConstraint *numberRight = [NSLayoutConstraint constraintWithItem:self.numberOfTeams
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1
                                                                    constant:-12];
    NSLayoutConstraint *numberWidth = [NSLayoutConstraint constraintWithItem:self.numberOfTeams
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:32];
    NSLayoutConstraint *numberHeight = [NSLayoutConstraint constraintWithItem:self.numberOfTeams
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1
                                                                     constant:32];
    NSLayoutConstraint *numberCenter = [NSLayoutConstraint constraintWithItem:self.numberOfTeams
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1
                                                                     constant:0];
    [self.numberOfTeams.superview addConstraints:@[numberRight, numberWidth, numberHeight, numberCenter]];
    
    NSLayoutConstraint *stepperRight = [NSLayoutConstraint constraintWithItem:self.stepper
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.numberOfTeams
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1
                                                                     constant:-12];
    NSLayoutConstraint *stepperCenter = [NSLayoutConstraint constraintWithItem:self.stepper
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.stepper.superview
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1
                                                                      constant:0];
    [self.stepper.superview addConstraints:@[stepperRight, stepperCenter]];
    
    
    NSLayoutConstraint *titleLeft = [NSLayoutConstraint constraintWithItem:self.title
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:12];
    NSLayoutConstraint *titleHeight = [NSLayoutConstraint constraintWithItem:self.title
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:32];
    NSLayoutConstraint *titleRight = [NSLayoutConstraint constraintWithItem:self.title
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.stepper
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1
                                                                   constant:-12];
    NSLayoutConstraint *titleCenter = [NSLayoutConstraint constraintWithItem:self.title
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:0];
    [self.title.superview addConstraints:@[titleLeft, titleHeight, titleRight, titleCenter]];
}


@end















