//
//  FNReorderableCell.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 5/6/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNReorderableCell.h"

@implementation FNReorderableCell

- (BOOL)isTouchInReorderControl:(UIGestureRecognizer *)touch
{
    CGPoint point = [touch locationInView:self];
    return CGRectContainsPoint(self.button.frame, point);
}

- (void)prepareForMove
{
    self.mainTextLabel.text = nil;
    [self.button setHidden:YES];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
