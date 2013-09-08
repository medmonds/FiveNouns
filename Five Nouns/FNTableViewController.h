//
//  FNTableViewController.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/24/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNAppearance.h"
#import "FNTableView.h"


@interface FNTableViewController : UITableViewController <UITextFieldDelegate, FNTableViewDataSource>

- (void)setBackgroundForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)setBackgroundForCell:(UITableViewCell *)cell withPosition:(FNTableViewCellPosition)position;

- (void)setBackgroundForTextField:(UITextField *)textField;

@end
