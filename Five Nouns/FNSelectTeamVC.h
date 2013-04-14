//
//  FNSelectTeamVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNBrain.h"
#import "FNInfoFromModal.h"

@interface FNSelectTeamVC : UITableViewController <FNInfoFromModal>

@property (nonatomic, strong) FNPlayer *playerForTeam;
@property (nonatomic, strong) FNBrain *brain;
- (void)infoFromPresentedModal:(NSArray *)info;

@end
