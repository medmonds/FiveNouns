//
//  FNScoreCard.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FNPlayer;

@interface FNScoreCard : NSObject <NSCoding>

@property (nonatomic, strong) FNPlayer *player;
@property (nonatomic, strong) NSMutableArray *nounsScored;
@property NSInteger round;
@property NSInteger turn;

@end
