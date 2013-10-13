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
#import "FNNetworkManager.h"

@interface FNNewGameVC ()
@property (nonatomic, strong) FNBrain *brain;
@end

@implementation FNNewGameVC

- (IBAction)newGamePressed
{
    self.brain = [[FNBrain alloc] init];
    self.brain.navController = self.navigationController;
    [[FNNetworkManager sharedNetworkManager] startServingGame];
    [self performSegueWithIdentifier:@"addPlayers" sender:self];
}

// this should automatically happen when launched if the last game was not finished
//- (IBAction)resumeGamePressed
//{
//    self.brain = [FNBrain brainFromPreviousGame];
//    [self performSegueWithIdentifier:@"addPlayers" sender:self];
//}

- (IBAction)instructionsPressed
{
    // get the NetworkManager and tell it to present the joinVC
    // when a game is joined then this should segue to the appropriate VC
    // if the view is cancelled (donePressed) then just return to the main menu
}

- (IBAction)joinGamePressed:(id)sender
{
    if (!self.brain) {
        self.brain = [[FNBrain alloc] init];
        self.brain.navController = self.navigationController;
    }
    UIViewController *joinVC = [[FNNetworkManager sharedNetworkManager] joinViewController];
    [self.navigationController pushViewController:joinVC animated:YES];
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
    // add this manager to the brain when it is created and then add a pointer to the brain to the currently displayed vc so it can present views when necessary
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.navigationController setNavigationBarHidden:YES];
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
