//
//  FNEditableCell.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 4/13/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNSeparatorCell.h"
#import "SSTextField.h"


@interface FNEditableCell : FNSeparatorCell

@property (weak, nonatomic) IBOutlet UILabel *mainTextLabel;
@property (weak, nonatomic) IBOutlet SSTextField *detailTextField;

@end
