//
//  FNUniqueIDObject.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/23/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNUniqueIDObject : NSObject <NSCoding>

@property (nonatomic, copy) NSUUID *uniqueID;

@end
