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
- (void) selectItem:(id)item;
@end


@interface ListViewController : ViewController <UIScrollViewDelegate>
@property UIScrollView* scrollView;
@property (weak) id<ListViewDelegate> delegate;
@property NSInteger topItemIndex;
@property NSInteger bottomItemIndex;
@property CGFloat previousContentOffsetY;
@property (readonly) UIView* topView;
@property (readonly) UIView* bottomView;
- (void) stopScrolling;
@end
