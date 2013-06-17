//
//  FNScoreCard.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNScoreCard.h"

@implementation FNScoreCard

- (NSMutableArray *)nounsScored
{
    if (!_nounsScored) {
        _nounsScored = [[NSMutableArray alloc] init];
    }
    return _nounsScored;
}

@end
