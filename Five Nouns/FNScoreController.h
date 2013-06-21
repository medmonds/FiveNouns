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

@interface FNScoreController : NSObject <UITableViewDataSource, UITableViewDelegate>

- (void)setup;

@property (nonatomic, strong) FNBrain *brain;
@property (nonatomic, weak) UITableView *tableView;

@end
