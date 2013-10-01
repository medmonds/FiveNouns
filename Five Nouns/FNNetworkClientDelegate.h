//
//  FNNetworkClientDelegate.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/17/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "FNNetworkManager.h"

@interface FNNetworkClientDelegate : NSObject <GKSessionDelegate, FNNetworkManagerDelegate>

// the designated initializer
- (instancetype)initWithManager:(FNNetworkManager *)manager;

- (void)connectToServerAtIndex:(NSInteger)index;

@end
