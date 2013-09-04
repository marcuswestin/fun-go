//
//  ListViewController.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 8/8/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "ListViewController.h"
#import "UIView+FunStyle.h"

// Used to differentiate group head views from item views
@interface ListGroupHeadView : UIView;
@end
@implementation ListGroupHeadView
@end

static CGFloat MAX_Y = 9999999.0f;
static CGFloat START_Y = 99999.0f;

@implementation ListViewController {
    UIView* _topGroupView;
}
- (void)viewDidLoad {
    _groupHeadBoundary = 0;
    
    [super viewDidLoad];

    if (!_delegate) {
        _delegate = (id<ListViewDelegate>)self;
    }
    
    self.view.backgroundColor = WHITE;
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.showsVerticalScrollIndicator = NO;
    
    asyncMain(^{ // Load data in next tick to ensure subclass viewDidLoad finished
        [self _setupScrollview];
        [self reloadDataWithStartIndex:[_delegate listStartIndex]];
        [self.view insertSubview:_scrollView atIndex:0];
    });
}

- (void)reloadDataWithStartIndex:(NSInteger)startAtIndex {
    [self _withoutScrollEvents:^{
        [self.scrollView empty];
        _topY = START_Y;
        _bottomY = START_Y;
        
        _scrollView.contentSize = CGSizeMake(self.view.width, MAX_Y);
        _scrollView.contentOffset = CGPointMake(0, START_Y);
        _previousContentOffsetY = _scrollView.contentOffset.y;
        
        // All subsequent view calculations depend on the top/bottom current views.
        // Initialize with first view. It's the first top & bottom view.
        _topItemIndex = startAtIndex;
        _bottomItemIndex = startAtIndex - 1;
        BOOL didAddFirstView = [self _listAddNextBottomView];
        
        if (didAddFirstView) {
            [self _setTopGroupItem:[_delegate listItemForIndex:_topItemIndex] withDirection:DOWN];
            _bottomGroupId = _topGroupId;
            
            [self _extendBottom];
            [self _extendTop];
        }
    }];
}

- (void)_setupScrollview {
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
    _topGroupId = [_delegate listGroupIdForItem:item];
    if ([_delegate respondsToSelector:@selector(listTopGroupDidChange:withDirection:)]) {
        [_delegate listTopGroupDidChange:item withDirection:direction];
    }
}

- (BOOL)_isGroupView:(UIView*)view {
    return [view isMemberOfClass:[ListGroupHeadView class]];
}

- (BOOL)_listAddNextBottomView {
    NSInteger index = _bottomItemIndex + 1;
    id item = [_delegate listItemForIndex:index];
    if (!item) { return NO; }
    
    // Check if the new item falls outside of the group of the current bottom-most item.
    id groupId = [_delegate listGroupIdForItem:item];
    if (![groupId isEqual:_bottomGroupId]) {
        // We reached the beginning of the next-to-be-displayed group at the bottom of the view
        [self _addGroupViewForItem:item withGroupId:groupId atLocation:BOTTOM];
    }
    
    UIView* view = [_delegate listViewForItem:item atIndex:index withWidth:[self _listWidthForView]];
    [view moveToX:_groupMargins.left];
    [self _addView:view at:BOTTOM];
    
    _bottomItemIndex = index;
    return YES;
}

- (BOOL)_listAddNextTopView {
    NSInteger nextTopItemIndex = _topItemIndex - 1;
    id nextTopItem = [_delegate listItemForIndex:nextTopItemIndex];
    if (!nextTopItem) {
        if (![self _isGroupView:[self topView]]) {
            // There should always be a group view at the very top
            [self _listRenderTopGroup];
            return YES;
        }

        return NO; // We're at the very top
    }
    
    // Check if the new item falls outside of the group of the current top-most item.
    id groupId = [_delegate listGroupIdForItem:nextTopItem];
    if (![groupId isEqual:_topGroupId]) {
        if ([self _isGroupView:[self topView]]) {
            // The group view was just rendered in the previous _listAddNewTopView call
            _topGroupId = groupId;
        } else {
            // We reached the top of the currently displayed top-most group.
            [self _listRenderTopGroup];
            return YES;
        }
    }
    
    UIView* view = [_delegate listViewForItem:nextTopItem atIndex:nextTopItemIndex withWidth:[self _listWidthForView]];
    [view moveToX:_groupMargins.left];
    [self _addView:view at:TOP];
    _topItemIndex = nextTopItemIndex;
    return YES;
}

- (UIView*)_listRenderTopGroup {
    id previousTopItem = [_delegate listItemForIndex:_topItemIndex];
    return [self _addGroupViewForItem:previousTopItem withGroupId:_topGroupId atLocation:TOP];
}

- (CGFloat)_listWidthForView {
    return self.view.width - (_groupMargins.left + _groupMargins.right);
}

- (UIView*) _addGroupViewForItem:(id)item withGroupId:(id)groupId atLocation:(ListViewLocation)location {
    UIView* view = [_delegate listViewForGroupId:groupId withItem:item withWidth:[self _listWidthForView]];
    [view moveToX:_groupMargins.left y:_groupMargins.top + _groupMargins.bottom];
    CGRect frame = view.bounds;
    frame.size.height += _groupMargins.top + _groupMargins.bottom;
    ListGroupHeadView* groupView = [[ListGroupHeadView alloc] initWithFrame:frame];
    [groupView addSubview:view];
    [self _addView:groupView at:location];
    if (location == TOP) {
        [self _setTopGroupItem:item withDirection:UP];
    } else {
        _bottomGroupId = groupId;
    }
    [self _checkTopGroupView];
    return groupView;
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
        BOOL didAddView = [self _listAddNextBottomView];
        if (!didAddView) {
            [self _didReachTheVeryBottom];
            break;
        }
    }
    [self _cleanupTop];
}

- (void)_extendTop {
    CGFloat targetY = _scrollView.contentOffset.y;
    while (_topY > targetY) {
        BOOL didAddView = [self _listAddNextTopView];
        if (!didAddView) {
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
    CGFloat changeInHeight = CGRectGetMinY([self topView].frame);
    if (changeInHeight == 0) { return; }
    _topY -= changeInHeight;
    _bottomY -= changeInHeight;
    [self _withoutScrollEvents:^{
        _scrollView.contentOffset = CGPointMake(0, _scrollView.contentOffset.y - changeInHeight);
        for (UIView* subView in self.views) {
            [subView moveByY:-changeInHeight];
        }
    }];
}

- (void)_withoutScrollEvents:(Block)block {
    _scrollView.delegate = nil;
    block();
    _scrollView.delegate = self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (contentOffsetY > _previousContentOffsetY) {
        [self _extendBottom];
    } else if (contentOffsetY < _previousContentOffsetY) {
        [self _extendTop];
    } else { // contentOffsetY == _previousContentOffsetY
        return;
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

@end
