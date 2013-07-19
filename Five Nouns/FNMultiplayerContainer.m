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

@interface FNMultiplayerContainer ()

@end


@implementation FNMultiplayerContainer

- (IBAction)stopHostingGamePressed:(id)sender
{
    [self.dataSource stopHostingGame];
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
        [self.dataSource viewControllerWasDismissed];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    FNMultiPlayerVC *childVC = self.childViewControllers[0];
    childVC.dataSource = self.dataSource;
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
    UIView *navTitle = [FNAppearance navBarTitleWithText:@"Connected Players" forOrientation:self.interfaceOrientation];
    // need to change the color too !!!
    [navTitle setUserInteractionEnabled:NO];
    self.navigationItem.titleView = navTitle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *navTitle = [FNAppearance navBarTitleWithText:@"Connected Players" forOrientation:self.interfaceOrientation];
    // need to change the color too !!!
    [navTitle setUserInteractionEnabled:NO];
    self.navigationItem.titleView = navTitle;
    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
    UIBarButtonItem *done = [FNAppearance barButtonItemDismiss];
    [done setTarget:self];
    [done setAction:@selector(donePressed)];
    [self.navigationItem setRightBarButtonItem:done];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
