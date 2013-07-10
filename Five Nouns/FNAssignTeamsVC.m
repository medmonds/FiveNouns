//
//  FNAssignTeamsVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNAssignTeamsVC.h"
#import <QuartzCore/QuartzCore.h>
#import "FNPlayer.h"
#import "FNStepperCell.h"
#import "FNReorderableCell.h"
#import "FNSelectableCell.h"
#import "FMMoveTableView.h"
#import "FNNextUpVC.h"
#import "FNStepperView.h"

@interface FNAssignTeamsVC ()
//@property (nonatomic, strong) NSMutableArray *teams;
@property (nonatomic) NSInteger visibleTeam;
@property (strong, nonatomic) FNStepperView *stepperView;
@end



@implementation FNAssignTeamsVC


/*****************************************************************************************************
  
 To Do:
 
 - animate adding and remove the forward button when number of teams moves to & past zero
   then remove the check at - forwardBarButtonItemPressed
 
 - make button backgrounds for the selected state
 - set the selected background for the stepper when stepped
 - (??) set the selected background for the reorder control when reordering (not when pressed)
 - change team name to be edited in the button cell (row 0) and make the background dark when expanded
 
 Ideas:
 
 To show all of the team members (for Review) could just show the assigned players & Just the
 team name header cell (maybe checkmarks) but in a flat (not inset) manner and then when pressed
 animate and "push the cells into the game" for the the inset look
 
 
 ******************************************************************************************************/


typedef NS_ENUM(NSInteger, FNTeamCellType) {
    FNTeamCellTypeNumberOfTeams,
    FNTeamCellTypeReorder,
    FNTeamCellTypeName,
    FNTeamCellTypePlayer
};

- (NSMutableArray *)configureDataSource:(NSMutableArray*)data
{
    NSArray *sorted = [data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *first = ((FNPlayer *)obj1).team.name ? ((FNPlayer *)obj1).team.name : @"";
        NSString *second = ((FNPlayer *)obj2).team.name ? ((FNPlayer *)obj2).team.name : @"";
        return [first localizedCaseInsensitiveCompare:second];
    }];
    data = [sorted mutableCopy];
    return data;
}

- (void)forwardBarButtonItemPressed
{
    if ([self.brain.allTeams count] > 0) {
        [self performSegueWithIdentifier:@"nextUp" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((FNNextUpVC *)segue.destinationViewController).brain = self.brain;
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    // if the textfield is active & the team is deleted by the stepper could go out of array bounds
    if ([self.brain.allTeams count] > textField.tag) {
        FNTeam *team = [self.brain.allTeams objectAtIndex:textField.tag];
        team.name = textField.text;
    }
    return YES;
}

- (void)playerAssignmentIndicatorPressed:(UIButton *)sender
{
    // figure out the current state then cycle it accordingly & set the properties & image
    FNSelectableCell *cell = ((FNSelectableCell *)sender.superview.superview);
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    FNPlayer *player = cell.objectForCell;
    FNTeam *team = [self.brain.allTeams objectAtIndex:indexPath.section - 1];
    if ([team.players containsObject:player] && player.team == team) {
        // full release of player
        player.team = nil;
        [team removePlayer:player];
        [cell.button setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    } else if ([team.players containsObject:player]) {
        // user assigned team
        player.team = team;
        [cell.button setImage:[FNAppearance checkmarkWithStyle:FNCheckmarkStyleUser] forState:UIControlStateNormal];
    } else {
        // computer assigned team
        for (FNTeam *team in self.brain.allTeams) {
            [team removePlayer:player];
        }
        [team addPlayer:player];
        [cell.button setImage:[FNAppearance checkmarkWithStyle:FNCheckmarkStyleGame] forState:UIControlStateNormal];
    }
}

- (void)stepperDidStep:(UIStepper *)stepper
{
    [CATransaction begin];
    [self.tableView beginUpdates];
    int numberOfTeams = stepper.value;
    if (numberOfTeams > [self.brain.allTeams count]) {
        [CATransaction setCompletionBlock:^{
            [self assignPlayersToTeams];
        }];
        for (int i = numberOfTeams - [self.brain.allTeams count]; i > 0; i--) {
            FNTeam *newTeam = [[FNTeam alloc] init];
            newTeam.name = [NSString stringWithFormat:@"Team %d", [self.brain.allTeams count] + 1];
            [self.brain.allTeams insertObject:newTeam atIndex:[self.brain.allTeams count]];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:[self.brain.allTeams count]] withRowAnimation:UITableViewRowAnimationTop];
        }
    } else if ([self.brain.allTeams count] > numberOfTeams) {
        [CATransaction setCompletionBlock:^{
            [self assignUnAssignedPlayers];
        }];
        for (int i = [self.brain.allTeams count] - numberOfTeams; i > 0; i--) {
            // flip the order of remove object & the if statement
            [self.brain.allTeams removeLastObject];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:[self.brain.allTeams count] + 1] withRowAnimation:UITableViewRowAnimationTop];
            if (self.visibleTeam == [self.brain.allTeams count] + 1) {
                self.visibleTeam = 0;
            }
        }
    }
    FNStepperCell *cell = (FNStepperCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UIButton *buttonLabel = cell.detailButtonLabel;
    buttonLabel.titleLabel.text = [NSString stringWithFormat:@"%d", numberOfTeams];
    [self.tableView endUpdates];
    [CATransaction commit];
}

