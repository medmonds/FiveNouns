//
//  FNPausedVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/19/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNPausedVC.h"
#import "FNScoreController.h"
#import "FNTableViewController.h"

@interface FNPausedVC () <FNTVRowInsertAndDeleteManager>
@property (nonatomic, strong) FNScoreController *scoreController;
@end

@implementation FNPausedVC

- (void)donePressed
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}



- (void)insertRowsAtIndexPaths:(NSArray *)indexpaths forController:(id<UITableViewDelegate>)controller
{
    [self.tableView insertRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexpaths forController:(id<UITableViewDelegate>)controller
{
    [self.tableView deleteRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath forController:(id<UITableViewDelegate>)controller
{
    if (indexPath.section == 0) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.section == 1) {
        
    } else {
        
    }
}


#pragma mark - Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.scoreController tableView:tableView didSelectRowAtIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        
    } else {
        
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self.scoreController tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        
    } else {
        
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.scoreController tableView:tableView didHighlightRowAtIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        
    } else {
        
    }

}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.scoreController tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        
    } else {
        
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self.scoreController tableView:tableView heightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        
    } else {

    }
}

//- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

#pragma mark - Data Source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [self.scoreController tableView:tableView cellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        
    } else {
        
    }
    [super setBackgroundForCell:cell Style:FNTableViewCellStyleButton atIndexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (section == 0) {
        return [self.scoreController tableView:tableView numberOfRowsInSection:section];
//    }
//    } else if (section == 1) {
//        
//    } else {
//        
//    }
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
    UIBarButtonItem *done = [FNAppearance barButtonItemDismiss];
    [done setTarget:self];
    [done setAction:@selector(donePressed)];
    [self.navigationItem setRightBarButtonItem:done];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Directions"];
    self.navigationItem.leftBarButtonItem = nil;
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









