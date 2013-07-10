//
//  FNSelectableCell.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 5/6/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNSeparatorCell.h"

@interface FNSelectableCell : FNSeparatorCell

@property (weak, nonatomic) IBOutlet UILabel *mainTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) id objectForCell;

@end
