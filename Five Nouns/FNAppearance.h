//
//  FNAppearance.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/24/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNAppearance : NSObject

+ (UIColor *)tableViewBackgroundColor;

+ (void)configureAppearanceProxies;

+ (UILabel *)navBarTitleWithText:(NSString *)text;

+ (UIBarButtonItem *)backBarButtonItem;

+(UIBarButtonItem *)forwardBarButtonItem;

@end
