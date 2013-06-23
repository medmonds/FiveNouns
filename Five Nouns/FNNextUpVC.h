//
//  FNNextUpVC.h
//  Five Nouns
//
//  Created by Jill on 5/22/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNRoundDirectionsVC.h"

@class FNBrain;
@class FNPlayer;

@interface FNNextUpVC : UIViewController <UITableViewDataSource, UITableViewDelegate, FNDirectionsVCPresenter>
@property (nonatomic, strong) FNBrain *brain;
@property (nonatomic) NSInteger round;
//@property (nonatomic, weak) IBOutlet UITableViewController *scoreBoard;
@end
