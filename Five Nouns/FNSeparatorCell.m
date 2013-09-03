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
@property (nonatomic, strong) UIButton *deleteButton;
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


#pragma mark - FNDeleteCell

- (void)showDeleteControlForTableView:(FNTableView *)tableView withSelector:(SEL)selector
{
    // can't get it to let me change the size of the content view !!! so have to add it to the content view not background view
    CGFloat height = 33;
    CGFloat width = 64;
    CGRect buttonFrame = CGRectMake(CGRectGetWidth(self.bounds) - (width + 15), (CGRectGetMidY(self.bounds) - 1) - (height / 2), width, height);
    self.deleteButton = [[UIButton alloc] initWithFrame:buttonFrame];
    UIImage *background = [FNAppearance backgroundForButton];
    [self.deleteButton setBackgroundImage:background forState:UIControlStateNormal];
    [self.deleteButton addTarget:tableView action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton addTarget:self action:@selector(deletePressed) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [UIView animateWithDuration:.3 animations:^{
        [self.contentView addSubview:self.deleteButton];
        self.deleteButton.alpha = 1;
    }];
}

- (void)hideDeleteControlForTableView
{
    [UIView animateWithDuration:.3 animations:^{
        self.deleteButton.alpha = 0;
    } completion:^(BOOL finished) {
        [self.deleteButton removeFromSuperview];
        self.deleteButton = nil;
    }];
}

- (void)setDeletedState
{
    // should change the background !!!
}

- (void)deletePressed
{
    [self.deleteButton removeFromSuperview];
    self.deleteButton = nil;
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









