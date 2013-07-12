//
//  FNStepperView.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 7/9/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FNStepperView : UIView

@property (nonatomic) NSInteger maxTeams;
@property UIStepper *stepper;
@property UILabel *title;

- (void)setCurrentNumber:(NSInteger)number;

@end