- (void)assignPlayersToTeams
{
    // reset the computer assigned team assignments
    FNPlayer *player;
    for (FNTeam *team in self.brain.allTeams) {
        for (int i = [team.players count] -1; i >= 0; i--) {
            player = [team.players objectAtIndex:i];
            if (player.team != team) {
                [team removePlayer:player];
            }
        }
    }
    if ([self.brain.allTeams count] > 0) {
        // all players in the game
        NSMutableArray *players = [[NSMutableArray alloc] init];
        for (FNPlayer *player in [self.brain allPlayers]) {
            if (!player.team) {
                [players addObject:player];
            }
        }
        NSInteger playersPerTeam = [self.brain.allPlayers count] / [self.brain.allTeams count];
        for (FNTeam *team in self.brain.allTeams) {
            for (int i = [team.players count]; i < playersPerTeam; i++) {
                if ([players count] > 0) {
                    NSInteger randomPlayer = arc4random() % [players count];
                    [team addPlayer:[players objectAtIndex:randomPlayer]];
                    [players removeObjectAtIndex:randomPlayer];
                }
            }
        }
        // to assign any left over players
        NSInteger index = 0;
        for (FNPlayer *player in players) {
            FNTeam *team = [self.brain.allTeams objectAtIndex:index];
            [team addPlayer:player];
            index++;
        }
    }
    [self refreshVisibleTeam];
}

- (void)refreshVisibleTeam
{
    if (self.visibleTeam > 0) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = [self tableView:self.tableView numberOfRowsInSection:self.visibleTeam] - 1; i > 1; i--) {
            [array addObject:[NSIndexPath indexPathForRow:i inSection:self.visibleTeam]];
        }
        [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)assignUnAssignedPlayers
{
    if ([self.brain.allTeams count] > 0) {
        NSInteger playersPerTeam = [self.brain.allPlayers count] / [self.brain.allTeams count];
        if (([self.brain.allPlayers count] % [self.brain.allTeams count]) > 0) {
            playersPerTeam++;
        }
        for (FNPlayer *player in self.brain.allPlayers) {
            BOOL isOnTeam = NO;
            //        NSLog(@"current player: %@", player.name);
            for (FNTeam *team in self.brain.allTeams) {
                //            NSLog(@"team: %@", team.name);
                //            for (FNPlayer *player in team.players) {
                //                NSLog(@"%@", player.name);
                //            }
                if ([team.players containsObject:player]) {
                    isOnTeam = YES;
                    break;
                }
            }
            if (!isOnTeam) {
                NSArray *sorted = [self.brain.allTeams sortedArrayUsingComparator:^NSComparisonResult(FNTeam *obj1, FNTeam *obj2) {
                    if ([obj1.players count] < [obj2.players count]) {
                        return NSOrderedAscending;
                    } else if ([obj1.players count] > [obj2.players count]) {
                        return NSOrderedDescending;
                    } else {
                        return NSOrderedSame;
                    }
                }];
                for (FNTeam *team in sorted) {
                    if ([team.players count] < playersPerTeam) {
                        //                    NSLog(@"Assigning: %@   to team: %@", player.name, team.name);
                        [team addPlayer:player];
                        // this refresh call should be moved ?? !!
                        [self refreshVisibleTeam];
                        break;
                    }
                }
            }
        }
    }
}

