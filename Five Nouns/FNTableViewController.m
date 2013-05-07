//
//  FNTableViewController.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/24/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNTableViewController.h"
#import "FNAppearance.h"

@interface FNTableViewController ()

@end

@implementation FNTableViewController

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO; // otherwise enters a return
}

#pragma mark - Appearance Customization

- (void)setBackgroundForCell:(UITableViewCell *)cell Style:(FNTableViewCellStyle)style atIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:cell.frame];
    NSInteger sectionRows = [self.tableView numberOfRowsInSection:indexPath.section];
    NSInteger row = indexPath.row;
    if (row == 0 && row == sectionRows - 1)
    {
        backgroundView.image = [FNAppearance backgroundForCellWithStyle:style forPosition:FNTableViewCellPositionNone];
    }
    else if (row == 0)
    {
        backgroundView.image = [FNAppearance backgroundForCellWithStyle:style forPosition:FNTableViewCellPositionTop];
    }
    else if (row == sectionRows - 1)
    {
        backgroundView.image = [FNAppearance backgroundForCellWithStyle:style forPosition:FNTableViewCellPositionBottom];
    }
    else
    {
        backgroundView.image = [FNAppearance backgroundForCellWithStyle:style forPosition:FNTableViewCellPositionMiddle];
    }
    cell.backgroundView = backgroundView;
}

- (void)setBackgroundForTextField:(UITextField *)textField
{
    CGRect frame = textField.frame;
    frame.size.height = 35;
    textField.frame = frame;
    UIImage *background = [FNAppearance backgroundForTextField];
    textField.backgroundColor = [UIColor clearColor];
    textField.borderStyle = UITextBorderStyleNone;
    textField.background = background;
}

#pragma mark - View Controller Life Cycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [FNAppearance tableViewBackgroundColor];
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
