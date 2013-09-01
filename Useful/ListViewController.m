//
//  ListViewController.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 8/8/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "ListViewController.h"
#import "UIView+FunStyle.h"

static CGFloat MAX_Y = 9999999.0f;
static CGFloat START_Y = 99999.0f;

@implementation ListGroupHeadView
@end

@implementation ListViewController {
    UIView* _topGroupView;
}
- (void)viewDidLoad {
    _groupHeadBoundary = 0;
    
    [super viewDidLoad];
    UIView* view = self.view;
    if (!_delegate) {
        _delegate = (id<ListViewDelegate>)self;
    }
    _width = view.width;
    _height = view.height;
    _scrollView = [[UIScrollView alloc] initWithFrame:view.bounds];
        
    _scrollView.showsVerticalScrollIndicator = NO;
    
    // Load data in next tick to ensure subclass viewDidLoad finished
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadDataWithStartIndex:[_delegate listStartIndex]];
        [self _setupScrollview];
    });
}

- (void)reloadDataWithStartIndex:(NSInteger)startAtIndex {
    [self.scrollView empty];
    _topY = START_Y;
    _bottomY = START_Y;
    _topItemIndex = startAtIndex;
    _bottomItemIndex = startAtIndex - 1;
    
    _scrollView.contentSize = CGSizeMake(_width, MAX_Y);
    _scrollView.contentOffset = CGPointMake(0, START_Y);
    _previousContentOffsetY = _scrollView.contentOffset.y;

    [self _addViewForNextItemAtLocation:BOTTOM];
    [self _setTopGroupItem:[_delegate listItemForIndex:_topItemIndex] withDirection:DOWN];
    _bottomGroupId = _topGroupId;
    [self _extendBottom];
}

- (void)_setupScrollview {
    [self.view insertSubview:_scrollView atIndex:0];
    [_scrollView setDelegate:self];
    [_scrollView onTap:^(UITapGestureRecognizer *sender) {
        CGPoint tapPoint = [sender locationInView:_scrollView];
        NSInteger itemIndex = _topItemIndex;
        for (UIView* view in self.views) {
            BOOL isGroupView = [self _isGroupView:view];
            if (CGRectContainsPoint(view.frame, tapPoint)) {
                id item = [_delegate listItemForIndex:itemIndex];
                if (isGroupView) {
                    id groupId = [_delegate listGroupIdForItem:item];
                    if ([_delegate respondsToSelector:@selector(listSelectGroupWithId:withItem:)]) {
                        [_delegate listSelectGroupWithId:(id)groupId withItem:(id)item];
                    }
                } else {
                    [_delegate listSelectItem:item atIndex:itemIndex];
                }
                break;
            }
            if (!isGroupView) {
                itemIndex += 1; // Don't count group heads against item indices.
            }
        }
    }];
}

- (void)_setTopGroupItem:(id)item withDirection:(ListViewDirection)direction {
    _topGroupItem = item;
    _topGroupId = [_delegate listGroupIdForItem:item];
    if ([_delegate respondsToSelector:@selector(listTopGroupDidChange:withDirection:)]) {
        [_delegate listTopGroupDidChange:item withDirection:direction];
    }
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

    id item = [_delegate listItemForIndex:index];
    if (!item) {
        return NO;
    }
    
    [self _checkGroupForItem:item atLocation:location];

    UIView* view = [_delegate listViewForItem:item atIndex:index withWidth:_width];
    [self _addView:view at:location];
    
    if (location == TOP) {
        _topItemIndex = index;
    } else {
        _bottomItemIndex = index;
    }
    
    return YES;
}

- (void)_checkGroupForItem:(id)item atLocation:(ListViewLocation)location {
    id groupId = [_delegate listGroupIdForItem:item];
    id currentGroupId = (location == TOP ? _topGroupId : _bottomGroupId);
    if (![groupId isEqual:currentGroupId]) {
        UIView* view = [_delegate listViewForGroupId:groupId withItem:item withWidth:_width];
        ListGroupHeadView* groupView = [[ListGroupHeadView alloc] initWithFrame:view.bounds];
        [groupView addSubview:view];
        [self _addView:groupView at:location];
        if (location == TOP) {
            [self _setTopGroupItem:item withDirection:UP];
        } else {
            _bottomGroupId = groupId;
        }
        [self _checkTopGroupView];
    }
}

- (void) _checkTopGroupView {
    _topGroupView = [self.views pickOne:^BOOL(id view, NSUInteger i) {
        return [self _isGroupView:view];
    }];
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
            id item = [_delegate listItemForIndex:_topItemIndex];
            [self _setTopGroupItem:item withDirection:DOWN];
            [self _checkTopGroupView];
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
            id item = [_delegate listItemForIndex:_bottomItemIndex];
            _bottomGroupId = [_delegate listGroupIdForItem:item];
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
    
    if (_topGroupView && [_delegate respondsToSelector:@selector(listTopGroupViewDidMove:)]) {
        CGRect frame = _topGroupView.frame;
        frame.origin.y -= _scrollView.contentOffset.y;
        [_delegate listTopGroupViewDidMove:frame];
    }
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

//- (UIView*)topView {
//    return [self _firstRealSubviewFromIndex:0 step:1];
//}
//- (UIView*)bottomView {
//    return [self _firstRealSubviewFromIndex:_scrollView.subviews.count-1 step:-1];
//}
//- (UIView*)_firstRealSubviewFromIndex:(NSUInteger)index step:(NSInteger)step {
//    // Why is a random UIImageView hanging in the scroll view? Asch.
//    UIView* view;
//    NSArray* views = _scrollView.subviews;
//    do {
//        view = views[index];
//        index += step;
//    } while ([view isKindOfClass:UIImageView.class] && index > 0 && index < views.count);
//    return view;
//}

@end
