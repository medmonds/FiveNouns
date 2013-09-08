//
//  FNTVTeamsDelegate.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 9/7/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNTVController.h"

@interface FNTVTeamsDelegate : NSObject <FNTVControllerDelegate>

@property (nonatomic, strong) FNBrain *brain;
// the FNTVController will ask for this value and other things can set it like the FNScoreVC.
@property (nonatomic) BOOL shouldCollapseOnTitleTap;
@property (nonatomic, weak) FNTVController *controller;


@end
