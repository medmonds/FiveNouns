//
//  FNNetworkContainer.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/15/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNNetworkContainer.h"
#import "FNNetworkVC.h"
#import "FNButtonRect.h"

@interface FNNetworkContainer ()
@property (weak, nonatomic) IBOutlet FNButtonRect *NetworkServerStateToggle;
@end


@implementation FNNetworkContainer


- (IBAction)toggleNetworkServerStatePressed:(UIButton *)sender
{
    if ([self.dataSource isNetworkEnabled]) {
        [self.dataSource turnOffNetwork];
        [UIView animateWithDuration:.2 animations:^{
            self.NetworkServerStateToggle.alpha = 0.2;
        } completion:^(BOOL finished) {
            [self.NetworkServerStateToggle setTitle:@"Start Hosting Game" forState:UIControlStateNormal];
            [UIView animateWithDuration:.2 animations:^{
                self.NetworkServerStateToggle.alpha = 1.0;
            }];
        }];
    } else {
        [self.dataSource turnOnNetwork];
        [UIView animateWithDuration:.2 animations:^{
            self.NetworkServerStateToggle.alpha = 0.2;
        } completion:^(BOOL finished) {
            [self.NetworkServerStateToggle setTitle:@"Stop Hosting Game" forState:UIControlStateNormal];
            [UIView animateWithDuration:.2 animations:^{
                self.NetworkServerStateToggle.alpha = 1.0;
            }];
        }];
    }
}

- (void)insertPeerAtIndex:(NSInteger)index
{
    [((FNNetworkVC *)self.childViewControllers[0]) insertClientAtIndex:index];
}

- (void)deletePeerAtIndex:(NSInteger)index
{
    [((FNNetworkVC *)self.childViewControllers[0]) deleteClientAtIndex:index];
}

- (void)donePressed
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self.dataSource viewControllerWasDismissed:self];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((FNNetworkVC *)segue.destinationViewController).dataSource = self.dataSource;
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
    if ([self.dataSource isNetworkEnabled]) {
        [self.NetworkServerStateToggle setTitle:@"Stop Hosting Game" forState:UIControlStateNormal];
    } else {
        [self.NetworkServerStateToggle setTitle:@"Start Hosting Game" forState:UIControlStateNormal];
    }
}


@end
