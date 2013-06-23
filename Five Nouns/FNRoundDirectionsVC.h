//
//  FNRoundDirectionsVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/2/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FNBrain;
@class FNRoundDirectionsVC;

@protocol FNDirectionsVCPresenter <NSObject>

- (void)dismissDirectionVC:(FNRoundDirectionsVC *)vc;

@end

@interface FNRoundDirectionsVC : UIViewController

@property (nonatomic, weak) FNBrain *brain;
@property (nonatomic) NSInteger round;
@property (nonatomic, weak) UIViewController <FNDirectionsVCPresenter> *presentingVC;


@end
