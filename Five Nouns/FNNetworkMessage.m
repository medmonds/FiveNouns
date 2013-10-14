//
//  FNNetworkMessage.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 10/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNNetworkMessage.h"

@implementation FNNetworkMessage

+ (FNNetworkMessage *)messageWithType:(FNNetworkMessageType)type valueNew:(id)valueNew valueOld:(id)valueOld
{
    FNNetworkMessage *message = [[FNNetworkMessage alloc] init];
    message.type = type;
    message.valueNew = valueNew;
    message.valueOld = valueOld;
    return message;
}

- (NSData *)messageAsData
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

+ (FNNetworkMessage *)messageForData:(NSData *)data
{
    FNNetworkMessage *message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([message isKindOfClass:[FNNetworkMessage class]]) {
        return message;
    }
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    self.type = [aDecoder decodeIntegerForKey:@"type"];
    self.valueNew = [aDecoder decodeObjectForKey:@"valueNew"];
    self.valueOld = [aDecoder decodeObjectForKey:@"valueOld"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeObject:self.valueNew forKey:@"valueNew"];
    [aCoder encodeObject:self.valueOld forKey:@"valueOld"];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    FNNetworkMessage *copy = [FNNetworkMessage messageWithType:self.type valueNew:self.valueNew valueOld:self.valueOld];
    return copy;
}

@end
