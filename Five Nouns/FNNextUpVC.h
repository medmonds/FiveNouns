//
//  FNNextUpVC.h
//  Five Nouns
//
//  Created by Jill on 5/22/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNDirectionView.h"

@class FNBrain;
@class FNPlayer;

@interface FNNextUpVC : UIViewController <UITableViewDataSource, UITableViewDelegate, FNDirectionViewPresenter>
@property (nonatomic, strong) FNBrain *brain;
@property (nonatomic) NSInteger round;
@end
