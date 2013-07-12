//
//  FNTableViewController.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/24/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNTableViewController.h"

@interface FNTableViewController ()
@property (nonatomic, strong) UIImage *none;
@property (nonatomic, strong) UIImage *top;
@property (nonatomic, strong) UIImage *bottom;
@property (nonatomic, strong) UIImage *middle;
@end

@implementation FNTableViewController

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO; // otherwise enters a return
}

#pragma mark - Appearance Customization

- (void)setBackgroundForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
{
    if (![cell.backgroundView isKindOfClass:[UIImageView class]]) {
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:cell.frame];
        cell.backgroundView = backgroundView;
    }
    NSInteger sectionRows = [self.tableView numberOfRowsInSection:indexPath.section];
    NSInteger row = indexPath.row;
    if (row == 0 && row == sectionRows - 1) {
        if (!self.none) self.none = [FNAppearance cellBackgroundForPosition:FNTableViewCellPositionNone];
        if (((UIImageView *)cell.backgroundView).image != self.none) {
            ((UIImageView *)cell.backgroundView).image = self.none;
        }
    } else if (row == 0) {
        if (!self.top) self.top = [FNAppearance cellBackgroundForPosition:FNTableViewCellPositionTop];
        if (((UIImageView *)cell.backgroundView).image != self.top) {
            ((UIImageView *)cell.backgroundView).image = self.top;
        }
    } else if (row == sectionRows - 1) {
        if (!self.bottom) self.bottom = [FNAppearance cellBackgroundForPosition:FNTableViewCellPositionBottom];
        if (((UIImageView *)cell.backgroundView).image != self.bottom) {
            ((UIImageView *)cell.backgroundView).image = self.bottom;
        }
    } else {
        if (!self.middle) self.middle = [FNAppearance cellBackgroundForPosition:FNTableViewCellPositionMiddle];
        if (((UIImageView *)cell.backgroundView).image != self.middle) {
            ((UIImageView *)cell.backgroundView).image = self.middle;
        }
    }
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

#pragma mark - Table View Headers
// to pad between the sections

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 6;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [FNAppearance tableViewBackgroundColor];
    return header;
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
