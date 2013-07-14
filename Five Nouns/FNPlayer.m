//
//  FNPlayer.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNPlayer.h"

@implementation FNPlayer

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.nouns = [aDecoder decodeObjectForKey:@"nouns"];
    self.team = [aDecoder decodeObjectForKey:@"team"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.nouns forKey:@"nouns"];
    [aCoder encodeObject:self.team forKey:@"team"];
}

@end
