//
//  FNScoreVC.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/1/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNBrain.h"

@interface FNScoreVC : NSObject <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) FNBrain *brain;
@property (nonatomic, weak) UICollectionView *mainScoreBoard;
@property (nonatomic, weak) UICollectionView *headerScoreBoard;
@property (nonatomic, weak) UICollectionView *footerScoreBoard;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

@end
