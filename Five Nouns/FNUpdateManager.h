//
//  FNUpdateManager.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 9/28/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNUpdate.h"

@class FNBrain;

@interface FNUpdateManager : NSObject

@property (nonatomic, weak) FNBrain *brain;

+ (FNUpdateManager *)sharedUpdateManager;

- (void)sendUpdate:(FNUpdate *)update withGameState:(NSDictionary *)state;
- (void)receiveUpdate:(NSData *)update;
- (BOOL)isUpdateValid:(NSData *)data;


- (void)didConnectToClient:(NSString *)peerID;
- (void)didDisconnectFromClient:(NSString *)peerID;



@end
