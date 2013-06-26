//
//  FNDirectionsController.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/25/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FNScoreController.h"

@class FNBrain;

@interface FNDirectionsController : NSObject <UITableViewDataSource, UITableViewDelegate>

- (void)setup;

@property (nonatomic, strong) FNBrain *brain;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UITableViewController <FNTVRowInsertAndDeleteManager> *tvController;

@end

