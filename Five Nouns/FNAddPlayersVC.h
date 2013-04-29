//
//  FNAddPlayersVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNTableViewController.h"
#import "FNInfoFromModal.h"

@class FNBrain;

@interface FNAddPlayersVC : FNTableViewController <FNInfoFromModal>

@property (nonatomic, strong) FNBrain *brain;

- (void)infoFromPresentedModal:(NSArray *)info;

- (void)cellButtonPressed;

@end
