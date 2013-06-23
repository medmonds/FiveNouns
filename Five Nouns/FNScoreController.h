//
//  FNScoreController.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/20/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FNBrain;

@protocol FNTVRowInsertAndDeleteManager <NSObject>

- (void)insertRowsAtIndexPaths:(NSArray *)indexpaths forController:(id <UITableViewDelegate>)controller;
- (void)deleteRowsAtIndexPaths:(NSArray *)indexpaths forController:(id <UITableViewDelegate>)controller;
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath forController:(id <UITableViewDelegate>)controller;

@end

@interface FNScoreController : NSObject <UITableViewDataSource, UITableViewDelegate>

- (void)setup; // will expand the table view and show the scores

@property (nonatomic, strong) FNBrain *brain;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UITableViewController <FNTVRowInsertAndDeleteManager> *tvController;

@end
