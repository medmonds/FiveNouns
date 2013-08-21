//
//  FNAssignTeamsContainer.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/11/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNAssignTeamsContainer.h"
#import "FNAssignTeamsVC.h"
#import "FNStepperView.h"
#import "FNBrain.h"
#import "FNNextUpVC.h"

@interface FNAssignTeamsContainer ()
@property (weak, nonatomic) IBOutlet FNStepperView *stepperView;
@end

@implementation FNAssignTeamsContainer

- (void)setBrain:(FNBrain *)brain
{
    _brain = brain;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"nextUp"]) {
        ((FNNextUpVC *)segue.destinationViewController).brain = self.brain;
    } else {
        ((FNAssignTeamsVC *)segue.destinationViewController).brain = self.brain;
    }
}

- (void)displayInvalidTeamsAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unassigned players"
                                                    message:@"You must assign all players to teams before proceeding."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)forwardBarButtonItemPressed
{
    if ([self.brain.allTeams count] && [self.brain allPlayersAssignedToTeams]) {
        [self performSegueWithIdentifier:@"nextUp" sender:self];
    } else {
        [self displayInvalidTeamsAlert];
    }
}

- (void)setStepperMaxValue:(NSInteger)maxValue
{
    self.stepperView.maxTeams = maxValue;
}

- (void)setStepperValue:(NSInteger)value
{
    [self.stepperView setCurrentNumber:value];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Players" forOrientation:toInterfaceOrientation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Teams" forOrientation:self.interfaceOrientation];
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
    UIBarButtonItem *back = [FNAppearance backBarButtonItem];
    [back setTarget:self.navigationController];
    [back setAction:@selector(popViewControllerAnimated:)];
    [self.navigationItem setLeftBarButtonItem:back];
    UIBarButtonItem *forward = [FNAppearance forwardBarButtonItem];
    [forward setTarget:self];
    [forward setAction:@selector(forwardBarButtonItemPressed)];
    [self.navigationItem setRightBarButtonItem:forward];

    [self.stepperView.stepper addTarget:((FNAssignTeamsVC *)self).childViewControllers[0] action:@selector(stepperDidStep:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.stepperView.stepper.maximumValue = MIN(6, [self.brain.allPlayers count]);
    [self.stepperView setCurrentNumber:[self.brain.allTeams count]];
    [self.brain setGameStatus:FNGameStatusNotStarted];
}

@end
