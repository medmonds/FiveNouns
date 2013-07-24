//
//  FNMultiplayerContainer.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/15/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FNMultiplayerHostDelegate;
@class FNMultiPlayerVC;

@interface FNMultiplayerContainer : UIViewController

@property (nonatomic, weak) FNMultiplayerHostDelegate *dataSource;

- (void)insertClientAtIndex:(NSInteger)index;
- (void)deleteClientAtIndex:(NSInteger)index;

@end
