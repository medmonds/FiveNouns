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

@interface FNPausedVC ()
@property (nonatomic, strong) FNScoreController *scoreController;
@end

@implementation FNPausedVC

- (void)donePressed
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
    UIBarButtonItem *done = [FNAppearance barButtonItemDismiss];
    [done setTarget:self];
    [done setAction:@selector(donePressed)];
    [self.navigationItem setRightBarButtonItem:done];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Directions"];
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









