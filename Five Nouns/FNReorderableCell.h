//
//  FNReorderableCell.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 5/6/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FNReorderableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mainTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;

- (BOOL)isTouchInReorderControl:(UIGestureRecognizer *)touch;
- (void)prepareForMove;

@end
