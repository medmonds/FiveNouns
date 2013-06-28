//
//  FNTVDirectionsDelegate.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/27/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FNTVController.h"

@interface FNTVDirectionsDelegate : NSObject <FNTVControllerDelegate>

// the FNTVController will ask for this value and other things can set it like the FNScoreVC.
@property (nonatomic) BOOL shouldCollapseOnTitleTap;
@property (nonatomic, weak) FNTVController *controller;

@end