- (void)toggleTeamForSection:(NSInteger)section
{
    // if anything is open close it. If selected is not open, open it.
    [CATransaction begin];
    NSInteger oldTeam = self.visibleTeam;
    [CATransaction setCompletionBlock:^{
        NSIndexPath *index1 = [NSIndexPath indexPathForRow:0 inSection:section];
        NSIndexPath *index2 = [NSIndexPath indexPathForRow:0 inSection:oldTeam];
        UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:index1];
        UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:index2];
        [self setBackgroundForCell:cell1 atIndexPath:index1];
        [self setBackgroundForCell:cell2 atIndexPath:index2];
    }];
    [self.tableView beginUpdates];
    NSInteger currentlyVisible = self.visibleTeam;
    // close the open team
    if (currentlyVisible > 0) {
        // get the indexPaths for the open section & delete the rows
        NSMutableArray *array = [[NSMutableArray alloc] init];
        int rowsToDelete = [self tableView:self.tableView numberOfRowsInSection:currentlyVisible];
        for (int i = 1; i < rowsToDelete; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:currentlyVisible];
            [array addObject:path];
        }
        [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
        self.visibleTeam = 0;
        [self assignUnAssignedPlayers];
    }
    // open the team section
    if (section != currentlyVisible) {
        self.visibleTeam = section;
        // conditionally open the selected team
        NSMutableArray *array = [[NSMutableArray alloc] init];
        int rowsToInsert = [self tableView:self.tableView numberOfRowsInSection:section];
        for (int i = 1; i < rowsToInsert; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:section];
            [array addObject:path];
        }
        [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
    }
    [self.tableView endUpdates];
    [CATransaction commit];
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        [self toggleTeamForSection:indexPath.section];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setHighlighted:YES animated:YES];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setHighlighted:NO animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // should never be called
}

#pragma mark - Move Table View

- (BOOL)canReorderTableView
{
    if (self.visibleTeam > 0) {
        return NO;
    }
    return YES;
}

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    FNTeam *movedTeam = self.brain.allTeams[fromIndexPath.section - 1];
    [self.brain.allTeams removeObjectAtIndex:fromIndexPath.section - 1];
    [self.brain.allTeams insertObject:movedTeam atIndex:toIndexPath.section - 1];
    NSLog(@"Moved Team From Index: %d to %d", fromIndexPath.section, toIndexPath.section);
}

- (NSIndexPath *)moveTableView:(FMMoveTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row == 1 || proposedDestinationIndexPath.section == 0) {
        proposedDestinationIndexPath = nil;
    }
	return proposedDestinationIndexPath;
}

/*
- (CGFloat)tableView:(FMMoveTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning Implement this check in your table view delegate if necessary
//     * Implement this check in your table view delegate to ensure correct access to the row heights in
//     * data source.
//     *
//     * SKIP this check if all of your rows have the same heigt!
//     *
//     * The data source is in a dirty state when moving a row and is only being updated after the user
//     * releases the moving row
    indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
	
    NSArray *movie = [[[self movies] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    CGFloat heightForRow = [[movie objectAtIndex:kIndexRowHeightOfMovie] floatValue];
    
    return heightForRow;
}
*/

// not implemented b/c if the row doesn't have a reorder control then is can't be moved
//- (BOOL)moveTableView:(FMMoveTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + [self.brain.allTeams count];
}

- (NSInteger)tableView:(FMMoveTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (section == 0) {
        numberOfRows = 1;
    } else {
        if (section == self.visibleTeam) {
            FNTeam *team = [self.brain.allTeams objectAtIndex:section - 1];
            NSInteger playerCount = [team.players count];
            numberOfRows = 2 + playerCount + [[self availablePlayersForTeam:team] count];
        } else {
            numberOfRows = 1;
        }
    }
    /******************************** NOTE ************************************************************
	 * Implement this check in your table view data source to ensure correct access to the data source
	 * The data source is in a dirty state when moving a row and is only being updated after the user
	 * releases the moving row
     * 1. A row is in a moving state
     * 2. The moving row is not in it's initial section
	 *************************************************************************************************/
//    if ([tableView movingIndexPath] && [[tableView movingIndexPath] section] != [[tableView initialIndexPathForMovingRow] section]) {
//		if (section == [[tableView movingIndexPath] section]) {
//			numberOfRows++;
//		} else if (section == [[tableView initialIndexPathForMovingRow] section]) {
//			numberOfRows--;
//		}
//	}
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else if (section == 1) {
        return 6;
    }
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [FNAppearance tableViewBackgroundColor];
    return header;
}

