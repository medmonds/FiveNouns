//
//  FNGameDirections.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/25/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNGameDirections.h"

@implementation FNGameDirections

+ (NSArray *)allDirectionsForGame
{
    NSMutableArray *all = [[NSMutableArray alloc] initWithCapacity:5];
    for (NSInteger i = 0; i < 5; i ++) {
        [all addObject:[FNGameDirections directionsOfType:[FNGameDirections directionsTypeForRound:i]]];
    }
    return [NSArray arrayWithArray:all];
}

+ (FNGameDirections *)directionsOfType:(FNGameDirectionsType)type
{
    FNGameDirections *directions = [[FNGameDirections alloc] init];
    if (type == FNGameDirectionsTypeOverview) {
        directions.type = FNGameDirectionsTypeOverview;
    } else if (type == FNGameDirectionsTypeRoundOne) {
        directions.type = FNGameDirectionsTypeRoundOne;
    } else if (type == FNGameDirectionsTypeRoundTwo) {
        directions.type = FNGameDirectionsTypeRoundTwo;
    } else if (type == FNGameDirectionsTypeRoundThree) {
        directions.type = FNGameDirectionsTypeRoundThree;
    } else if (type == FNGameDirectionsTypeRoundFour) {
        directions.type = FNGameDirectionsTypeRoundFour;
    }
    return directions;
}

+ (FNGameDirectionsType)directionsTypeForRound:(NSInteger)round
{
    if (round == 0) {
        return FNGameDirectionsTypeOverview;
    } else if (round == 1) {
        return FNGameDirectionsTypeRoundOne;
    } else if (round == 2) {
        return FNGameDirectionsTypeRoundTwo;
    } else if (round == 3) {
        return FNGameDirectionsTypeRoundThree;
    } else if (round == 4) {
        return FNGameDirectionsTypeRoundFour;
    } else {
        return nil;
    }
}

- (NSString *)title
{
    return [self titleForType:self.type];
}

- (NSString *)directions
{
    return [self directionsForType:self.type];
}

- (NSString *)titleForType:(FNGameDirectionsType)type
{
    if (type == FNGameDirectionsTypeOverview) {
        return @"Overview";
    } else if (type == FNGameDirectionsTypeRoundOne) {
        return @"Round One";
    } else if (type == FNGameDirectionsTypeRoundTwo) {
        return @"Round Two";
    } else if (type == FNGameDirectionsTypeRoundThree) {
        return @"Round Three";
    } else if (type == FNGameDirectionsTypeRoundFour) {
        return @"Round Four";
    } else {
        return nil;
    }
}

- (NSString *)directionsForType:(FNGameDirectionsType)type
{
    if (type == FNGameDirectionsTypeOverview) {
        return @"An instance of the UIButton class implements a button on the touch screen. A button intercepts touch events and sends an action message to a target object when tapped. Methods for setting the target";
    } else if (type == FNGameDirectionsTypeRoundOne) {
        return @"An instance of the UIButton class implements a button on the touch screen. A button intercepts touch events and sends an action message to a target object when tapped. Methods for setting the target";
    } else if (type == FNGameDirectionsTypeRoundTwo) {
        return @"An instance of the UIButton class implements a button on the touch screen. A button intercepts touch events and sends an action message to a target object when tapped. Methods for setting the target";
    } else if (type == FNGameDirectionsTypeRoundThree) {
        return @"An instance of the UIButton class implements a button on the touch screen. A button intercepts touch events and sends an action message to a target object when tapped. Methods for setting the target";
    } else if (type == FNGameDirectionsTypeRoundFour) {
        return @"An instance of the UIButton class implements a button on the touch screen. A button intercepts touch events and sends an action message to a target object when tapped. Methods for setting the target";
    } else {
        return nil;
    }
}

@end
