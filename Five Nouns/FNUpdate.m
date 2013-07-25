//
//  FNUpdate.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/24/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNUpdate.h"

@implementation FNUpdate

+ (NSData *)dataForUpdate:(FNUpdate *)update
{
    return [NSKeyedArchiver archivedDataWithRootObject:update];
}

+ (FNUpdate *)updateForData:(NSData *)data
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.updateType = [aDecoder decodeIntegerForKey:@"updateType"];
    self.updatedObjectID = [aDecoder decodeObjectForKey:@"updatedObjectID"];
    self.valueNew = [aDecoder decodeObjectForKey:@"valueNew"];
    self.valueOld = [aDecoder decodeObjectForKey:@"valueOld"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.updateType forKey:@"updateType"];
    [aCoder encodeObject:self.updatedObjectID forKey:@"updatedObjectID"];
    [aCoder encodeObject:self.valueNew forKey:@"valueNew"];
    [aCoder encodeObject:self.valueOld forKey:@"valueOld"];
}

@end

