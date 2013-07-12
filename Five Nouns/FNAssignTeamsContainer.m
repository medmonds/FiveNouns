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

- (void)forwardBarButtonItemPressed
{
    if ([self.brain.allTeams count] > 0) {
        [self performSegueWithIdentifier:@"nextUp" sender:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Teams"];
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
}

@end
