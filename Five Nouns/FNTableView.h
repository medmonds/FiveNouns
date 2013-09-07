//
//  FNTableView.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 9/2/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FNTableView : UITableView <UIGestureRecognizerDelegate>

- (void)deleteControlPressed;
@end


@protocol FNTableViewDataSource <NSObject>

- (BOOL)tableView:(FNTableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(FNTableView *)tableView deleteRowAtIndexPath:(NSIndexPath *)indexPath;
@end
