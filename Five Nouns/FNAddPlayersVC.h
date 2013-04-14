//
//  FNAddPlayersVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNInfoFromModal.h"

@class FNBrain;

@interface FNAddPlayersVC : UITableViewController <FNInfoFromModal>

@property (nonatomic, strong) FNBrain *brain;

- (void)infoFromPresentedModal:(NSArray *)info;

@end
