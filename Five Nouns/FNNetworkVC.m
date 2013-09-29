//
//  FNNetworkVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/15/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNNetworkVC.h"
#import "FNReorderableCell.h"
#import "FNNetworkContainer.h"

@interface FNNetworkVC ()

@end

@implementation FNNetworkVC

- (void)insertClientAtIndex:(NSInteger)index
{
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteClientAtIndex:(NSInteger)index
{
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View Delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *header = [[UILabel alloc] init];
    header.text = @"Connected Players";
    header.textColor = [FNAppearance textColorLabel];
    header.font = [FNAppearance fontWithSize:18];
    header.backgroundColor = [FNAppearance tableViewBackgroundColor];
    header.textAlignment = NSTextAlignmentCenter;
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource peersCount];
}

- (UITableViewCell *)configureNameCellForIndexPath:(NSIndexPath *)indexPath
{
    FNReorderableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"reorderable"];
    cell.mainTextLabel.text = [self.dataSource displayNameForPeerAtIndex:indexPath.row];
    cell.showCellSeparator = NO;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self configureNameCellForIndexPath:indexPath];
    [super setBackgroundForCell:cell atIndexPath:indexPath];
    return cell;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


@end
