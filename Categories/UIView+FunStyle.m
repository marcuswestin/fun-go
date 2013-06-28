//
//  UIView+Style.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 ;; Labs Inc. All rights reserved.
//

#import "UIView+FunStyle.h"

@implementation UIView (FunStyle)

- (ViewStyle*)style {
    return [[ViewStyle alloc] initWithView:self];
}

@end

@implementation ViewStyle {
    UIView* view;
    CGRect frame;
    CALayer* layer;
}

/* Create & apply
 ****************/
- (instancetype)init {
    self = [super init];
    frame = CGRectZero;
    return self;
}

- (instancetype)initWithView:(UIView *)_view {
    self = [self init];
    view = _view;
    return self;
}

- (UIView *)apply {
    view.frame = frame;
    return view;
}


/* Position
 **********/
- (StylerFloat1)x {
    return ^(float x) {
        self.xy(x, view.frame.origin.y);
        return self;
    };
}

- (StylerFloat1)y {
    return ^(float y) {
        self.xy(view.frame.origin.x, y);
        return self;
    };
}

- (StylerFloat2)xy {
    return ^(float x, float y) {
        frame.origin.x = x;
        frame.origin.y = y;
        return self;
    };
}

- (StylerView)centerIn {
    return ^(UIView* parentView) {
        view.frame = frame;
        view.center = parentView.center;
        frame = view.frame;
        return self;
    };
}

/* Size
 ******/
- (StylerFloat1)w {
    return ^(float width) {
        frame.size.width = width;
        return self;
    };
}

- (StylerFloat1)h {
    return ^(float height) {
        frame.size.height = height;
        return self;
    };
}

- (StylerFloat2)wh {
    return ^(float width, float height) {
        frame.size.width = width;
        frame.size.height = height;
        return self;
    };
}

- (ViewStyle*)sizeToFit {
    [view sizeToFit];
    frame.size = view.frame.size;
    return self;
}

/* Color
 *******/
- (StylerColor1)bg {
    return ^(UIColor* color) {
        view.backgroundColor = color;
        return self;
    };
}

@end