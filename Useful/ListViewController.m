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
    self.width = self.view.width;
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = RED;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.width, MAX_Y);
    self.scrollView.contentOffset = CGPointMake(0, START_Y);
    self.previousContentOffsetY = self.scrollView.contentOffset.y;
    
    NSInteger index = self.delegate.startAtIndex;
    self.topItemIndex = index;
    self.bottomItemIndex = index;

    [self.scrollView empty];
    [self _addViewForItemIndex:self.topItemIndex withOffsetY:START_Y at:TOP];
    [self _extendBottom];
    [self.view addSubview:self.scrollView];
    
    [self.scrollView setDelegate:self];
    [self.scrollView onTap:^(UITapGestureRecognizer *sender) {
        CGPoint tapLocation = [sender locationInView:self.scrollView];
        for (NSInteger index = self.topItemIndex; index <= self.bottomItemIndex; index++) {
            UIView* view = self.scrollView.subviews[index - self.topItemIndex];
            if (CGRectContainsPoint(view.frame, tapLocation)) {
                id item = [self.delegate itemForIndex:index];
                [self.delegate selectItem:item atIndex:index];
            }
        }
    }];
}

- (UIView*)_addViewForItemIndex:(NSInteger)itemIndex withOffsetY:(CGFloat)offsetY at:(ListViewLocation)location {
    id item = [self.delegate itemForIndex:itemIndex];
    if (!item) { return nil; }
    UIView* view = [self.delegate viewForItem:item atIndex:itemIndex withWidth:self.width];
    if (location == TOP) {
        [view moveToY:offsetY - view.height];
        [self.scrollView insertSubview:view atIndex:0];
    } else {
        [view moveToY:offsetY];
        [self.scrollView addSubview:view];
    }
    return view;
}

- (void)_extendBottom {
    CGFloat targetY = self.scrollView.contentOffset.y + self.scrollView.height;
    CGFloat bottomY = CGRectGetMaxY(self.bottomView.frame);
    while (bottomY < targetY) {
        UIView* view = [self _addViewForItemIndex:self.bottomItemIndex+1 withOffsetY:bottomY at:BOTTOM];
        if (!view) {
            return [self _didReachEnd];
        }
        self.bottomItemIndex += 1;
        bottomY += view.height;
    }
    [self _cleanupTop];
}

- (void)_extendTop {
    CGFloat targetY = self.scrollView.contentOffset.y;
    CGFloat topY = CGRectGetMinY(self.topView.frame);
    while (topY > targetY) {
        UIView* view = [self _addViewForItemIndex:self.topItemIndex-1 withOffsetY:topY at:TOP];
        if (!view) {
            return [self _didReachBeginning];
        }
        topY -= view.height;
        self.topItemIndex -= 1;
    }
    [self _cleanupBottom];
}

- (void)_cleanupTop {
    CGFloat targetY = self.scrollView.contentOffset.y;
    while (CGRectGetMaxY(self.topView.frame) < targetY) {
        [self.topView removeFromSuperview];
        self.topItemIndex += 1;
    }
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
    for (UIView* subView in self.scrollView.subviews) {
        [subView moveByY:-changeInHeight];
    }
    self.scrollView.delegate = self;
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

- (void)stopScrolling {
    [self.scrollView setContentOffset:self.scrollView.contentOffset animated:NO];
}

- (UIView*)topView {
    return self.scrollView.subviews.firstObject;
}

- (UIView*)bottomView {
    return self.scrollView.subviews.lastObject;
}

@end
