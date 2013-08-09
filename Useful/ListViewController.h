//
//  ListViewController.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 8/8/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunAll.h"

enum ListViewLocation { TOP=1, BOTTOM=2 };
typedef enum ListViewLocation ListViewLocation;


@protocol ListViewDelegate <NSObject>
@required
- (NSInteger) startAtIndex;
- (id)itemForIndex:(NSInteger)index;
- (UIView*) viewForItem:(id)item;
- (id) groupForItem:(id)item;
//- (void)renderItem:(id)item inCell:(UITableViewCell*)cell width:(CGFloat)width height:(CGFloat)height;
//- (void)renderHeader:(NSInteger)section inView:(UIView*)view width:(CGFloat)width height:(CGFloat)height;
//- (CGFloat)heightForItem:(id)item width:(CGFloat)width;
//- (CGFloat)heightForHeader:(NSUInteger)index;
//- (NSArray*)loadItems;
//- (NSArray*)loadSectionCounts;
//- (void)selectItem:(id)item cell:(UITableViewCell*)cell;
//- (BOOL)shouldHighlightItem:(id)item;
@end


@interface ListViewController : ViewController <UIScrollViewDelegate>
@property UIScrollView* scrollView;
@property (weak) id<ListViewDelegate> delegate;
@property NSInteger topItemIndex;
@property NSInteger bottomItemIndex;
@property CGFloat previousContentOffsetY;
@property (readonly) UIView* topView;
@property (readonly) UIView* bottomView;
@end
