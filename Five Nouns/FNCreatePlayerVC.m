//
//  FNCreatePlayerVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNCreatePlayerVC.h"
#import "FNEditableCell.h"
#import "FNPlayer.h"

@interface FNCreatePlayerVC ()

@end

@implementation FNCreatePlayerVC

- (IBAction)savePressed:(UIBarButtonItem *)sender
{
    // validate the input and proceed or reject with error message
    FNPlayer *newPlayer = [self newPlayerIsValid];
    if (newPlayer) {
        [self.delegate infoFromPresentedModal:@[newPlayer]];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Save Player" message:@"New Player's must have a name and at least three nouns." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (FNPlayer *)newPlayerIsValid
{
    // validates that a new player was created properly
    FNEditableCell *nameCell = (FNEditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *name = nameCell.detailTextField.text;
    
    NSMutableArray *nouns = [[NSMutableArray alloc] init];
    int possibleNouns = [self.tableView numberOfRowsInSection:1];
    for (int i = 0; i < possibleNouns; i++) {
        FNEditableCell *nounCell = (FNEditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        NSString *noun = nounCell.detailTextField.text;
        if ([noun length] > 0) {
            [nouns addObject:noun];
        }
    }
    FNPlayer *newPlayer = nil;
    if ([name length] > 0 && [nouns count] > 2) {
        newPlayer = [[FNPlayer alloc] init];
        newPlayer.name = name;
        newPlayer.nouns = nouns;
    }
    return newPlayer;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        // the number of nouns
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"editableCell";
    FNEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.mainTextLabel.text = @"Name:";
    } else {
        cell.mainTextLabel.text = [NSString stringWithFormat:@"Noun %d:", indexPath.row + 1];
    }
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
