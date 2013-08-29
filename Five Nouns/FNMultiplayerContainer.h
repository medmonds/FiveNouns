//
//  FNMultiplayerContainer.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/15/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNMultiplayerManager.h"

@class FNMultiPlayerVC;

@interface FNMultiplayerContainer : UIViewController <FNMultiplayerViewController>

@property (nonatomic, weak) id <FNMultiplayerViewControllerDataSource> dataSource;

@end
