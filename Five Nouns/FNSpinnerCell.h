//
//  FNSpinnerCell.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/18/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FNSpinnerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *mainTextLabel;

- (void)startSpinner;
- (void)stopSpinner;

@end
