//
//  FNScoreVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/1/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNScoreVC.h"
#import "FNTVController.h"
#import "FNAppearance.h"
#import "FNTVScoreDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface FNScoreVC () <FNTVRowInsertAndDeleteManager>
@property (nonatomic, strong) FNTVController *scoreController;
@end

@implementation FNScoreVC

#pragma mark - FNTVRowInsertAndDeleteManager

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths forController:(FNTVController *)controller
{
    NSIndexPath *aboveIndexPath = [NSIndexPath indexPathForRow:((NSIndexPath *)indexPaths[0]).row - 1 inSection:((NSIndexPath *)indexPaths[0]).section];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:aboveIndexPath];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [super setBackgroundForCell:cell atIndexPath:aboveIndexPath];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths forController:(FNTVController *)controller
{    
    NSIndexPath *aboveIndexPath = [NSIndexPath indexPathForRow:((NSIndexPath *)indexPaths[0]).row - 1 inSection:((NSIndexPath *)indexPaths[0]).section];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:aboveIndexPath];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [super setBackgroundForCell:cell atIndexPath:aboveIndexPath];
    }];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [CATransaction commit];
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath forController:(FNTVController *)controller
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.scoreController tableView:tableView cellForRowAtIndexPath:indexPath];
    [super setBackgroundForCell:cell atIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.textColor = [FNAppearance textColorLabel];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = [self.scoreController tableView:tableView numberOfRowsInSection:section];
    return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


#pragma mark - Internal Methods

- (void)setBrain:(FNBrain *)brain
{
    _brain = brain;
    self.scoreController.delegate.brain = _brain;
}

- (void)orderTeamsByScore
{
    id scoreDelegate = self.scoreController.delegate;
    if ([scoreDelegate respondsToSelector:@selector(orderTeamsByScore)]) {
        [scoreDelegate performSelector:@selector(orderTeamsByScore)];
        [self.scoreController.tableView reloadData];
    }
}

#pragma mark - Life Cycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scoreController = [[FNTVController alloc] init];
    self.scoreController.delegate = [[FNTVScoreDelegate alloc] init];
    self.scoreController.delegate.shouldCollapseOnTitleTap = NO;
    self.scoreController.tableView = self.tableView;
    self.scoreController.tvController = self;
    self.tableView.delegate = self.scoreController;
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scoreController.delegate.brain = self.brain;
    [self.scoreController setup];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
