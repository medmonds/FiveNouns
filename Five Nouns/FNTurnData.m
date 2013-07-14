//
//  FNTurnData.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNTurnData.h"

@implementation FNTurnData

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.noun = [aDecoder decodeObjectForKey:@"noun"];
    self.timeRemaining = [aDecoder decodeIntegerForKey:@"timeRemaining"];
    self.scoreCard = [aDecoder decodeObjectForKey:@"scoreCard"];
    self.round = [aDecoder decodeIntegerForKey:@"round"];
    self.turn = [aDecoder decodeIntegerForKey:@"turn"];
    self.player = [aDecoder decodeObjectForKey:@"player"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.noun forKey:@"noun"];
    [aCoder encodeInteger:self.timeRemaining forKey:@"timeRemaining"];
    [aCoder encodeObject:self.scoreCard forKey:@"scoreCard"];
    [aCoder encodeInteger:self.round forKey:@"round"];
    [aCoder encodeInteger:self.turn forKey:@"turn"];
    [aCoder encodeObject:self.player forKey:@"player"];
}
     
     
@end
