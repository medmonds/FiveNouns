//
//  FNMultiplayerContainer.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/15/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNMultiplayerContainer.h"
#import "FNMultiPlayerVC.h"
#import "FNMultiplayerHostDelegate.h"
#import "FNButtonRect.h"

@interface FNMultiplayerContainer ()
@property (weak, nonatomic) IBOutlet FNButtonRect *multiplayerServerStateToggle;
@end


@implementation FNMultiplayerContainer


- (IBAction)toggleMultiplayerServerStatePressed:(UIButton *)sender
{
    if ([self.dataSource isMultiplayerEnabled]) {
        [self.dataSource userStopServingGame];
        [UIView animateWithDuration:.2 animations:^{
            self.multiplayerServerStateToggle.alpha = 0.2;
        } completion:^(BOOL finished) {
            [self.multiplayerServerStateToggle setTitle:@"Start Hosting Game" forState:UIControlStateNormal];
            [UIView animateWithDuration:.2 animations:^{
                self.multiplayerServerStateToggle.alpha = 1.0;
            }];
        }];
    } else {
        [self.dataSource userStartServingGame];
        [UIView animateWithDuration:.2 animations:^{
            self.multiplayerServerStateToggle.alpha = 0.2;
        } completion:^(BOOL finished) {
            [self.multiplayerServerStateToggle setTitle:@"Stop Hosting Game" forState:UIControlStateNormal];
            [UIView animateWithDuration:.2 animations:^{
                self.multiplayerServerStateToggle.alpha = 1.0;
            }];
        }];
    }
}

- (void)insertClientAtIndex:(NSInteger)index
{
    [((FNMultiPlayerVC *)self.childViewControllers[0]) insertClientAtIndex:index];
}

- (void)deleteClientAtIndex:(NSInteger)index
{
    [((FNMultiPlayerVC *)self.childViewControllers[0]) deleteClientAtIndex:index];
}

- (void)donePressed
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self.dataSource viewControllerWasDismissed:self];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((FNMultiPlayerVC *)segue.destinationViewController).dataSource = self.dataSource;
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
    UIView *navTitle = [FNAppearance navBarTitleWithText:@"Multiplayer" forOrientation:self.interfaceOrientation];
    // need to change the color too !!!
    [navTitle setUserInteractionEnabled:NO];
    self.navigationItem.titleView = navTitle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *navTitle = [FNAppearance navBarTitleWithText:@"Multiplayer" forOrientation:self.interfaceOrientation];
    // need to change the color too !!!
    [navTitle setUserInteractionEnabled:NO];
    self.navigationItem.titleView = navTitle;
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
    UIBarButtonItem *done = [FNAppearance barButtonItemDismiss];
    [done setTarget:self];
    [done setAction:@selector(donePressed)];
    [self.navigationItem setRightBarButtonItem:done];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.dataSource viewControllerWillAppear:self];
    if ([self.dataSource isMultiplayerEnabled]) {
        [self.multiplayerServerStateToggle setTitle:@"Stop Hosting Game" forState:UIControlStateNormal];
    } else {
        [self.multiplayerServerStateToggle setTitle:@"Start Hosting Game" forState:UIControlStateNormal];
    }
}


@end