- (UITableViewCell *)configureNumberOfTeamsCellForIndexPath:(NSIndexPath *)indexPath
{
    FNStepperCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"stepper"];
    [self setBackgroundForCell:cell atIndexPath:indexPath];
    cell.stepper.autorepeat = NO;
    cell.stepper.wraps = YES;
    cell.stepper.maximumValue = MIN(6, [self.brain.allPlayers count]);
    cell.stepper.value = [self.brain.allTeams count];
    [cell.stepper addTarget:self action:@selector(stepperDidStep:) forControlEvents:UIControlEventTouchUpInside];
    [cell.detailButtonLabel setBackgroundImage:[FNAppearance backgroundForTextField] forState:UIControlStateNormal];
    cell.detailButtonLabel.titleLabel.text = [NSString stringWithFormat:@"%d", [self.brain.allTeams count]];
    return cell;
}

- (UITableViewCell *)configureTeamReorderCellForIndexPath:(NSIndexPath *)indexPath
{
    FNReorderableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"reorderable"];
    FNTeam *team = [self.brain.allTeams objectAtIndex:indexPath.section - 1];
    [self setBackgroundForCell:cell atIndexPath:indexPath];
    [cell.button setImage:[FNAppearance reorderControlImage] forState:UIControlStateNormal];
    cell.mainTextLabel.text = team.name;
    // Moving Table View Methods
    cell.shouldIndentWhileEditing = NO;
    cell.showsReorderControl = NO;
    [cell.button setHidden:NO];
    if ([(FMMoveTableView *)self.tableView indexPathIsMovingIndexPath:indexPath]) {
        [cell prepareForMove];
    }
    cell.showCellSeparator = YES;
    return cell;
}

- (UITableViewCell *)configureNameCellForIndexPath:(NSIndexPath *)indexPath
{
    FNEditableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TEXT_FIELD];
    FNTeam *team = [self.brain.allTeams objectAtIndex:indexPath.section - 1];
    [self setBackgroundForCell:cell atIndexPath:indexPath];
    [self setBackgroundForTextField:cell.detailTextField];
    cell.detailTextField.delegate = self;
    cell.detailTextField.tag = indexPath.section -1;
    cell.mainTextLabel.text = @"name:";
    cell.detailTextField.text = team.name;
    cell.showCellSeparator = NO;
    cell.indentationLevel = 3;
    return cell;
}

- (UITableViewCell *)configurePlayerCellForIndexPath:(NSIndexPath *)indexPath
{
    FNSelectableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"selectable"];
    FNTeam *team = [self.brain.allTeams objectAtIndex:indexPath.section - 1];
    [self setBackgroundForCell:cell atIndexPath:indexPath];
    [cell.button addTarget:self action:@selector(playerAssignmentIndicatorPressed:) forControlEvents:UIControlEventTouchUpInside];
    FNPlayer *player = [self playerForIndexPath:indexPath];
    cell.objectForCell = player;
    if (player.team == team) {
        [cell.button setImage:[FNAppearance checkmarkWithStyle:FNCheckmarkStyleUser] forState:UIControlStateNormal];
    } else if ([team.players containsObject:player]) {
        [cell.button setImage:[FNAppearance checkmarkWithStyle:FNCheckmarkStyleGame] forState:UIControlStateNormal];
    } else {
        [cell.button setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    }
    cell.mainTextLabel.text = player.name;
    if (indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section] - 1) {
        cell.showCellSeparator = YES;
    } else {
        cell.showCellSeparator = NO;
    }
    cell.indentationLevel = 3;
    return cell;
}

