//
//  FNButtonCell.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/28/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNButtonCell.h"

@implementation FNButtonCell

- (IBAction)buttonPressed
{
    [self.delegate performSelector:@selector(cellButtonPressed)];
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
