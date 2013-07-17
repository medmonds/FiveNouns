//
//  FNMultiPlayerVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/15/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNMultiPlayerVC.h"

@interface FNMultiPlayerVC ()
@property (nonatomic) BOOL localPlayersAreVisible;
@end

@implementation FNMultiPlayerVC

@synthesize localPlayers = _localPlayers;
@synthesize connectedPlayers = _connectedPlayers;

- (NSMutableArray *)localPlayers
{
    if (!_localPlayers) {
        _localPlayers = [[NSMutableArray alloc] init];
    }
    return _localPlayers;
}

- (NSMutableArray *)connectedPlayers
{
    if (!_connectedPlayers) {
        _connectedPlayers = [[NSMutableArray alloc] init];
    }
    return _connectedPlayers;
}

- (void)showLocalPlayersPressed
{
    
}

- (void)insertLocalPlayer:(GKPlayer *)player
{
    // just for testing !!!
    [self.localPlayers addObject:player];
    [self.tableView reloadData];
}

- (void)deleteLocalPlayer:(GKPlayer *)player
{
    // just for testing !!!
    [self.localPlayers removeObject:player];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

// should this be in didSelectRowAtIndexPath not shouldSelect? !!!
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    // make the textfield (if cell has a textfield) the first responder
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[FNEditableCell class]]) {
        FNEditableCell *textFieldCell = cell;
        [textFieldCell.detailTextField becomeFirstResponder];
    }
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.localPlayersAreVisible) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.localPlayersAreVisible) {
            return [self.localPlayers count];
        } else {
            return [self.localPlayers count];
        }
    }
    return [self.connectedPlayers count];
}

- (UITableViewCell *)configureNameCellForIndexPath:(NSIndexPath *)indexPath
{
    FNEditableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TEXT_FIELD];
    cell.mainTextLabel.text = @"name:";
    cell.detailTextField.tag = indexPath.row - 1;
    cell.detailTextField.placeholder = @"New Player";
    cell.detailTextField.placeholderTextColor = [FNAppearance textColorButton];
    cell.detailTextField.delegate = self;
    [self setBackgroundForTextField:cell.detailTextField];
    cell.showCellSeparator = NO;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [self configureNameCellForIndexPath:indexPath];
    }
    return cell;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // just for testing !!!
    self.localPlayersAreVisible = YES;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
