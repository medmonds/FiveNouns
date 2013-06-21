//
//  FNPausedVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/19/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNTableViewController.h"

@class FNBrain;

@interface FNPausedVC : FNTableViewController

@property (nonatomic, strong) FNBrain *brain;
//@property (nonatomic, weak) UIViewController *presentingVC;

@end
