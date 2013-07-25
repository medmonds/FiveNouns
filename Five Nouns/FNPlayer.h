//
//  FNPlayer.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNUniqueIDObject.h"

@class FNTeam;

@interface FNPlayer : FNUniqueIDObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *nouns;
@property (nonatomic, weak) FNTeam *team;

@end


