//
//  FNMultiplayerManager.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/14/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GKMatch;

@interface FNMultiplayerManager : NSObject

@property (nonatomic, weak) UIViewController *hostViewController;

+ (FNMultiplayerManager *)sharedMultiplayerManager;

+ (SEL)selectorForMultiplayerView;

- (void)authenticateLocalPlayer;

- (BOOL)isMultiplayerEnabled;

// called by the multiplayerVC
- (void)multiplayerVCDidDisappear;

@end
