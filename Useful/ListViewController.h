//
//  ListViewController.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 8/8/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

enum ListViewLocation { TOP=1, BOTTOM=2 };
typedef enum ListViewLocation ListViewLocation;

enum ListViewDirection { UP=-1, DOWN=1 };
typedef enum ListViewDirection ListViewDirection;

@interface ListGroupHeadView : UIView;
@end

@protocol ListViewDelegate <NSObject>
@required
- (NSInteger) listStartIndex;
- (id) listItemForIndex:(NSInteger)index;
- (UIView*) listViewForItem:(id)item atIndex:(NSInteger)itemIndex withWidth:(CGFloat)width;
- (UIView*) listViewForGroupId:(id)groupId withItem:(id)item withWidth:(CGFloat)width;
- (id) listGroupIdForItem:(id)item;
- (void) listSelectItem:(id)item atIndex:(NSInteger)itemIndex;
@optional
- (void) listTopGroupViewDidMove:(CGRect)frame;
- (void) listTopGroupDidChange:(id)topGroupItem withDirection:(ListViewDirection)direction;
- (void) listSelectGroupWithId:(id)groupId withItem:(id)item;
@end


@interface ListViewController : ViewController <UIScrollViewDelegate>
@property UIScrollView* scrollView;
@property (weak) id<ListViewDelegate> delegate;
@property NSInteger topItemIndex;
@property NSInteger bottomItemIndex;
@property NSUInteger numberVisibleViews;
@property CGFloat previousContentOffsetY;
@property (readonly) id bottomGroupId;
@property (readonly) id topGroupId;
@property (readonly) id topGroupItem;
@property CGFloat topY;
@property CGFloat bottomY;
@property CGFloat width;
@property CGFloat groupHeadBoundary;
@property UIEdgeInsets groupMargins;
- (void) reloadDataWithStartIndex:(NSInteger)startIndex;
- (void) stopScrolling;
@end
