//
//  FNDirectionView.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/23/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FNDirectionView;

@protocol FNDirectionViewPresenter <NSObject>
- (void)directionViewWasDismissed:(FNDirectionView *)view;
@end

@interface FNDirectionView : UIView
@property (nonatomic) NSInteger round;
@property (nonatomic, strong) NSString *directions;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, weak) id <FNDirectionViewPresenter> presenter;
@end

