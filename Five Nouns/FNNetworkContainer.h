//
//  FNNetworkContainer.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/15/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNNetworkManager.h"

@class FNNetworkVC;

@interface FNNetworkContainer : UIViewController <FNNetworkViewController>

@property (nonatomic, weak) id <FNNetworkViewControllerDataSource> dataSource;

@end
