//
//  FNTurnData.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FNScoreCard;
@class FNPlayer;

@interface FNTurnData : NSObject <NSCoding>

@property (nonatomic, strong) NSString *noun;
@property (nonatomic) NSInteger timeRemaining;
@property (nonatomic, strong) FNScoreCard *scoreCard;
@property (nonatomic) NSInteger round;
@property (nonatomic) NSInteger turn;
@property (nonatomic, strong) FNPlayer *player;

@end
