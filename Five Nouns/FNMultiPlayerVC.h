//
//  FNMultiPlayerVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/15/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNTableViewController.h"

@class FNMultiplayerHostDelegate;

@interface FNMultiPlayerVC : FNTableViewController

@property (nonatomic, strong) FNMultiplayerHostDelegate *dataSource;

- (void)insertClientAtIndex:(NSInteger)index;
- (void)deleteClientAtIndex:(NSInteger)index;

@end
