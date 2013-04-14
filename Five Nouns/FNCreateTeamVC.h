//
//  FNCreateTeamVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNInfoFromModal.h"

@interface FNCreateTeamVC : UITableViewController
@property (nonatomic, weak) id <FNInfoFromModal> delegate;

@end
