//
//  FNAppearance.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/24/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNAppearance.h"
#import "FNMaxFontLabel.h"
#import "FNMultiplayerManager.h"

@interface FNAppearance ()


@end

@implementation FNAppearance

+ (CGFloat)cellSeparatorPartialIndent
{
    return 30.0;
}

+ (CGFloat)cellSeparatorPartialHeight
{
    return 1.0;
}

+ (CGFloat)cellSeparatorHeight
{
    return 2.0;
}

+ (UIFont *)fontWithSize:(CGFloat)fontSize
{
    if (!fontSize) fontSize = 28;
    return [UIFont fontWithName:@"AvenirNext-Medium" size:fontSize];
}

+ (UIColor *)tableViewBackgroundColor
{
    return [UIColor colorWithRed:12/255.0 green:182/255.0 blue:152/255.0 alpha:1];
}

+ (UIColor *)cellSeparatorColor
{
    return [FNAppearance tableViewBackgroundColor];
}

+ (UIColor *)textColorLabel
{
    return [UIColor whiteColor];
}

+ (UIColor *)textColorButton
{
    return [UIColor colorWithRed:234/255.0f green:208/255.0f blue:76/255.0f alpha:1.];
}

+ (UIColor *)backgroundColorAccent
{
    return [UIColor colorWithRed:74/255.0f green:74/255.0f blue:74/255.0f alpha:1];
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
    
    // Toolbar
    UIToolbar *toolbarProxy = [UIToolbar appearance];
    [toolbarProxy setBackgroundImage:background forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [toolbarProxy setBackgroundImage:background forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsLandscapePhone];
    
    // UIStepper
    UIImage *stepperBackground = [[UIImage alloc] init];  //[[UIImage imageNamed:@"buttonRect.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    UIImage *divider = [[UIImage alloc] init]; //[[UIImage imageNamed:@"stepperDivider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIStepper *stepperProxy = [UIStepper appearance];
    [stepperProxy setBackgroundImage:stepperBackground forState:UIControlStateNormal];
    [stepperProxy setIncrementImage:[UIImage imageNamed:@"incrementImage.png"] forState:UIControlStateNormal];
    [stepperProxy setDecrementImage:[UIImage imageNamed:@"decrementImage.png"] forState:UIControlStateNormal];
    [stepperProxy setDividerImage:divider forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal];
}

+ (UIView *)navBarTitleWithText:(NSString *)text forOrientation:(UIInterfaceOrientation)orientation
{
    UIFont *gameFont;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        gameFont = [FNAppearance fontWithSize:36];
    } else {
        gameFont = [FNAppearance fontWithSize:30];
    }
    CGSize titleSize = [text sizeWithFont:gameFont];
    CGRect titleFrame = CGRectMake(0, 0, titleSize.width, titleSize.height);
    UIView *titleView = [[UIView alloc] initWithFrame:titleFrame];
    titleView.backgroundColor = [UIColor clearColor];
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton.frame = titleFrame;
    [titleView addSubview:titleButton];
    [titleButton setTitleColor:[FNAppearance textColorButton] forState:UIControlStateNormal];
    [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [titleButton addTarget:[FNMultiplayerManager sharedMultiplayerManager] action:[FNMultiplayerManager selectorForMultiplayerView] forControlEvents:UIControlEventTouchUpInside];
    titleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    titleButton.backgroundColor = [UIColor clearColor];
    titleButton.titleLabel.font = gameFont;
    [titleButton setTitle:text forState:UIControlStateNormal];
    return titleView;
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

+ (UIBarButtonItem *)optionsBarButtonItem
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reorderControl.png"] landscapeImagePhone:[UIImage imageNamed:@"reorderControl.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateSelected barMetrics:UIBarMetricsLandscapePhone];
    return button;
}

+ (UIBarButtonItem *)barButtonItemDismiss
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dismissControl.png"] landscapeImagePhone:[UIImage imageNamed:@"dismissControl.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [button setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateSelected barMetrics:UIBarMetricsLandscapePhone];
    return button;
}

+ (UIImage *)cellBackgroundForPosition:(FNTableViewCellPosition)position;
{
    UIImage *background;
    if (position == FNTableViewCellPositionNone) {
        background = [UIImage imageNamed:@"cellNone"];
        background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(3, 13, 3, 13)];
    } else if (position == FNTableViewCellPositionTop) {
        background = [UIImage imageNamed:@"cellTop"];
        background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(3, 13, 3, 13)];
    } else if (position == FNTableViewCellPositionMiddle) {
        background = [UIImage imageNamed:@"cellMiddle"];
        background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(3, 13, 3, 13)];
    } else if (position == FNTableViewCellPositionBottom) {
        background = [UIImage imageNamed:@"cellBottom"];
        background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(3, 13, 3, 13)];
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

+ (UIImage *)reorderControlImage
{
    UIImage *image = [UIImage imageNamed:@"reorderControl.png"];
    return image;
}

+ (UIButton *)randomNounButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(1, 1, 42, 42)];
    button.backgroundColor = [UIColor blackColor];
    return button;
}

@end











