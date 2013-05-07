//
//  FNStepperCell.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 5/5/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FNStepperCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mainTextLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@property (weak, nonatomic) IBOutlet UIButton *detailButtonLabel;

@end
