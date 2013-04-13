//
//  FNBrain.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/12/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FNScoreCard;
@class FNPlayer;

@interface FNBrain : NSObject

- (NSString *)noun;
- (FNPlayer *)player;

- (void)addScoreCard:(FNScoreCard *)scoreCard;
- (void)returnUnplayedNoun:(NSString *)noun;

@end
