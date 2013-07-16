//
//  TableViewController.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/1/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "TableViewController.h"

@implementation TableViewController

- (void)viewDidLoad {
    if (!_delegate) { _delegate = (NSObject<TableViewDelegate>*) self; }
    _items = [_delegate loadItems];
    _rowHeights = calloc(_items.count, sizeof(NSUInteger));

    NSArray* sectionCounts = [_delegate loadSectionCounts];
    _sectionCount = sectionCounts.count;
    _headerHeights = calloc(_sectionCount, sizeof(NSUInteger));
    _rowCountPerSection = malloc(_sectionCount * sizeof(NSUInteger));
    _rowCountBeforeSection = malloc(_sectionCount * sizeof(NSUInteger));
    [sectionCounts each:^(id val, NSUInteger i) {
        _rowCountPerSection[i] = [sectionCounts[i] integerFor:@"count"];
        if (i == 0) {
            _rowCountBeforeSection[i] = 0;
        } else {
            _rowCountBeforeSection[i] = _rowCountBeforeSection[i - 1] + _rowCountPerSection[i - 1];
        }
    }];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (NSUInteger)indexForPath:(NSIndexPath*)indexPath {
    return _rowCountBeforeSection[indexPath.section] + indexPath.row;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _rowCountPerSection[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self itemForPath:indexPath];
    NSUInteger width = Viewport.width;
    NSUInteger height = [_delegate heightForItem:item width:width];
    UITableViewCell* cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    cell.backgroundColor = [UIColor whiteColor];
    [_delegate renderItem:item inCell:cell width:width height:height];
    return cell;
}

- (void)forEachRowIndexInSection:(NSUInteger)section block:(ForEachIndexBlock)block {
    NSUInteger index = _rowCountBeforeSection[section];
    NSUInteger lastIndex = _rowCountBeforeSection[section] + _rowCountPerSection[section];
    while (index < lastIndex) {
        block(index);
        index += 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = [self indexForPath:indexPath];
    if (!_rowHeights[index]) {
        _rowHeights[index] = [_delegate heightForItem:_items[index] width:Viewport.width];
    }
    return _rowHeights[index];
}

- (id)itemForPath:(NSIndexPath*)indexPath {
    return _items[[self indexForPath:indexPath]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSUInteger height = [self tableView:tableView heightForHeaderInSection:section];
    NSUInteger width = Viewport.width;
    UIView* view = [UIView.styler.wh(width,height) render];
    view.backgroundColor = [UIColor randomColor];
    [_delegate renderHeader:section inView:view width:width height:height];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!_headerHeights[section]) {
        _headerHeights[section] = [_delegate heightForHeader:section];
    }
    return _headerHeights[section];
}

/* Selection
 ***********/
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_delegate shouldHighlightItem:[self itemForPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [_delegate selectItem:[self itemForPath:indexPath] cell:cell];
}

/* Scrolling
 ***********/
- (void)scrollToBottomAnimated:(BOOL)animated {
    NSUInteger section = _sectionCount - 1;
    NSUInteger row = _rowCountPerSection[section] - 1;
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

@end
