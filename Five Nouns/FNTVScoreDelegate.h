//
//  FNTVScoreDelegate.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/26/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FNTVController.h"

@interface FNTVScoreDelegate : NSObject <FNTVControllerDelegate>

@property (nonatomic, strong) FNBrain *brain;

// the FNTVController will ask for this value and other things can set it like the FNScoreVC.
@property (nonatomic) BOOL shouldCollapseOnTitleTap;

- (void)orderTeamsByScore;

@end
