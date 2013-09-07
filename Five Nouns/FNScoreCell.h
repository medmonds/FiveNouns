//
//  FNScoreCell.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 9/4/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNSeparatorCell.h"

@interface FNScoreCell : FNSeparatorCell
@property (weak, nonatomic) IBOutlet UILabel *myTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *myDetailTextLabel;
@end
