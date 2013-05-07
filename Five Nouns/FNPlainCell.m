//
//  FNPlainCell.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/28/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNPlainCell.h"
#import "FNAppearance.h"

@interface FNPlainCell ()
@property BOOL showingDeleteButton;
@end

@implementation FNPlainCell


- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
                UIImageView *deleteBtn = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 64, 33)];
                [deleteBtn setImage:[FNAppearance backgroundForButton]];
                [[subview.subviews objectAtIndex:0] addSubview:deleteBtn];
            }
        }
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];

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
