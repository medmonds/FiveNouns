//
//  FNViewController.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 5/7/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNAppearance.h"


@interface FNViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (void)setBackgroundForCell:(UITableViewCell *)cell Style:(FNTableViewCellStyle)style atIndexPath:(NSIndexPath *)indexPath;
- (void)setBackgroundForTextField:(UITextField *)textField;

@end
