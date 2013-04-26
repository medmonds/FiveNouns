//
//  FNAppearance.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/24/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FNTableViewCellStyle) {
    FNTableViewCellStyleButton,
    FNTableViewCellStyleTextFieldLabel,
    FNTableViewCellStyleTextField,
    FNTableViewCellStyleTextFieldButton,
    FNTableViewCellStyleButtonSmall,
    FNTableViewCellStylePlain
};

typedef NS_ENUM(NSInteger, FNTableViewCellPosition) {
    FNTableViewCellPositionTop,
    FNTableViewCellPositionMiddle,
    FNTableViewCellPositionBottom,
    FNTableViewCellPositionNone
};

@interface FNAppearance : NSObject

+ (UIColor *)tableViewBackgroundColor;

+ (void)configureAppearanceProxies;

+ (UILabel *)navBarTitleWithText:(NSString *)text;

+ (UIBarButtonItem *)backBarButtonItem;

+ (UIBarButtonItem *)forwardBarButtonItem;

+ (UIImage *)backgroundForCellWithStyle:(FNTableViewCellStyle)style forPosition:(FNTableViewCellPosition)position;

@end
