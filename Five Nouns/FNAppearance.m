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
    UIBarButtonItem *back = [UIBarButtonItem alloc] initWithImage:<#(UIImage *)#> landscapeImagePhone:<#(UIImage *)#> style:<#(UIBarButtonItemStyle)#> target:<#(id)#> action:];
}

+ (UIBarButtonItem *)forwardBarButtonItem
{
    
}

@end
