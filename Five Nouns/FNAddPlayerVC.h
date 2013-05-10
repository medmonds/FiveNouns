//
//  FNAddPlayerVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 5/7/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNViewController.h"

@class FNBrain;

@interface FNAddPlayerVC : FNViewController

@property (nonatomic, strong) FNBrain *brain;

@property (weak, nonatomic) IBOutlet UIImageView *addPlayerView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addPlayerButton;
@property (weak, nonatomic) IBOutlet UIView *divider;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nounsLabel;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *noun0;
@property (weak, nonatomic) IBOutlet UITextField *noun1;
@property (weak, nonatomic) IBOutlet UITextField *noun2;
@property (weak, nonatomic) IBOutlet UITextField *noun3;
@property (weak, nonatomic) IBOutlet UITextField *noun4;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end
