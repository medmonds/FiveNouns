//
//  FNMultiplayerJoinVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/17/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNTableViewController.h"

@class FNMultiplayerClientDelegate;

@interface FNMultiplayerJoinVC : FNTableViewController

@property (nonatomic, weak) FNMultiplayerClientDelegate *dataSource;

- (void)insertAvailableServerAtIndex:(NSInteger)index;
- (void)deleteAvailableServerAtIndex:(NSInteger)index;

@end
