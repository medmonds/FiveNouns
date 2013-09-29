//
//  FNNetworkVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/15/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNTableViewController.h"
#import "FNNetworkManager.h"

@interface FNNetworkVC : FNTableViewController

@property (nonatomic, weak) id <FNNetworkViewControllerDataSource> dataSource;

- (void)insertClientAtIndex:(NSInteger)index;
- (void)deleteClientAtIndex:(NSInteger)index;

@end
