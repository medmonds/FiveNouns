//
//  FNScoreVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/1/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNScoreVC.h"
#import "FNScoreController.h"
#import "FNAppearance.h"

@interface FNScoreVC () <FNTVRowInsertAndDeleteManager>
@property (nonatomic, strong) FNScoreController *scoreController;
@end

@implementation FNScoreVC

- (void)insertRowsAtIndexPaths:(NSArray *)indexpaths forController:(id<UITableViewDelegate>)controller
{
    [self.tableView insertRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexpaths forController:(id<UITableViewDelegate>)controller
{
    [self.tableView deleteRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)setBrain:(FNBrain *)brain
{
    _brain = brain;
    self.scoreController.brain = _brain;
}

#pragma mark - Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.scoreController tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return NO;
    } else {
        return [self.scoreController tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.scoreController tableView:tableView didHighlightRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.scoreController tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.scoreController tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.scoreController tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}

#pragma mark - Data Source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.scoreController tableView:tableView cellForRowAtIndexPath:indexPath];
    [super setBackgroundForCell:cell Style:FNTableViewCellStyleButton atIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.textColor = [FNAppearance textColorLabel];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.scoreController tableView:tableView numberOfRowsInSection:section];
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
    self.scoreController = [[FNScoreController alloc] init];
    self.scoreController.brain = self.brain;
    self.scoreController.tableView = self.tableView;
    self.scoreController.tvController = self;
    
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.scoreController setup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
