//
//  FNNounGenerator.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 9/3/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNNounGenerator.h"

@interface FNNounGenerator ()
@property (nonatomic, strong) NSArray *nouns;
@end

@implementation FNNounGenerator

- (NSString *)noun
{
    return self.nouns[arc4random_uniform([self.nouns count])];
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    if (![self loadNouns]) {
        return nil;
    }
    return self;
}

- (BOOL)loadNouns
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"nouns" ofType:@"txt"];
    NSError *error;
    NSString *nounsString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        return NO;
    } else {
        self.nouns = [nounsString componentsSeparatedByString:@"\n"];
        return YES;
    }
}

@end
