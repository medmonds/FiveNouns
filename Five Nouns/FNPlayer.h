//
//  FNPlayer.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNTeam.h"
@interface FNPlayer : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *nouns;
@property (nonatomic, weak) FNTeam *team;

@end
