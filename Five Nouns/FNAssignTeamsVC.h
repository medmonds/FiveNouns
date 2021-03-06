//
//  FNAssignTeamsVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNTableViewController.h"
#import "FMMoveTableView.h"

@class FNBrain;

@interface FNAssignTeamsVC : FNTableViewController <FMMoveTableViewDataSource, FMMoveTableViewDelegate>
@property (nonatomic, strong) FNBrain *brain;

- (void)stepperDidStep:(UIStepper *)stepper;

@end
