//
//  FNUpdate.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/24/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, FNUpdateType) {
    FNUpdateTypeEverything,
    FNUpdateTypePlayerAdd,
    FNUpdateTypePlayerRemove,
    FNUpdateTypeTeamToPlayer,
    FNUpdateTypeTeamAdd,
    FNUpdateTypeTeamRemove,
    FNUpdateTypePlayerToTeam,
    FNUpdateTypeTeamOrder,
    FNUpdateTypeTeamName
};


@interface FNUpdate : NSObject <NSCoding>

+ (FNUpdate *)updateForObject:(id)updatedObject
                         updateType:(FNUpdateType)updateType
                     valueNew:(id)valueNew
                     valueOld:(id)valueOld;

@property FNUpdateType updateType;
@property (nonatomic, strong) id updatedObject;
@property (nonatomic, strong) id valueNew;
@property (nonatomic, strong) id valueOld;
+ (NSData *)dataForUpdate:(FNUpdate *)update;
+ (FNUpdate *)updateForData:(NSData *)data;

@end


/*

FNUpdateTypeEverything:
 
 gameStarted
 allTeams
 teamOrder
 allPlayers
 allScoreCards
 
 and something to capture currentTurn state





*/