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

- (void)reverseUpdate
{
    switch (self.updateType) {
        case FNUpdateTypeEverything:
            // can't be reversed
            break;
            
        case FNUpdateTypePlayerAdd: {
            self.updateType = FNUpdateTypePlayerRemove;
            id new = self.valueNew;
            id old = self.valueOld;
            self.valueOld = new;
            self.valueNew = old;
            break;
        }
        case FNUpdateTypePlayerRemove: {
            self.updateType = FNUpdateTypePlayerAdd;
            id new = self.valueNew;
            id old = self.valueOld;
            self.valueOld = new;
            self.valueNew = old;
            break;
        }
        case FNUpdateTypeTeamAdd: {
            self.updateType = FNUpdateTypeTeamRemove;
            id new = self.valueNew;
            id old = self.valueOld;
            self.valueOld = new;
            self.valueNew = old;
            break;
        }
        case FNUpdateTypeTeamRemove: {
            self.updateType = FNUpdateTypeTeamAdd;
            id new = self.valueNew;
            id old = self.valueOld;
            self.valueOld = new;
            self.valueNew = old;
            break;
        }
        case FNUpdateTypeTeamName: {
            id new = self.valueNew;
            id old = self.valueOld;
            self.valueOld = new;
            self.valueNew = old;
            break;
        }
        case FNUpdateTypeTeamOrder: {
            id new = self.valueNew;
            id old = self.valueOld;
            self.valueOld = new;
            self.valueNew = old;
            break;
        }
        case FNUpdateTypeTeamToPlayer: {
            id new = self.valueNew;
            id old = self.valueOld;
            self.valueOld = new;
            self.valueNew = old;
            break;
        }
        case FNUpdateTypePlayerToTeam:
            // Not used in the brain
            break;
            
        case FNUpdateTypeStatus: {
            id new = self.valueNew;
            id old = self.valueOld;
            self.valueOld = new;
            self.valueNew = old;
            break;
        }
        case FNUpdateTypePeerDisconnected:
            // it works the same either way
            break;
            
        default:
            break;
    }
}

@end

