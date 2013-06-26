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
        [all addObject:[FNGameDirections directionsOfType:[FNGameDirections directionTypeForRound:i]]];
    }
    return [NSArray arrayWithArray:all];
}

+ (FNGameDirections *)directionsOfType:(FNGameDirectionType)type
{
    FNGameDirections *directions = [[FNGameDirections alloc] init];
    if (type == FNGameDirectionTypeOverview) {
        directions.type = FNGameDirectionTypeOverview;
    } else if (type == FNGameDirectionTypeRoundOne) {
        directions.type = FNGameDirectionTypeRoundOne;
    } else if (type == FNGameDirectionTypeRoundTwo) {
        directions.type = FNGameDirectionTypeRoundTwo;
    } else if (type == FNGameDirectionTypeRoundThree) {
        directions.type = FNGameDirectionTypeRoundThree;
    } else if (type == FNGameDirectionTypeRoundFour) {
        directions.type = FNGameDirectionTypeRoundFour;
    }
    return directions;
}

+ (FNGameDirectionType)directionTypeForRound:(NSInteger)round
{
    if (round == 0) {
        return FNGameDirectionTypeOverview;
    } else if (round == 1) {
        return FNGameDirectionTypeRoundOne;
    } else if (round == 2) {
        return FNGameDirectionTypeRoundTwo;
    } else if (round == 3) {
        return FNGameDirectionTypeRoundThree;
    } else if (round == 4) {
        return FNGameDirectionTypeRoundFour;
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

- (NSString *)titleForType:(FNGameDirectionType)type
{
    if (type == FNGameDirectionTypeOverview) {
        return @"Overview";
    } else if (type == FNGameDirectionTypeRoundOne) {
        return @"Round One";
    } else if (type == FNGameDirectionTypeRoundTwo) {
        return @"Round Two";
    } else if (type == FNGameDirectionTypeRoundThree) {
        return @"Round Three";
    } else if (type == FNGameDirectionTypeRoundFour) {
        return @"Round Four";
    } else {
        return nil;
    }
}

- (NSString *)directionsForType:(FNGameDirectionType)type
{
    if (type == FNGameDirectionTypeOverview) {
        return @"An instance of the UIButton class implements a button on the touch screen. A button intercepts touch events and sends an action message to a target object when tapped. Methods for setting the target";
    } else if (type == FNGameDirectionTypeRoundOne) {
        return @"An instance of the UIButton class implements a button on the touch screen. A button intercepts touch events and sends an action message to a target object when tapped. Methods for setting the target";
    } else if (type == FNGameDirectionTypeRoundTwo) {
        return @"An instance of the UIButton class implements a button on the touch screen. A button intercepts touch events and sends an action message to a target object when tapped. Methods for setting the target";
    } else if (type == FNGameDirectionTypeRoundThree) {
        return @"An instance of the UIButton class implements a button on the touch screen. A button intercepts touch events and sends an action message to a target object when tapped. Methods for setting the target";
    } else if (type == FNGameDirectionTypeRoundFour) {
        return @"An instance of the UIButton class implements a button on the touch screen. A button intercepts touch events and sends an action message to a target object when tapped. Methods for setting the target";
    } else {
        return nil;
    }
}

@end
