//
//  FNUniqueIDObject.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/23/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNUniqueIDObject.h"

@implementation FNUniqueIDObject

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.uniqueID = [NSUUID UUID];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.uniqueID = [aDecoder decodeObjectForKey:@"uniqueID"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.uniqueID forKey:@"uniqueID"];
}

- (NSUInteger)hash
{
    return [self.uniqueID hash];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [self.uniqueID isEqual:((FNUniqueIDObject *)object).uniqueID];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    FNUniqueIDObject *copy = [[FNUniqueIDObject alloc] init];
    copy.uniqueID = self.uniqueID;
    return copy;
}

@end
