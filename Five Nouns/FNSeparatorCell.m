//
//  FNSeparatorCell.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/23/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNSeparatorCell.h"
#import "FNAppearance.h"
#import "FNTableView.h"

@interface FNSeparatorCell ()
@property (nonatomic, strong) UIView *partialSeparator;
@property (nonatomic, strong) UIView *separator;
@end


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
    
    CGFloat height = 33;
    CGFloat width = 64;
    CGRect buttonFrame = CGRectMake(0, 0, width, height);
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:buttonFrame];
    UIImage *background = [FNAppearance backgroundForButton];
    [deleteButton setBackgroundImage:background forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteControlPressed) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 74, 35)];
    [buttonContainer addSubview:deleteButton];
    self.editingAccessoryView = buttonContainer;
}

- (void)addSeparatorConstraints
{
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_partialSeparator
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_partialSeparator.superview
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1
                                                                constant:[FNAppearance cellSeparatorPartialIndent]];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_partialSeparator
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
                                                               constant:[FNAppearance cellSeparatorPartialHeight]];
    [_partialSeparator.superview addConstraints:@[left, right, bottom, height]];
    
    NSLayoutConstraint *left1 = [NSLayoutConstraint constraintWithItem:_separator
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_separator.superview
                                                                attribute:NSLayoutAttributeLeft
                                                               multiplier:1
                                                                 constant:0];
    NSLayoutConstraint *right1 = [NSLayoutConstraint constraintWithItem:_separator
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
                                                                constant:[FNAppearance cellSeparatorHeight]];
    [_separator.superview addConstraints:@[left1, right1, bottom1, height1]];
}

- (void)setShowCellSeparator:(BOOL)showCellSeparator
{
    _showCellSeparator = showCellSeparator;
    if (showCellSeparator) {
        _separator.alpha = 1;
        _partialSeparator.alpha = 1;
    } else {
        _separator.alpha = 0;
        _partialSeparator.alpha = 0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (self.showCellSeparator) {
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
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    [_partialSeparator removeFromSuperview];
    [_separator removeFromSuperview];
    [super setBackgroundView:backgroundView];
    [backgroundView addSubview:_partialSeparator];
    [backgroundView addSubview:_separator];
    [self addSeparatorConstraints];
}

- (void)setDeletedState
{
    // should change the background !!!
}

- (void)deleteControlPressed
{
    if ([self.superview isKindOfClass:[FNTableView class]]) {
        [((FNTableView *)self.superview) deleteControlPressed];
        [self setDeletedState];
    }
}


//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
//{
//    if (highlighted) {
//        self.textLabel.textColor = [FNAppearance textColorButton];
//    } else{
//        self.textLabel.textColor = [FNAppearance textColorLabel];
//    }
//}




@end









