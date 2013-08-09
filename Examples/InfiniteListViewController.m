//
//  InfiniteListViewController.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 8/8/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "InfiniteListViewController.h"

@implementation InfiniteListViewController

- (NSInteger)startAtIndex {
    return 0;
}

- (id)itemForIndex:(NSInteger)index {
    if (index == 100) {
        return nil;
    }
    if (index == -100) {
        return nil;
    }
    NSString* text = [NSString stringWithFormat:@"%d", index];
    return @{ @"text":text, @"color":RANDOM_COLOR };
}

- (UIView *)viewForItem:(NSDictionary*)item {
    UIView* view = [UIView.styler.wh(self.view.width, 80).bg(item[@"color"]) render];
    [UILabel.appendTo(view).text(item[@"text"]).sizeToFit.centerInSuperView render];
    return view;
}

- (id)groupForItem:(id)item {
    return @0; // all in one big family
}

- (void)selectItem:(id)item {
    NSLog(@"Select %@", item);
}

@end
