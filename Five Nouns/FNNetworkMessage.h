//
//  FNNetworkMessage.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 10/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNUniqueIDObject.h"


typedef NS_ENUM(NSUInteger, FNNetworkMessageType) {
    FNNetworkMessageTypeAssignNewHost,
    FNNetworkMessageTypeConfirmNewHost
};


@interface FNNetworkMessage : FNUniqueIDObject <NSCoding, NSCopying>

+ (FNNetworkMessage *)messageWithType:(FNNetworkMessageType)type
                             valueNew:(id)valueNew
                             valueOld:(id)valueOld;

@property FNNetworkMessageType type;
@property (nonatomic, strong) id valueNew;
@property (nonatomic, strong) id valueOld;

- (NSData *)messageAsData;
+ (FNNetworkMessage *)messageForData:(NSData *)data;

@end