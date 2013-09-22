//
//  FNAppearance.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/24/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNEditableCell.h"
#import "FNButtonCell.h"

#define CELL_IDENTIFIER_BUTTON @"button"
#define CELL_IDENTIFIER_PLAIN @"plain"
#define CELL_IDENTIFIER_SMALL_BUTTON @"smallButton"
#define CELL_IDENTIFIER_TEXT_FIELD @"textField"


typedef NS_ENUM(NSInteger, FNTableViewCellPosition) {
    FNTableViewCellPositionTop,
    FNTableViewCellPositionMiddle,
    FNTableViewCellPositionBottom,
    FNTableViewCellPositionNone
};

typedef NS_ENUM(NSInteger, FNCheckmarkStyle) {
    FNCheckmarkStyleUser,
    FNCheckmarkStyleGame,
};

@interface FNAppearance : NSObject

+ (CGFloat)cellSeparatorPartialIndent;

+ (CGFloat)cellSeparatorPartialHeight;

+ (CGFloat)cellSeparatorHeight;

+ (UIFont *)fontWithSize:(CGFloat)fontSize;

+ (UIColor *)tableViewBackgroundColor;

+ (UIColor *)cellSeparatorColor;

+ (UIColor *)textColorLabel;

+ (UIColor *)textColorButton;

+ (UIColor *)backgroundColorAccent;

+ (void)configureAppearanceProxies;

+ (UIView *)navBarTitleWithText:(NSString *)text forOrientation:(UIInterfaceOrientation)orientation;

+ (UIBarButtonItem *)backBarButtonItem;

+ (UIBarButtonItem *)forwardBarButtonItem;

+ (UIBarButtonItem *)optionsBarButtonItem;

+ (UIBarButtonItem *)barButtonItemDismiss;

+ (UIImage *)cellBackgroundForPosition:(FNTableViewCellPosition)position;

+ (UIImage *)backgroundForTextField;

+ (UIImage *)backgroundForButton;

+ (UIImage *)checkmarkWithStyle:(FNCheckmarkStyle)style;

+ (UIImage *)reorderControlImage;

+ (UIButton *)randomNounButton;

@end
