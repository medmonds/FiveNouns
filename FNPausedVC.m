//
//  FNPausedVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/19/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNPausedVC.h"
#import "FNTVController.h"
#import "FNTVScoreDelegate.h"
#import "FNTVDirectionsDelegate.h"

@interface FNPausedVC () <FNTVRowInsertAndDeleteManager>
@property (nonatomic, strong) FNTVController *scoreController;
@property (nonatomic, strong) FNTVController *directionController;
@property (nonatomic, strong) FNTVController *addPlayerController;
@end

@implementation FNPausedVC

- (void)donePressed
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths forController:(FNTVController *)controller
{
    NSArray *convertedIndexPaths = [self convertIndexPaths:indexPaths fromController:controller];
    [self.tableView insertRowsAtIndexPaths:convertedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths forController:(FNTVController *)controller
{
    NSArray *convertedIndexPaths = [self convertIndexPaths:indexPaths fromController:controller];
    [self.tableView deleteRowsAtIndexPaths:convertedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath forController:(FNTVController *)controller
{
    NSArray *convertedIndexPaths = [self convertIndexPaths:@[indexPath] fromController:controller];
    [self.tableView deselectRowAtIndexPath:convertedIndexPaths[0] animated:YES];
}

- (NSArray *)convertIndexPaths:(NSArray *)indexPaths fromController:(FNTVController *)controller
{
    NSInteger section = [self sectionForController:controller];
    NSMutableArray *converted = [[NSMutableArray alloc] initWithCapacity:[indexPaths count]];
    for (NSIndexPath *index in indexPaths) {
        [converted addObject:[NSIndexPath indexPathForRow:index.row inSection:section]];
    }
    return converted;
}

- (NSInteger)sectionForController:(FNTVController *)controller
{
    NSInteger section = -1;
    if (controller == self.scoreController) {
        section = 0;
    } else if (controller == self.directionController) {
        section = 1;
    } else if (controller == self.scoreController) {
        section = 2;
    }
    NSAssert(section >= -1, @"Tried to convert indexPaths for an unrecognized controller");
    return section;
}

- (FNTVController *)controllerForIndexPath:(NSIndexPath *)indexPath
{
    FNTVController *controller;
    if (indexPath.section == 0) {
        controller = self.scoreController;
    } else if (indexPath.section == 1) {
        controller = self.directionController;
    } else if (indexPath.section == 2) {
        controller = self.addPlayerController;
    }
    NSAssert(controller, @"Tried to get controller for an out of bounds indexPath");
    return controller;
}

#pragma mark - Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self controllerForIndexPath:indexPath] tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self controllerForIndexPath:indexPath] tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self controllerForIndexPath:indexPath] tableView:tableView didHighlightRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self controllerForIndexPath:indexPath] tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self controllerForIndexPath:indexPath] tableView:tableView heightForRowAtIndexPath:indexPath];
}

//- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

#pragma mark - Data Source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[self controllerForIndexPath:indexPath] tableView:tableView cellForRowAtIndexPath:indexPath];
    [super setBackgroundForCell:cell Style:FNTableViewCellStyleButton atIndexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self controllerForIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]] tableView:tableView numberOfRowsInSection:section];
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
    self.scoreController.delegate.brain = self.brain;
    self.scoreController.delegate.shouldCollapseOnTitleTap = YES;
    self.scoreController.tableView = self.tableView;
    self.scoreController.tvController = self;
    [self.scoreController setup];
    
    self.directionController = [[FNTVController alloc] init];
    self.directionController.delegate = [[FNTVDirectionsDelegate alloc] init];
    self.directionController.delegate.shouldCollapseOnTitleTap = YES;
    self.directionController.tableView = self.tableView;
    self.directionController.tvController = self;
    [self.directionController setup];
    
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









