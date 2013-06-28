//
//  FNGameDirections.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/25/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FNGameDirections : NSObject

typedef NS_ENUM(NSInteger, FNGameDirectionsType) {
    FNGameDirectionsTypeOverview,
    FNGameDirectionsTypeRoundOne,
    FNGameDirectionsTypeRoundTwo,
    FNGameDirectionsTypeRoundThree,
    FNGameDirectionsTypeRoundFour,
};

@property (nonatomic) FNGameDirectionsType *type;

+ (NSArray *)allDirectionsForGame;
+ (FNGameDirections *)directionsOfType:(FNGameDirectionsType)type;
+ (FNGameDirectionsType)directionsTypeForRound:(NSInteger)round;

- (NSString *)directions;
- (NSString *)title;

@end
