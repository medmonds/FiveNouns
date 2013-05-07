//
//  FNSelectableCell.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 5/6/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FNSelectableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mainTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end
