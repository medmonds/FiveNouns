//
//  FNCreateTeamVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNCreateTeamVC.h"
#import "FNEditableCell.h"
#import "FNTeam.h"
@interface FNCreateTeamVC ()

@end

@implementation FNCreateTeamVC

- (IBAction)savePressed:(UIBarButtonItem *)sender
{
    // validate the input and proceed or reject with error message
    FNTeam *newTeam = [self newTeamIsValid];
    if (newTeam) {
        [self.delegate infoFromPresentedModal:@[newTeam]];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Save Team" message:@"Enter a team name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (FNTeam *)newTeamIsValid
{
    // validates that a new player was created properly
    FNEditableCell *nameCell = (FNEditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *name = nameCell.detailTextField.text;
    FNTeam *newTeam = nil;
    if ([name length] > 0) {
        newTeam = [[FNTeam alloc] init];
        newTeam.name = name;
    }
    return newTeam;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"editableCell";
    FNEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.mainTextLabel.text = @"Name:";
    return cell;
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    FNEditableCell *cell = (FNEditableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.detailTextField becomeFirstResponder];
    return NO;
}

@end
