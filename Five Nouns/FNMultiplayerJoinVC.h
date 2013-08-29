//
//  FNMultiplayerJoinVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/17/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNTableViewController.h"
#import "FNMultiplayerManager.h"

@interface FNMultiplayerJoinVC : FNTableViewController <FNMultiplayerViewController>

@property (nonatomic, weak) id <FNMultiplayerViewControllerDataSource> dataSource;

@end
