//
//  FNUpdate.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/24/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNUpdate.h"

@implementation FNUpdate

+ (FNUpdate *)updateForObject:(id)updatedObject updateType:(FNUpdateType)updateType valueNew:(id)valueNew valueOld:(id)valueOld
{
    FNUpdate *update = [[FNUpdate alloc] init];
    update.updatedObject = updatedObject;
    update.updateType = updateType;
    update.valueNew = valueNew;
    update.valueOld = valueOld;
    return update;
}

+ (NSData *)dataForUpdate:(FNUpdate *)update
{
    return [NSKeyedArchiver archivedDataWithRootObject:update];
}

+ (FNUpdate *)updateForData:(NSData *)data
{
    FNUpdate *update = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([update isKindOfClass:[FNUpdate class]]) {
        return update;
    }
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    self.updateType = [aDecoder decodeIntegerForKey:@"updateType"];
    self.updatedObject = [aDecoder decodeObjectForKey:@"updatedObject"];
    self.valueNew = [aDecoder decodeObjectForKey:@"valueNew"];
    self.valueOld = [aDecoder decodeObjectForKey:@"valueOld"];
    self.updateIdentifier = [aDecoder decodeObjectForKey:@"updateIdentifier"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:self.updateType forKey:@"updateType"];
    [aCoder encodeObject:self.updatedObject forKey:@"updatedObject"];
    [aCoder encodeObject:self.valueNew forKey:@"valueNew"];
    [aCoder encodeObject:self.valueOld forKey:@"valueOld"];
    [aCoder encodeObject:self.updateIdentifier forKey:@"updateIdentifier"];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    FNUpdate *copy = [FNUpdate updateForObject:self.updatedObject updateType:self.updateType valueNew:self.valueNew valueOld:self.valueOld];
    copy.updateIdentifier = self.updateIdentifier;
    return copy;
}

@end

