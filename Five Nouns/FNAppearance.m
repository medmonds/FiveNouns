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
    UIImage *background = [UIImage imageNamed:@"navBarBackground.png"];
    background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UINavigationBar appearance] setBackgroundImage:background forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:background forBarMetrics:UIBarMetricsLandscapePhone];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
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
    UIImage *image;
    
    if (style == FNTableViewCellStyleTextField) {
        
    } else if (style == FNTableViewCellStyleTextFieldLabel) {
        
    } else if (style == FNTableViewCellStyleTextFieldButton) {
        
    } else if (style == FNTableViewCellStyleButton) {
        if (position == FNTableViewCellPositionNone) {
            
        } else if (position == FNTableViewCellPositionTop) {
            
        }
    } else if (style == FNTableViewCellStyleButtonSmall) {
        if (position == FNTableViewCellPositionBottom) {
            
        }
    } else if (style == FNTableViewCellStylePlain) {
        if (position == FNTableViewCellPositionNone) {
            
        } else if (position == FNTableViewCellPositionTop) {
            
        } else if (position == FNTableViewCellPositionMiddle) {
            
        } else if (position == FNTableViewCellPositionBottom) {
            
        }
    } 
    return image;
}

@end











