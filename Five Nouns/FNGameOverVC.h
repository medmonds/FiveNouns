//
//  FNGameOverVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 9/18/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FNBrain;

@interface FNGameOverVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) FNBrain *brain;

@end
