//
//  ListViewController.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 8/8/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "ListViewController.h"

static CGFloat MAX_Y = 9999999.0f;
static CGFloat START_Y = 99999.0f;

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.delegate) { self.delegate = (id<ListViewDelegate>)self; }
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = RED;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.view.width, MAX_Y);
    self.scrollView.contentOffset = CGPointMake(0, START_Y);
    self.previousContentOffsetY = self.scrollView.contentOffset.y;
    
    NSInteger index = self.delegate.startAtIndex;
    self.topItemIndex = index;
    self.bottomItemIndex = index;

    [self _renderFirstItem];
    [self _extendBottom];
    [self.view addSubview:self.scrollView];
    
    self.scrollView.delegate = self;
}

- (void) _renderFirstItem {
    [self.scrollView empty];
    id item = [self.delegate itemForIndex:self.topItemIndex];
    UIView* view = [self.delegate viewForItem:item];
    [view moveToPosition:self.scrollView.contentOffset];
    [self.scrollView addSubview:view];
}

- (void)_extendBottom {
    CGFloat targetY = self.scrollView.contentOffset.y + self.scrollView.height;
    CGFloat bottomY = CGRectGetMaxY(self.bottomView.frame);
    while (bottomY < targetY) {
        id item = [self.delegate itemForIndex:self.bottomItemIndex + 1];
        if (!item) {
            [self _didReachEnd];
            break;
        }
        UIView* view = [self.delegate viewForItem:item];
        [view moveToY:bottomY];
        bottomY += view.height;
        [self.scrollView insertSubview:view atIndex:self.scrollView.subviews.count];
        self.bottomItemIndex += 1;
    }
    [self _cleanupTop];
}

- (void)_cleanupTop {
    CGFloat targetY = self.scrollView.contentOffset.y;
    while (CGRectGetMaxY(self.topView.frame) < targetY) {
        [self.topView removeFromSuperview];
        self.topItemIndex += 1;
    }
}

- (void)_extendTop {
    CGFloat targetY = self.scrollView.contentOffset.y;
    CGFloat topY = CGRectGetMinY(self.topView.frame);
    while (topY > targetY) {
        id item = [self.delegate itemForIndex:self.topItemIndex - 1];
        if (!item) {
            [self _didReachBeginning];
            break;
        }
        UIView* view = [self.delegate viewForItem:item];
        topY -= view.height;
        [view moveToY:topY];
        [self.scrollView insertSubview:view atIndex:0];
        self.topItemIndex -= 1;
    }
    [self _cleanupBottom];
}

- (void) _cleanupBottom {
    CGFloat targetY = self.scrollView.contentOffset.y + self.scrollView.height;
    while (CGRectGetMinY(self.bottomView.frame) > targetY) {
        [self.bottomView removeFromSuperview];
        self.bottomItemIndex -= 1;
    }
}

- (void)_didReachEnd {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width, CGRectGetMaxY(self.bottomView.frame));
}

- (void)_didReachBeginning {
    if (self.scrollView.contentOffset.y <= 0) { return; }
    CGFloat changeInHeight = CGRectGetMinY(self.topView.frame);

    // We don't want to fire another scroll event,
    // so remove ourselves as delegate while the swap is made
    self.scrollView.delegate = nil;
    self.scrollView.contentOffset = CGPointZero;
    self.scrollView.delegate = self;
    
    for (UIView* subView in self.scrollView.subviews) {
        [subView moveByY:-changeInHeight];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (contentOffsetY == self.previousContentOffsetY) {
        return;
    }
    if (contentOffsetY > self.previousContentOffsetY) {
        [self _extendBottom];
    } else {
        [self _extendTop];
    }
    self.previousContentOffsetY = scrollView.contentOffset.y;
}

//- (void)_checkVisibleViews {
//    CGFloat targetTop = self.scrollView.contentOffset.y;
//    CGFloat targetBottom = targetTop + self.scrollView.height;
//    // Remove views that are out-of-bound
//    CGFloat topViewBottomY = CGRectGetMinY(self.topView.frame);
//    while (topViewBottomY > targetTop) {
//        [topView removeFromSuperview];
//        topViewbottomY = self.topView;
//    }
//    CGFloat bottomY = CGRectGetMaxY(self.bottomView.frame);
//    while (bottomView && CGRectGetMinY(bottomView.frame) > targetBottom) {
//        [bottomView removeFromSuperview];
//        bottomView = self.bottomView;
//    }
//    // Render views to fill visible space
//    while (topView && CGRectGetMinY(topView.frame) > targetTop) {
//        id item = [self.delegate itemForIndex:self.topItemIndex - 1];
//        if (!item) {
//            break;
//        }
//        topView = [self _addItemTo:TOP];
//    }
//    while (bottomView && CGRectGetMaxY(bottomView.frame) < targetBottom) {
//        id item = [self.delegate itemForIndex:self.bottomItemIndex + 1];
//        if (!item) {
//        }
//        bottomView = [self _addItemTo:BOTTOM];
//    }
//}

- (UIView*)topView {
    return self.scrollView.subviews.firstObject;
}

- (UIView*)bottomView {
    return self.scrollView.subviews.lastObject;
}

@end
