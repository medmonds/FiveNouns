//
//  FNTVController.h
//  Five Nouns
//
//  Created by Matthew Edmonds on 6/25/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FNBrain;
@class FNTVController;

@protocol FNTVRowInsertAndDeleteManager <NSObject>

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths forController:(id <UITableViewDelegate>)controller;
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths forController:(id <UITableViewDelegate>)controller;
//- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths forController:(FNTVController *)controller;
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath forController:(id <UITableViewDelegate>)controller;

@end

///////////////////////////////////////////////////////////////

@protocol FNTVControllerDelegate <NSObject>

typedef void (^CellConfigBlock)(id, id);

// configure these properties. wait these should be on the FNTVScoreDelegate not the protocol !!! maybe
@optional
@property (nonatomic, strong) FNBrain *brain;
- (CGFloat)heightForCell:(UITableViewCell *)cell withItem:(id)item;
- (NSString *)cellIdentifierForCategory;
- (NSString *)cellIdentifierForItem;
@required
@property (nonatomic) BOOL shouldCollapseOnTitleTap;
// it answers these questions
- (NSArray *)categories;
- (NSString *)title;
- (NSArray *)itemsForCategory:(id)category;
- (CellConfigBlock)titleCellConfigureBlockForController:(FNTVController *)controller;
- (CellConfigBlock)categoryCellConfigureBlockForController:(FNTVController *)controller;
- (CellConfigBlock)itemCellConfigureBlockForController:(FNTVController *)controller;
@end

////////////////////////////////////////////////////////////////

@interface FNTVController : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UITableViewController <FNTVRowInsertAndDeleteManager> *tvController;
@property (nonatomic, strong) id <FNTVControllerDelegate> delegate;

- (void)setup;

@end