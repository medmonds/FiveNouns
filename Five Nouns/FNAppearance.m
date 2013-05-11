//
//  FNAppearance.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/24/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNAppearance.h"

@interface FNAppearance ()


@end

@implementation FNAppearance

+ (UIColor *)tableViewBackgroundColor
{
    return [UIColor colorWithRed:104/255.0 green:204/255.0 blue:197/255.0 alpha:1];
}

+ (void)configureAppearanceProxies
{
    // UINavigationBar
    UIImage *background = [UIImage imageNamed:@"navBarBackground.png"];
    background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UINavigationBar *navProxy = [UINavigationBar appearance];
    [navProxy setBackgroundImage:background forBarMetrics:UIBarMetricsDefault];
    [navProxy setBackgroundImage:background forBarMetrics:UIBarMetricsLandscapePhone];
    [navProxy setShadowImage:[[UIImage alloc] init]];
    
    // UIStepper
    UIImage *stepperBackground = [[UIImage imageNamed:@"buttonRect.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    UIImage *divider = [[UIImage imageNamed:@"stepperDivider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIStepper *stepperProxy = [UIStepper appearance];
    [stepperProxy setBackgroundImage:stepperBackground forState:UIControlStateNormal];
    [stepperProxy setIncrementImage:[UIImage imageNamed:@"incrementImage.png"] forState:UIControlStateNormal];
    [stepperProxy setDecrementImage:[UIImage imageNamed:@"decrementImage.png"] forState:UIControlStateNormal];
    [stepperProxy setDividerImage:divider forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal];
    
}

+ (UILabel *)navBarTitleWithText:(NSString *)text
{
    UIFont *gameFont = [UIFont fontWithName:@"AvenirNext-Medium" size:36];
    CGSize titleSize = [text sizeWithFont:gameFont];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleSize.width, titleSize.height)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = gameFont;
    titleLabel.text = text;
    return titleLabel;
}

+ (UIBarButtonItem *)backBarButtonItem
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftArrow.png"] landscapeImagePhone:[UIImage imageNamed:@"leftArrow.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateSelected barMetrics:UIBarMetricsLandscapePhone];
    return button;
}

+ (UIBarButtonItem *)forwardBarButtonItem
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rightArrow.png"] landscapeImagePhone:[UIImage imageNamed:@"rightArrow.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateSelected barMetrics:UIBarMetricsLandscapePhone];
    return button;
}

+ (UIImage *)backgroundForCellWithStyle:(FNTableViewCellStyle)style forPosition:(FNTableViewCellPosition)position
{
    UIImage *background;
    if (style == FNTableViewCellStyleTextField || style == FNTableViewCellStyleTextFieldLabel || style == FNTableViewCellStyleTextFieldButton || style == FNTableViewCellStyleButtonSmall) {
        if (position == FNTableViewCellPositionMiddle) {
            background = [UIImage imageNamed:@"cellBackDarkMiddle.png"];
            background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(3, 13, 3, 13)];
        } else if (position == FNTableViewCellPositionBottom) {
            background = [UIImage imageNamed:@"cellBackDarkBottom.png"];
            background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(3, 13, 3, 13)];
        }
    } else if (style == FNTableViewCellStyleButton) {
        if (position == FNTableViewCellPositionNone) {
            background = [UIImage imageNamed:@"cellBackButton.png"];
            background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(3, 13, 3, 13)];
        } else if (position == FNTableViewCellPositionTop) {
            background = [UIImage imageNamed:@"cellBackButtonTop.png"];
            background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(3, 13, 3, 13)];
        }
    } else if (style == FNTableViewCellStylePlain) {
        if (position == FNTableViewCellPositionNone) {
            background = [UIImage imageNamed:@"cellBackPlain"];
            background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(3, 13, 3, 13)];
        } else if (position == FNTableViewCellPositionTop) {
            background = [UIImage imageNamed:@"cellBackPlain"];
            background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(3, 13, 3, 13)];
        } else if (position == FNTableViewCellPositionMiddle) {
            background = [UIImage imageNamed:@"cellBackPlain"];
            background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(3, 13, 3, 13)];
        } else if (position == FNTableViewCellPositionBottom) {
            background = [UIImage imageNamed:@"cellBackPlain"];
            background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(3, 13, 3, 13)];
        }
    } 
    return background;
}

+ (UIImage *)backgroundForTextField
{
    UIImage *background = [UIImage imageNamed:@"textFieldBack.png"];
    background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    return background;
}

+ (UIImage *)backgroundForButton
{
    UIImage *background = [UIImage imageNamed:@"buttonRect.png"];
    background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    return background;
}

+ (UIImage *)checkmarkWithStyle:(FNCheckmarkStyle)style
{
    UIImage *checkmark;
    if (style == FNCheckmarkStyleGame) {
        checkmark = [UIImage imageNamed:@"checkmarkGameSelected.png"];
    } else {
        checkmark = [UIImage imageNamed:@"checkmarkUserSelected.png"];
    }
    return checkmark;
}

@end











