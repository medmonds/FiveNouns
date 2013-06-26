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

@protocol FNTVRowInsertAndDeleteManager <NSObject>

- (void)insertRowsAtIndexPaths:(NSArray *)indexpaths forController:(id <UITableViewDelegate>)controller;
- (void)deleteRowsAtIndexPaths:(NSArray *)indexpaths forController:(id <UITableViewDelegate>)controller;
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath forController:(id <UITableViewDelegate>)controller;

@end

@interface FNTVController : NSObject <UITableViewDataSource, UITableViewDelegate>

- (void)setup;
- (BOOL)showCellSeparatorForIndexPath:(NSIndexPath *)indexPath;


@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSArray *allData;
@property (nonatomic, strong) NSString *title;
// can I just assign the class to these two properties instead of instances of the classes
@property (nonatomic, strong) id subCategoryType;
@property (nonatomic, strong) id categoryType;


@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UITableViewController <FNTVRowInsertAndDeleteManager> *tvController;


/*
 should pass the object and the cell and then have the subclass configure it
 
 
 instead of subclassing this class I should create a delegate protocol that will be 
 assigned to this classes delegate and then that delegate should be responsible for 
 setting up the above properties (no it should answer the question behind the properties ex
 categoryfor: ) and configuring cells when passed the cell to configure
 and the data source for that cell no do this as a block like objc.io
 
 -(CellConfigBlock*)configBlockForHeader
 -(CellConfigBlock*)configBlockForCategory
 -(CellConfigBlock*)configBlockForSubCategory

 
 
 
*/

@end