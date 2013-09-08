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
#import "FNTVAddPlayerDelegate.h"
#import "FNTVTeamsDelegate.h"
#import "FNNewGameVC.h"
#import <QuartzCore/QuartzCore.h>

@interface FNPausedVC () <FNTVRowInsertAndDeleteManager, UIActionSheetDelegate>
@property (nonatomic, strong) FNTVController *scoreController;
@property (nonatomic, strong) FNTVController *directionController;
@property (nonatomic, strong) FNTVController *addPlayerController;
@property (nonatomic, strong) FNTVController *teamsController;
@property (nonatomic, strong) NSIndexPath *lastSelectedHeader;
@end

@implementation FNPausedVC

- (void)donePressed
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        [self returnToMainMenu];
    }
}

- (void)quitPressed
{
    NSLog(@"Quit Pressed");
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to quit?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Quit Game"
                                              otherButtonTitles:nil];
    [sheet showInView:self.view];
}

- (void)returnToMainMenu
{
    //save the game to be accessible from the Resume Game Button on main page
    
    // instaniate the main menu controller & push it on the stack
    FNNewGameVC *mainMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGameVC"];
    [self.navigationController setViewControllers:@[mainMenu] animated:YES];
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths forController:(FNTVController *)controller
{
    NSArray *convertedIndexPaths = [self convertIndexPaths:indexPaths fromController:controller];
    if ([convertedIndexPaths count] > 0) {
        NSIndexPath *headerIndexPath = [NSIndexPath indexPathForRow:0 inSection:((NSIndexPath *)convertedIndexPaths[0]).section];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:headerIndexPath];
        [super setBackgroundForCell:cell withPosition:FNTableViewCellPositionTop];
        [self.tableView insertRowsAtIndexPaths:convertedIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths forController:(FNTVController *)controller
{
    NSArray *convertedIndexPaths = [self convertIndexPaths:indexPaths fromController:controller];
    if ([convertedIndexPaths count] > 0) {
        NSIndexPath *headerIndexPath = [NSIndexPath indexPathForRow:0 inSection:((NSIndexPath *)convertedIndexPaths[0]).section];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:headerIndexPath];
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [super setBackgroundForCell:cell atIndexPath:headerIndexPath];
        }];
        [self.tableView deleteRowsAtIndexPaths:convertedIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        [CATransaction commit];
    }
}

//- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths forController:(FNTVController *)controller
//{
//    NSArray *convertedIndexPaths = [self convertIndexPaths:indexPaths fromController:controller];
//    [self.tableView reloadRowsAtIndexPaths:convertedIndexPaths withRowAnimation:UITableViewRowAnimationNone];
//}

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
    } else if (controller == self.teamsController) {
        section = 1;
    } else if (controller == self.directionController) {
        section = 2;
    } else if (controller == self.addPlayerController) {
        section = 3;
    } else if (!controller) {
        section = 4;
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
        controller = self.teamsController;
    } else if (indexPath.section == 2) {
        controller = self.directionController;
    } else if (indexPath.section == 3) {
        controller = self.addPlayerController;
    } else if (indexPath.section == 4) {
        controller = nil;
    }
    //NSAssert(controller, @"Tried to get controller for an out of bounds indexPath");
    return controller;
}

#pragma mark - Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (![self.lastSelectedHeader isEqual:indexPath] && self.lastSelectedHeader) {
            FNTVController *controller = [self controllerForIndexPath:self.lastSelectedHeader];
            [controller tableView:tableView didSelectRowAtIndexPath:self.lastSelectedHeader];
            self.lastSelectedHeader = indexPath;
        } else if ([self.lastSelectedHeader isEqual:indexPath]) {
            self.lastSelectedHeader = nil;
        } else {
            self.lastSelectedHeader = indexPath;
        }
    }
    FNTVController *controller = [self controllerForIndexPath:indexPath];
    if (controller) {
        [controller tableView:tableView didSelectRowAtIndexPath:indexPath];
    } else {
        // this is for the quite button.
        [self quitPressed];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    FNTVController *controller = [self controllerForIndexPath:indexPath];
    if (controller) {
        return [controller tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    } else {
        // this is for the quite button.
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    FNTVController *controller = [self controllerForIndexPath:indexPath];
    if (controller) {
        [controller tableView:tableView didHighlightRowAtIndexPath:indexPath];
    } else {
        // this is for the quite button.
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    FNTVController *controller = [self controllerForIndexPath:indexPath];
    if (controller) {
        [controller tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
    } else {
        // this is for the quite button.
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FNTVController *controller = [self controllerForIndexPath:indexPath];
    if (controller) {
        return [controller tableView:tableView heightForRowAtIndexPath:indexPath];
    } else {
        // this is for the quite button.
        return 44;
    }
}


#pragma mark - Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    FNTVController *controller = [self controllerForIndexPath:indexPath];
    if (controller) {
        cell = [[self controllerForIndexPath:indexPath] tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        // this is for the quite button.
        cell = [tableView dequeueReusableCellWithIdentifier:@"headerCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Quit Game";
        cell.textLabel.font = [FNAppearance fontWithSize:30];
        cell.textLabel.textColor = [UIColor redColor];
        ((FNSeparatorCell *)cell).showCellSeparator = NO;
    }
    [super setBackgroundForCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    FNTVController *controller = [self controllerForIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    if (controller) {
        return [controller tableView:tableView numberOfRowsInSection:section];
    } else {
        // this is for the quite button.
        return 1;
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
    self.scoreController.tableView = self.tableView;
    self.scoreController.tvController = self;
    FNTVScoreDelegate *score = [[FNTVScoreDelegate alloc] init];
    score.brain = self.brain;
    score.shouldCollapseOnTitleTap = YES;
    self.scoreController.delegate = score;
    [self.scoreController setup];
    
    self.directionController = [[FNTVController alloc] init];
    self.directionController.tableView = self.tableView;
    self.directionController.tvController = self;
    FNTVDirectionsDelegate *directions = [[FNTVDirectionsDelegate alloc] init];
    directions.shouldCollapseOnTitleTap = YES;
    self.directionController.delegate = directions;
    [self.directionController setup];
    
    self.addPlayerController = [[FNTVController alloc] init];
    self.addPlayerController.tableView = self.tableView;
    self.addPlayerController.tvController = self;
    FNTVAddPlayerDelegate *addPlayer = [[FNTVAddPlayerDelegate alloc] init];
    addPlayer.brain = self.brain;
    self.addPlayerController.delegate = addPlayer;
    [self.addPlayerController setup];
    
    self.teamsController = [[FNTVController alloc] init];
    self.teamsController.tableView = self.tableView;
    self.teamsController.tvController = self;
    FNTVTeamsDelegate *teams = [[FNTVTeamsDelegate alloc] init];
    teams.brain = self.brain;
    teams.shouldCollapseOnTitleTap = YES;
    self.teamsController.delegate = teams;
    [self.teamsController setup];
    
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
    UIBarButtonItem *done = [FNAppearance barButtonItemDismiss];
    [done setTarget:self];
    [done setAction:@selector(donePressed)];
    [self.navigationItem setRightBarButtonItem:done];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Options" forOrientation:self.interfaceOrientation];
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









