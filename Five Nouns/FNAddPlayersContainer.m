//
//  FNAddPlayersContainer.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/11/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNAddPlayersContainer.h"
#import "FNAssignTeamsContainer.h"
#import "FNAddPlayersVC.h"
#import "FNBrain.h"

@interface FNAddPlayersContainer ()

@end

@implementation FNAddPlayersContainer


- (void)forwardBarButtonItemPressed
{
    if ([self.brain.allPlayers count] > 1) {
        [self performSegueWithIdentifier:@"teamsOverview" sender:self];
    } else {
        [self displayInvalidPlayerCountAlert];
    }
}

- (void)displayInvalidPlayerCountAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Enough Players"
                                                    message:@"You must add at least two players before proceeding."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((FNAssignTeamsContainer *)segue.destinationViewController).brain = self.brain;
}

- (IBAction)addPlayerPressed:(UIButton *)sender
{
    [((FNAddPlayersVC *)self).childViewControllers[0] addPlayer];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Players" forOrientation:toInterfaceOrientation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Players" forOrientation:self.interfaceOrientation];
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
    UIBarButtonItem *back = [FNAppearance backBarButtonItem];
    [back setTarget:self.navigationController];
    [back setAction:@selector(popViewControllerAnimated:)];
    [self.navigationItem setLeftBarButtonItem:back];
    UIBarButtonItem *forward = [FNAppearance forwardBarButtonItem];
    [forward setTarget:self];
    [forward setAction:@selector(forwardBarButtonItemPressed)];
    [self.navigationItem setRightBarButtonItem:forward];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
