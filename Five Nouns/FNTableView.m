//
//  FNTableView.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 9/2/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNTableView.h"

@interface FNTableView ()

@property (nonatomic, strong) UISwipeGestureRecognizer *deleteGesture;
@property (nonatomic) BOOL gesturesShouldBegin;
@property (nonatomic, strong) NSIndexPath *deleteIndexPath;
@property (nonatomic, strong) id <FNTableViewDataSource> deleteDataSource;
@end


@implementation FNTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    [self commonInit];
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
}

- (void)commonInit
{
    self.deleteGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeDeleteGesture:)];
    self.deleteGesture.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:self.deleteGesture];
    self.gesturesShouldBegin = YES;
    if ([self.dataSource conformsToProtocol:@protocol(FNTableViewDataSource) ]) {
        self.deleteDataSource = (id <FNTableViewDataSource>)self.dataSource;
    }
}

- (void)didRecognizeDeleteGesture:(UISwipeGestureRecognizer *)gesture
{
    CGPoint touch = [gesture locationInView:self];
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:touch];
    NSLog(@"didRecognizeDeleteGesture IndexPath: %@", indexPath);
    if (!self.deleteDataSource || !indexPath) {
        return;
    }
    if (self.gesturesShouldBegin) {
        if ([self.deleteDataSource tableView:self canEditRowAtIndexPath:indexPath]) {
            [self showDeleteControlForIndexPath:indexPath];
        }
    } else {
        [self hideDeleteControl];
    }
}

- (void)showDeleteControlForIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"showDeleteControlForIndexPath");
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    self.gesturesShouldBegin = NO;
    if ([cell conformsToProtocol:@protocol(FNDeleteCell)]) {
        self.deleteIndexPath = indexPath;
        // implement in a cell superclass
        [(id <FNDeleteCell>)cell showDeleteControlForTableView:self withSelector:@selector(deleteControlPressed)];
    }
}

- (void)deleteControlPressed
{
    NSLog(@"deleteControlPressed");
    UITableViewCell *cell = [self cellForRowAtIndexPath:self.deleteIndexPath];
    [self.deleteDataSource tableView:self deleteRowAtIndexPath:self.deleteIndexPath];
    if ([cell conformsToProtocol:@protocol(FNDeleteCell)]) {
        // implement in a cell superclass
        [(id <FNDeleteCell>)cell setDeletedState];
    }
    self.deleteIndexPath = nil;
    self.gesturesShouldBegin = YES;
}

- (void)hideDeleteControl
{
    NSLog(@"hideDeleteControl");
    UITableViewCell *cell = [self cellForRowAtIndexPath:self.deleteIndexPath];
    if ([cell conformsToProtocol:@protocol(FNDeleteCell)]) {
        // implement in a cell superclass
        [(id <FNDeleteCell>)cell hideDeleteControlForTableView];
    }
    self.deleteIndexPath = nil;
    self.gesturesShouldBegin = YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"gestureRecognizerShouldBegin was deleteGesture %d", gestureRecognizer == self.deleteGesture);
    if (gestureRecognizer == self.panGestureRecognizer) {
        BOOL shouldBegin = self.gesturesShouldBegin;
        [self hideDeleteControl];
        return shouldBegin;
    } else {
        return  self.gesturesShouldBegin;
    }
}

@end
