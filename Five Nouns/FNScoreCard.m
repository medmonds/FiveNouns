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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    
    self.player = [aDecoder decodeObjectForKey:@"player"];
    self.nounsScored = [aDecoder decodeObjectForKey:@"nounsScored"];
    self.round = [aDecoder decodeIntegerForKey:@"round"];
    self.turn = [aDecoder decodeIntegerForKey:@"turn"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.player forKey:@"player"];
    [aCoder encodeObject:self.nounsScored forKey:@"nounsScored"];
    [aCoder encodeInteger:self.round forKey:@"round"];
    [aCoder encodeInteger:self.turn forKey:@"turn"];
}

@end
