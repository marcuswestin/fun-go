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

@implementation ListGroupHeadView
@end

@implementation ListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    UIView* view = self.view;
    if (!_delegate) { _delegate = (id<ListViewDelegate>)self; }
    _width = view.width;
    _height = view.height;
    _scrollView = [[UIScrollView alloc] initWithFrame:view.bounds];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(_width, MAX_Y);
    _scrollView.contentOffset = CGPointMake(0, START_Y);
    _previousContentOffsetY = _scrollView.contentOffset.y;
    
    // Load data in next tick to ensure subclass viewDidLoad finished
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _loadData];
    });
}

- (void)_loadData {
    _topY = START_Y;
    _bottomY = START_Y;
    _topItemIndex = _delegate.startAtIndex;
    _bottomItemIndex = _delegate.startAtIndex - 1;

    [self _addViewForNextItemAtLocation:BOTTOM];
    [self _extendBottom];
    [self.view insertSubview:_scrollView atIndex:0];
    
    [_scrollView setDelegate:self];
    [_scrollView onTap:^(UITapGestureRecognizer *sender) {
        CGPoint tapPoint = [sender locationInView:_scrollView];
        NSInteger itemIndex = _topItemIndex;
        for (UIView* view in self.views) {
            BOOL isGroupView = [self _isGroupView:view];
            if (CGRectContainsPoint(view.frame, tapPoint)) {
                id item = [_delegate itemForIndex:itemIndex];
                if (isGroupView) {
                    id groupId = [_delegate groupIdForItem:item];
                    [_delegate selectGroupWithId:(id)groupId withItem:(id)item];
                } else {
                    [_delegate selectItem:item atIndex:itemIndex];
                }
                break;
            }
            if (!isGroupView) {
                itemIndex += 1; // Don't count group heads against item indices.
            }
        }
    }];
}

- (BOOL)_isGroupView:(UIView*)view {
    return [view isMemberOfClass:[ListGroupHeadView class]];
}

- (BOOL)_addViewForNextItemAtLocation:(ListViewLocation)location {
    NSInteger index;
    if (location == TOP) {
        index = _topItemIndex - 1;
    } else {
        index = _bottomItemIndex + 1;
    }

    id item = [_delegate itemForIndex:index];
    if (!item) {
        return NO;
    }
    
    [self _checkGroupForItem:item atLocation:location];

    UIView* view = [_delegate viewForItem:item atIndex:index withWidth:_width];
    [self _addView:view at:location];
    
    if (location == TOP) {
        _topItemIndex = index;
    } else {
        _bottomItemIndex = index;
    }
    
    return YES;
}

- (void)_checkGroupForItem:(id)item atLocation:(ListViewLocation)location {
    id groupId = [_delegate groupIdForItem:item];
    id currentGroupId = (location == TOP ? _topGroupId : _bottomGroupId);
    if (![groupId isEqual:currentGroupId]) {
        UIView* view = [_delegate viewForGroupId:groupId withItem:item withWidth:_width];
        ListGroupHeadView* groupView = [[ListGroupHeadView alloc] initWithFrame:view.bounds];
        [self _addView:groupView at:location];
        if (location == TOP) {
            _topGroupId = groupId;
        } else {
            _bottomGroupId = groupId;
        }
    }
}

- (void)_addView:(UIView*)view at:(ListViewLocation)location {
    if (location == TOP) {
        _topY -= view.height;
        [view moveToY:_topY];
        [_scrollView insertSubview:view atIndex:0];
    } else {
        [view moveToY:_bottomY];
        _bottomY += view.height;
        [_scrollView addSubview:view];
    }
}

- (void)_extendBottom {
    CGFloat targetY = _scrollView.contentOffset.y + _scrollView.height;
    while (_bottomY < targetY) {
        BOOL didAddItem = [self _addViewForNextItemAtLocation:BOTTOM];
        if (!didAddItem) {
            [self _didReachTheVeryBottom];
            break;
        }
    }
    [self _cleanupTop];
}

- (void)_extendTop {
    CGFloat targetY = _scrollView.contentOffset.y;
    while (_topY > targetY) {
        BOOL didAddItem = [self _addViewForNextItemAtLocation:TOP];
        if (!didAddItem) {
            [self _didReachTheVeryTop];
            break;
        }
    }
    [self _cleanupBottom];
}

- (void)_cleanupTop {
    CGFloat targetY = _scrollView.contentOffset.y;
    UIView* view;
    while (CGRectGetMaxY((view = [self topView]).frame) < targetY) {
        [view removeFromSuperview];
        _topY += view.height;
        if ([self _isGroupView:view]) {
            id item = [_delegate itemForIndex:_topItemIndex];
            _topGroupId = [_delegate groupIdForItem:item];
        } else {
            _topItemIndex += 1;
        }
    }
}

- (void) _cleanupBottom {
    CGFloat targetY = _scrollView.contentOffset.y + _scrollView.height;
    UIView* view;
    while (CGRectGetMinY((view = [self bottomView]).frame) > targetY) {
        [view removeFromSuperview];
        _bottomY -= view.height;
        if ([self _isGroupView:view]) {
            id item = [_delegate itemForIndex:_bottomItemIndex];
            _bottomGroupId = [_delegate groupIdForItem:item];
        } else {
            _bottomItemIndex -= 1;
        }
    }
}

- (void)_didReachTheVeryBottom {
    _scrollView.contentSize = CGSizeMake(_scrollView.width, CGRectGetMaxY([self bottomView].frame));
}

- (void)_didReachTheVeryTop {
    if (_scrollView.contentOffset.y <= 0) { return; }
    CGFloat changeInHeight = CGRectGetMinY([self topView].frame);
    _topY -= changeInHeight;
    _bottomY -= changeInHeight;
    // We don't want to fire another scroll event,
    // so remove ourselves as delegate while the swap is made
    _scrollView.delegate = nil;
    _scrollView.contentOffset = CGPointZero;
    for (UIView* subView in self.views) {
        [subView moveByY:-changeInHeight];
    }
    _scrollView.delegate = self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (contentOffsetY == _previousContentOffsetY) {
        return;
    }
    if (contentOffsetY > _previousContentOffsetY) {
        [self _extendBottom];
    } else {
        [self _extendTop];
    }
    _previousContentOffsetY = scrollView.contentOffset.y;
}

- (void)stopScrolling {
    [_scrollView setContentOffset:_scrollView.contentOffset animated:NO];
}

- (NSArray*)views {
    return [_scrollView.subviews filter:^BOOL(UIView* view, NSUInteger i) {
        // Why is a random UIImageView hanging in the scroll view? Asch.
        return ![view isKindOfClass:UIImageView.class];
    }];
}
- (UIView*)topView {
    return self.views.firstObject;
}
- (UIView*)bottomView {
    return self.views.lastObject;
}

@end
