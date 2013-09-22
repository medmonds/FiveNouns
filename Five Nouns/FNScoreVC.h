//
//  FNScoreVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/1/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNTableViewController.h"

@class FNBrain;

@interface FNScoreVC : FNTableViewController

@property (nonatomic, strong) FNBrain *brain;

- (void)orderTeamsByScore;

@end
