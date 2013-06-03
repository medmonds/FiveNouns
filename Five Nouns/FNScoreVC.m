//
//  FNScoreVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/1/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNScoreVC.h"
#import "FNScoreCard.h"
#import "FNPlayer.h"
#import "FNTeam.h"
#import "FNScoreViewCell.h"

@interface FNScoreVC ()
@property (nonatomic, strong) NSArray *turnScores;
@property (nonatomic, strong) NSArray *teamsAndScores;
@end

@implementation FNScoreVC

#define INTER_ITEM_SPACING 8

#pragma mark - Score View

- (void)setBrain:(FNBrain *)brain
{
    _brain = brain;
    [self setup];
}

- (void)setup
{
    [self configureViews];
    [self configureData];
    [self.headerScoreBoard reloadData];
    [self.mainScoreBoard reloadData];
    [self.footerScoreBoard reloadData];
}

- (void)configureViews
{
    [self.headerScoreBoard setScrollEnabled:NO];
    [self.footerScoreBoard setScrollEnabled:NO];
    self.mainScoreBoard.delegate = self;
    self.mainScoreBoard.dataSource = self;
    self.headerScoreBoard.delegate = self;
    self.headerScoreBoard.dataSource = self;
    self.footerScoreBoard.delegate = self;
    self.footerScoreBoard.dataSource = self;
}

- (void)configureData
{
    // should move this block into the scoreCard Class
    NSArray *sorted = [[self.brain allScoreCards] sortedArrayUsingComparator:^(FNScoreCard *card1, FNScoreCard *card2) {
        if (card1.round > card2.round) {
            return (NSComparisonResult)NSOrderedDescending;
        } else if (card1.round < card2.round) {
            return (NSComparisonResult)NSOrderedAscending;
        } else {
            if (card1.turn > card2.turn) {
                return (NSComparisonResult)NSOrderedDescending;
            } else if (card1.turn < card2.turn) {
                return (NSComparisonResult)NSOrderedAscending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }
        }
    }];
    
    // fix this if no scoreCards then it wont create the list of teams and the score will be blank
    NSMutableArray *teamsAndScores = [[NSMutableArray alloc] init];
    for (FNTeam *team in self.brain.allTeams) {
        [teamsAndScores addObject:[[NSMutableArray alloc] initWithObjects:team, @0, nil]];
    }
    for (FNScoreCard *card in sorted) {
        for (NSMutableArray *team in teamsAndScores) {
            if ([team[0] isEqual:card.player.team]) {
                team[1] = @([(NSNumber *)team[1] integerValue] + [card.nounsScored count]);
            }
        }
    }
    self.turnScores = sorted;
    self.teamsAndScores = teamsAndScores;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.mainScoreBoard reloadData];
    [self.headerScoreBoard reloadData];
}

#pragma mark - Score View Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger itemCount = 0;
    if (collectionView == self.headerScoreBoard || collectionView == self.footerScoreBoard) {
        itemCount = [self.teamsAndScores count];
    } else {
        itemCount = [self.turnScores count];
    }
    return itemCount;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FNScoreViewCell *cell;
    if (collectionView == self.headerScoreBoard) {
        cell = [self.headerScoreBoard dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        FNTeam *team = self.teamsAndScores[indexPath.item][0];
        cell.label.text = team.name;
    } else if (collectionView == self.mainScoreBoard) {
        cell = [self.mainScoreBoard dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        FNScoreCard *score = self.turnScores[indexPath.item];
        cell.label.text = [NSString stringWithFormat:@"%d", [[score nounsScored] count]];
    } else {
        cell = [self.footerScoreBoard dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        NSNumber *teamScore = (self.teamsAndScores[indexPath.item])[1];
        cell.label.text = [teamScore stringValue];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat totalSpacing = ([self.teamsAndScores count] - 1) * INTER_ITEM_SPACING;
    CGFloat width = (self.mainScoreBoard.bounds.size.width - totalSpacing) / [self.teamsAndScores count];
    return CGSizeMake(width, width);
}

// can be set with properties or methods
/*
 - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
 {
 
 }
 
 - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
 {
 
 }
 
 - (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
 {
 
 }
 
 - (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
 {
 
 }
 */

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return INTER_ITEM_SPACING;
}

#pragma mark - Score View Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Score View Collection View Flow Layout

- (UICollectionViewFlowLayout *)layoutForCollectionView:(UICollectionView *)collectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.footerReferenceSize = CGSizeMake(0, 0);
    layout.headerReferenceSize = CGSizeMake(0, 0);
    CGFloat totalSpacing = ([self.teamsAndScores count] - 1) * INTER_ITEM_SPACING;
    CGFloat width = (self.mainScoreBoard.bounds.size.width - totalSpacing) / [self.teamsAndScores count];
    layout.itemSize = CGSizeMake(width, width);
    layout.minimumInteritemSpacing = INTER_ITEM_SPACING;
    layout.minimumLineSpacing = 10;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    return layout;
}


@end
