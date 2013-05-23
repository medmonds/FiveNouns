//
//  FNNextUpVC.h
//  Five Nouns
//
//  Created by Jill on 5/22/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNBrain.h"

@interface FNNextUpVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) FNBrain *brain;
@end
