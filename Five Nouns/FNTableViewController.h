//
//  FNTableViewController.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/24/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNAppearance.h"

@interface FNTableViewController : UITableViewController <UITextFieldDelegate>

- (void)setBackgroundForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)setBackgroundForTextField:(UITextField *)textField;

@end
