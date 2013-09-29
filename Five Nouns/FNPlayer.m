//
//  FNPlayer.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNPlayer.h"
#import "FNTeam.h"

@implementation FNPlayer

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
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
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.nouns forKey:@"nouns"];
    [aCoder encodeObject:self.team forKey:@"team"];
}

- (BOOL)isValidPlayer
{
    NSMutableArray *goodNouns = [[NSMutableArray alloc] init];
    for (NSString *noun in self.nouns) {
        if ([noun length] > 0) {
            [goodNouns addObject:noun];
        }
    }
    if ([goodNouns count] > 2 && [self.name length] > 0) {
        self.nouns = goodNouns;
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isEqualToPlayer:(FNPlayer *)player
{
    if ([super isEqual:player] && [self.name isEqualToString:player.name] && [self.team isEqual:player.team]) {
        if ([self.nouns isEqualToArray:player.nouns]) {
            return YES;
        }
    }
    return NO;
}


@end









