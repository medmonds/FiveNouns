//
//  FNHeaderCell.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/22/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNHeaderCell.h"

@implementation FNHeaderCell

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

    // Add the partial width seperator line to the bottom of the cell
}


@end
