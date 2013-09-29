//
//  FNNetworkJoinVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/17/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNNetworkJoinVC.h"
#import "FNAppearance.h"
#import "FNSpinnerCell.h"

@interface FNNetworkJoinVC ()

@end

@implementation FNNetworkJoinVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIView *navTitle = [FNAppearance navBarTitleWithText:@"Join Game" forOrientation:self.interfaceOrientation];
    // need to change the color too !!!
    [navTitle setUserInteractionEnabled:NO];
    self.navigationItem.titleView = navTitle;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.dataSource viewControllerWillAppear:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *navTitle = [FNAppearance navBarTitleWithText:@"Join Game" forOrientation:self.interfaceOrientation];
    // need to change the color too !!!
    [navTitle setUserInteractionEnabled:NO];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.titleView = navTitle;
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.dataSource viewControllerWasDismissed:self];
}


#pragma mark - Table view data source

- (void)insertPeerAtIndex:(NSInteger)index
{
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deletePeerAtIndex:(NSInteger)index
{
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource peersCount];
}

- (UITableViewCell *)configureCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"spinnerCell";
    FNSpinnerCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.mainTextLabel.text = [self.dataSource displayNameForPeerAtIndex:indexPath.row];
    return cell;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self configureCellForRowAtIndexPath:indexPath];
    [super setBackgroundForCell:cell atIndexPath:indexPath];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.dataSource connectToServerAtIndex:indexPath.row];
    [((FNSpinnerCell *)[tableView cellForRowAtIndexPath:indexPath]) startSpinner];
}


@end
