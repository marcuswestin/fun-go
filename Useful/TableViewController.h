//
//  TableViewController.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/1/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "ViewController.h"

@protocol TableViewDelegate <NSObject>
@required
- (void)renderItem:(id)item inCell:(UITableViewCell*)cell width:(NSUInteger)width height:(NSUInteger)height;
- (void)renderHeader:(NSInteger)section inView:(UIView*)view width:(NSUInteger)width height:(NSUInteger)height;
- (NSUInteger)heightForItem:(id)item width:(NSUInteger)width;
- (NSUInteger)heightForHeader:(NSUInteger)index;
- (NSArray*)loadItems;
- (NSArray*)loadSectionCounts;
- (void)selectItem:(id)item cell:(UITableViewCell*)cell;
- (BOOL)shouldHighlightItem:(id)item;
@end

typedef void (^ForEachIndexBlock)(NSUInteger rowIndex);

@interface TableViewController : ViewController <UITableViewDataSource, UITableViewDelegate>
@property UITableView* tableView;
@property NSUInteger sectionCount;
@property NSUInteger* rowCountsPerSection;
@property NSUInteger* rowCountsBeforeSection;
@property NSUInteger* rowHeights;
@property NSUInteger* headerHeights;
@property NSArray* items;
@property NSObject<TableViewDelegate>* delegate;

- (NSUInteger)indexForPath:(NSIndexPath*)indexPath;
- (void)forEachRowIndexInSection:(NSUInteger)section block:(ForEachIndexBlock)block;
- (id)firstItemInSection:(NSUInteger)section;
- (id)lastItemInSection:(NSUInteger)section;

- (id)itemForPath:(NSIndexPath*)indexPath;
- (void)scrollToBottomAnimated:(BOOL)animated;

@end
