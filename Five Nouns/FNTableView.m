//
//  FNTableView.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 9/2/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNTableView.h"
#import "FNAppearance.h"

@interface FNTableView ()

@property (nonatomic, strong) UISwipeGestureRecognizer *deleteGesture;
@property (nonatomic, strong) NSIndexPath *deleteIndexPath;
@property (nonatomic, strong) id <FNTableViewDataSource> deleteDataSource;
@end


@implementation FNTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
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
    self.deleteGesture.delegate = self;
    [self addGestureRecognizer:self.deleteGesture];
    if ([self.dataSource conformsToProtocol:@protocol(FNTableViewDataSource) ]) {
        self.deleteDataSource = (id <FNTableViewDataSource>)self.dataSource;
    }
}

- (void)didRecognizeDeleteGesture:(UISwipeGestureRecognizer *)gesture
{
    if (!self.deleteDataSource) return; // deleting is not implemented
    CGPoint touch = [gesture locationInView:self];
    NSIndexPath *touchIndexPath = [self indexPathForRowAtPoint:touch];
    NSLog(@"didRecognizeDeleteGesture IndexPath: %@", touchIndexPath);
    if (!touchIndexPath) return;
    if ([self.deleteDataSource tableView:self canEditRowAtIndexPath:touchIndexPath]) {
        [self showDeleteControlForIndexPath:touchIndexPath];
    }
}

- (void)showDeleteControlForIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"showDeleteControlForIndexPath");
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    [cell setEditing:YES animated:YES];
    self.deleteIndexPath = indexPath;
}

- (void)deleteControlPressed
{
    NSLog(@"deleteControlPressed");
    [self.deleteDataSource tableView:self deleteRowAtIndexPath:self.deleteIndexPath];
    self.deleteIndexPath = nil;
}

- (void)hideDeleteControl
{
    NSLog(@"hideDeleteControl");
    UITableViewCell *cell = [self cellForRowAtIndexPath:self.deleteIndexPath];
    [cell setEditing:NO animated:YES];
    self.deleteIndexPath = nil;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"gestureRecognizerShouldBegin was deleteGesture %d", gestureRecognizer == self.deleteGesture);
    if (self.deleteIndexPath) {
        [self hideDeleteControl];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    if (!self.deleteIndexPath) {
        return YES;
    }
    UITableViewCell *cell = [self cellForRowAtIndexPath:self.deleteIndexPath];
    if ([cell pointInside:[[touches anyObject] locationInView:cell.editingAccessoryView] withEvent:event]) {
        return YES;
    } else {
        [self hideDeleteControl];
        return NO;
    }
}

@end
