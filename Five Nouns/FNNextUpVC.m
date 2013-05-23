//
//  FNNextUpVC.m
//  Five Nouns
//
//  Created by Jill on 5/22/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNNextUpVC.h"

@interface FNNextUpVC ()
@property (nonatomic, weak) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *nextPlayerLabel;
@property (weak, nonatomic) IBOutlet UITableView *scoreView;
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;
@end

@implementation FNNextUpVC

#pragma mark - IB Actions

- (IBAction)startPressed:(UIButton *)sender
{
    
}


#pragma mark - View Controller Life Cycle

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