- (FNTeamCellType)cellTypeForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return FNTeamCellTypeNumberOfTeams;
    } else {
        if (indexPath.row == 0) {
            return FNTeamCellTypeReorder;
        } else if (indexPath.row == 1) {
            return FNTeamCellTypeName;
        } else {
            return FNTeamCellTypePlayer;
        }
    }
}

- (void)setBackgroundForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:cell.frame];
    NSInteger numberOfSections = [self.tableView numberOfSections];
    NSInteger section = indexPath.section;
    NSInteger rowsInSection = [self.tableView numberOfRowsInSection:section];
    NSInteger row = indexPath.row;
    
    if ([self cellTypeForIndexPath:indexPath] == FNTeamCellTypeNumberOfTeams) {
        backgroundView.image = [FNAppearance cellBackgroundForPosition:FNTableViewCellPositionNone];
    } else if ([self cellTypeForIndexPath:indexPath] == FNTeamCellTypeReorder) {
        if (section == 1 && numberOfSections == 2 && rowsInSection == 1) {
            backgroundView.image = [FNAppearance cellBackgroundForPosition:FNTableViewCellPositionNone];
        } else if (section == 1) {
            backgroundView.image = [FNAppearance cellBackgroundForPosition:FNTableViewCellPositionTop];
        } else if (numberOfSections > 2 && rowsInSection == 1) {
            backgroundView.image = [FNAppearance cellBackgroundForPosition:FNTableViewCellPositionBottom];
        } else {
            backgroundView.image = [FNAppearance cellBackgroundForPosition:FNTableViewCellPositionMiddle];
        }
    } else if (section == numberOfSections - 1 && row == rowsInSection - 1) {
        backgroundView.image = [FNAppearance cellBackgroundForPosition:FNTableViewCellPositionBottom];
    } else {
        backgroundView.image = [FNAppearance cellBackgroundForPosition:FNTableViewCellPositionMiddle];
    }
    cell.backgroundView = backgroundView;
}

- (UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self cellTypeForIndexPath:indexPath] == FNTeamCellTypeNumberOfTeams) {
        return [self configureNumberOfTeamsCellForIndexPath:indexPath];
    } else {
        if ([self cellTypeForIndexPath:indexPath] == FNTeamCellTypeReorder) {
            return [self configureTeamReorderCellForIndexPath:indexPath];
        } else if ([self cellTypeForIndexPath:indexPath] == FNTeamCellTypeName) {
            return [self configureNameCellForIndexPath:indexPath];
        } else {
            return [self configurePlayerCellForIndexPath:indexPath];
        }
    }
}

- (FNPlayer *)playerForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger playerIndex = indexPath.row - 2;
    FNPlayer *player;
    FNTeam *team = [self.brain.allTeams objectAtIndex:indexPath.section - 1];
    if ([team.players count] > playerIndex) {
        player = [team.players objectAtIndex:playerIndex];
    } else {
        player = [[self availablePlayersForTeam:team] objectAtIndex:playerIndex - [team.players count]];
    }
    return player;
}

- (NSArray *)availablePlayersForTeam:(FNTeam *)team
{
    NSMutableArray *allPlayers = self.brain.allPlayers;
    NSMutableArray *availablePlayers = [[NSMutableArray alloc] init];
    for (FNPlayer *player in allPlayers) {
        if (!player.team && ![team.players containsObject:player]) {
            [availablePlayers addObject:player];
        }
    }
    return [self configureDataSource:availablePlayers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.brain setTeamOrder:self.brain.allTeams];
    [super viewWillDisappear:animated];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"Content Offset: %f", self.tableView.contentOffset.y);
    NSLog(@"Origin: %f", self.tableView.bounds.origin.y);
    CGRect newFrame = CGRectMake(0, self.tableView.contentOffset.y, self.tableView.bounds.size.width, 44);
    self.stepperView.frame = newFrame;
}


- (void)viewWillLayoutSubviews
{
    CGRect newFrame = CGRectMake(0, self.tableView.contentOffset.y, self.tableView.bounds.size.width, 44);
    self.stepperView.frame = newFrame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Teams"];
    self.stepperView = [[FNStepperView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    [self.stepperView.stepper addTarget:self action:@selector(stepperDidStep:) forControlEvents:UIControlEventTouchUpInside];
    self.stepperView.title.text = @"Teams";
    [self.tableView addSubview:self.stepperView];
}

@end
