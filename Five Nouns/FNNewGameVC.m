//
//  FNNewGameVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNNewGameVC.h"
#import "FNBrain.h"
#import "FNAddPlayersVC.h"

@interface FNNewGameVC ()
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
    
}

- (IBAction)instructionsPressed
{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addPlayers"]) {
        FNAddPlayersVC *vc = segue.destinationViewController;
        vc.brain = self.brain;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:104/255.0 green:204/255.0 blue:197/255.0 alpha:1];
    
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
