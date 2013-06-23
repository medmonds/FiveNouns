//
//  FNSeparatorCell.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/23/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNSeparatorCell.h"
#import "FNAppearance.h"

@interface FNSeparatorCell ()
@property (nonatomic, strong) UIView *partialSeparator;
@property (nonatomic, strong) UIView *separator;
@end

#define PARTIAL_SEPARATOR_HEIGHT 1
#define SEPARATOR_HEIGHT 2
#define PARTIAL_SEPARATOR_WIDTH 30

@implementation FNSeparatorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
}

- (void)commonInit
{
    self.textLabel.highlightedTextColor = [FNAppearance textColorLabel];

    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    
    _partialSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    [_partialSeparator setTranslatesAutoresizingMaskIntoConstraints:NO];
    _partialSeparator.backgroundColor = [FNAppearance cellSeparatorColor];
        
    _separator = [[UIView alloc] initWithFrame:CGRectZero];
    [_separator setTranslatesAutoresizingMaskIntoConstraints:NO];
    _separator.backgroundColor = [FNAppearance cellSeparatorColor];

    self.backgroundView = backgroundView;
}

- (void)addSeparatorConstraints
{
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_partialSeparator
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_partialSeparator.superview
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1
                                                                constant:PARTIAL_SEPARATOR_WIDTH];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_partialSeparator
                                                                attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_partialSeparator.superview
                                                                attribute:NSLayoutAttributeRight
                                                               multiplier:1
                                                                 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_partialSeparator
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_partialSeparator.superview
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_partialSeparator
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:PARTIAL_SEPARATOR_HEIGHT];
    [_partialSeparator.superview addConstraints:@[leading, trailing, bottom, height]];
    
    NSLayoutConstraint *leading1 = [NSLayoutConstraint constraintWithItem:_separator
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_separator.superview
                                                                attribute:NSLayoutAttributeLeft
                                                               multiplier:1
                                                                 constant:0];
    NSLayoutConstraint *trailing1 = [NSLayoutConstraint constraintWithItem:_separator
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_separator.superview
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1
                                                                  constant:0];
    NSLayoutConstraint *bottom1 = [NSLayoutConstraint constraintWithItem:_separator
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_separator.superview
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1
                                                                constant:0];
    NSLayoutConstraint *height1 = [NSLayoutConstraint constraintWithItem:_separator
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1
                                                                constant:SEPARATOR_HEIGHT];
    [_partialSeparator.superview addConstraints:@[leading1, trailing1, bottom1, height1]];
}

- (void)setShowCellSeparator:(BOOL)showCellSeparator
{
    if (showCellSeparator) {
        [self.backgroundView addSubview:self.separator];
    } else {
        [self.separator removeFromSuperview];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        // Add the partial width seperator line to the bottom of the cell
        self.partialSeparator.alpha = 0;
        [UIView animateWithDuration:.3 animations:^(void){
            self.separator.alpha = 0;
            self.partialSeparator.alpha = 1;
        }];
    } else {
        // Conditionally add the seperator
        if (self.showCellSeparator) {
            self.separator.alpha = 0;
        }
        [UIView animateWithDuration:.3 animations:^(void){
            self.separator.alpha = 1;
            self.partialSeparator.alpha = 0;
        }];
    }
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    [super setBackgroundView:backgroundView];
    [backgroundView addSubview:_partialSeparator];
    [backgroundView addSubview:_separator];

    [self addSeparatorConstraints];
}






@end
