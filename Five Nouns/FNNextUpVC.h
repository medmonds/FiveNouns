//
//  FNNextUpVC.h
//  Five Nouns
//
//  Created by Jill on 5/22/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FNBrain;
@class FNPlayer;

@interface FNNextUpVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) FNBrain *brain;
@property (nonatomic) NSInteger round;
@property (nonatomic, weak) IBOutlet UICollectionView *mainScoreBoard;
@property (nonatomic, weak) IBOutlet UICollectionView *headerScoreBoard;
@property (weak, nonatomic) IBOutlet UICollectionView *footerScoreBoard;
@end
