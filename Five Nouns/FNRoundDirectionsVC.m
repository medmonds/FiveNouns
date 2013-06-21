//
//  FNRoundDirectionsVC.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/2/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNRoundDirectionsVC.h"
#import "FNAppearance.h"
#import "FNBrain.h"

@interface FNRoundDirectionsVC ()
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;
@property (weak, nonatomic) IBOutlet UITextView *directionsTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;
@end

@implementation FNRoundDirectionsVC

- (void)donePressed
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setDirectionsForRound
{
    [self configureDirectionsView];
    [self configureRoundLabel];
}

- (void)configureDirectionsView
{
    NSString *directions = [self.brain directionsForRound:self.round];
    CGSize textViewWidth = CGSizeMake(self.view.frame.size.width - 20, 420);
    CGSize textSize = [directions sizeWithFont:self.directionsTextView.font
                             constrainedToSize:textViewWidth
                                 lineBreakMode:NSLineBreakByWordWrapping];
    textSize.height = textSize.height + 15;
    CGRect textViewFrame = CGRectMake(10, 60, textViewWidth.width, textSize.height);
    self.textViewHeight.constant = textSize.height;
    self.directionsTextView.frame = textViewFrame;
    self.directionsTextView.text = directions;
}

- (void)configureRoundLabel
{
    NSString *partial = @"Round ";
    if (self.round == 1) {
        partial = [partial stringByAppendingString:@"One"];
    } else if (self.round == 2) {
        partial = [partial stringByAppendingString:@"Two"];
    } else if (self.round == 3) {
        partial = [partial stringByAppendingString:@"Three"];
    } else {
        partial = [partial stringByAppendingString:@"Four"];
    }
    self.roundLabel.text = partial;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setDirectionsForRound];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [FNAppearance tableViewBackgroundColor];
    UIBarButtonItem *done = [FNAppearance barButtonItemDismiss];
    [done setTarget:self];
    [done setAction:@selector(donePressed)];
    [self.navigationItem setRightBarButtonItem:done];
    self.navigationItem.titleView = [FNAppearance navBarTitleWithText:@"Directions"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
