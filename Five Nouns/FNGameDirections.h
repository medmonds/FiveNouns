//
//  FNGameDirections.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/25/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FNGameDirections : NSObject

typedef NS_ENUM(NSInteger, FNGameDirectionType) {
    FNGameDirectionTypeOverview,
    FNGameDirectionTypeRoundOne,
    FNGameDirectionTypeRoundTwo,
    FNGameDirectionTypeRoundThree,
    FNGameDirectionTypeRoundFour,
};

@property (nonatomic) FNGameDirectionType *type;

+ (NSArray *)allDirectionsForGame;
+ (FNGameDirections *)directionsOfType:(FNGameDirectionType)type;
+ (FNGameDirectionType)directionTypeForRound:(NSInteger)round;

- (NSString *)directions;
- (NSString *)title;

@end
