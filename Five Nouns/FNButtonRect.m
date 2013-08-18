//
//  FNButtonRect.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/24/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNButtonRect.h"
#import "FNAppearance.h"

@implementation FNButtonRect

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeButton];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeButton];
    }
    return self;
}

- (void)initializeButton
{
    UIImage *background = [FNAppearance backgroundForButton];
    [self setBackgroundImage:background forState:UIControlStateNormal];
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
