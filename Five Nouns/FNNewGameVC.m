//
//  FNNewGameVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNNewGameVC.h"
#import "FNBrain.h"
#import "FNAddPlayersContainer.h"
#import "FNAppearance.h"
#import "FNMultiplayerManager.h"

@interface FNNewGameVC ()
@property (nonatomic, strong) FNMultiplayerManager *multiplayerManager;
@property (nonatomic, strong) FNBrain *brain;
@end

@implementation FNNewGameVC

- (IBAction)newGamePressed
{
    self.brain = [[FNBrain alloc] init];
    [self performSegueWithIdentifier:@"addPlayers" sender:self];
}

- (IBAction)resumeGamePressed
{
    self.brain = [FNBrain brainFromPreviousGame];
    [self performSegueWithIdentifier:@"addPlayers" sender:self];
}

- (IBAction)instructionsPressed
{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addPlayers"]) {
        ((FNAddPlayersContainer *)segue.destinationViewController).brain = self.brain;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
    // I will want the same manager when I quite the game & Come back to tthis screen so Need to deal with that !!!
    self.multiplayerManager = [FNMultiplayerManager sharedMultiplayerManager];
    self.multiplayerManager.hostViewController = self;
    // add this manager to the brain when it is created and then add a pointer to the brain to the currently displayed vc so it can present views when necessary
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.multiplayerManager authenticateLocalPlayer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
