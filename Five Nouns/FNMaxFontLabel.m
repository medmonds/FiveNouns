//
//  FNMaxFontLabel.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNMaxFontLabel.h"

@implementation FNMaxFontLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIFont *)maxFontForFont:(UIFont *)font
{
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    NSInteger fontSize = 0;
    CGSize textSize;
    while (textSize.width < maxSize.width && textSize.height < maxSize.height) {
        fontSize ++;
        font = [UIFont fontWithName:[font fontName] size:fontSize];
        textSize = [self.text sizeWithFont:font];
    }
    fontSize --;
    return font;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.font = [self maxFontForFont:self.font];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:[self maxFontForFont:font]];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    self.font = [self maxFontForFont:self.font];
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
