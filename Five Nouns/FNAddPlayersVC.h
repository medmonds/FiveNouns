//
//  FNAddPlayersVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNTableViewController.h"

@class FNBrain;

@interface FNAddPlayersVC : FNTableViewController

@property (nonatomic, strong) FNBrain *brain;

- (void)addPlayer;

//- (void)cellButtonPressed;

@end
