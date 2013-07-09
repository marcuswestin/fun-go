//
//  UIView+Style.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 ;; Labs Inc. All rights reserved.
//

#import "UIView+FunStyle.h"
#import <QuartzCore/QuartzCore.h>

ViewStyle* makeView() {
    return [[UIView alloc] init].style;
}

@implementation UIView (FunStyle)

- (ViewStyle*)style {
    return [[ViewStyle alloc] initWithView:self];
}

- (void)moveByX:(NSInteger)dx y:(NSInteger)dy {
    CGFloat x = self.frame.origin.x + dx;
    self.frame = CGRectMake(x, self.frame.origin.y + dy, self.frame.size.width, self.frame.size.height);
}

- (void)moveToX:(CGFloat)x y:(CGFloat)y {
    self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
}
- (void)moveToY:(CGFloat)y {
    [self moveToX:self.frame.origin.x y:y];
}
- (void)moveToX:(CGFloat)x {
    [self moveToX:x y:self.frame.origin.y];
}

- (void)outsetShadowColor:(UIColor *)color opacity:(CGFloat)opacity radius:(CGFloat)radius x:(CGFloat)offsetX y:(CGFloat)offsetY {
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
    self.layer.shadowOffset = CGSizeMake(offsetX, offsetY);
}

- (void)insetShadowColor:(UIColor*)color radius:(CGFloat)radius x:(CGFloat)offsetX y:(CGFloat)offsetY {
    UIView *shadowView = [[UIView alloc] initWithFrame:self.frame];
    [shadowView moveToX:0 y:0];
    NSArray* colors = @[(id)color.CGColor, (id)[UIColor.clearColor CGColor]];
    
    CAGradientLayer *shadowTop = [CAGradientLayer layer];
    shadowTop.frame = CGRectMake(0 + offsetX, 0 + offsetY, self.bounds.size.width, radius);
    shadowTop.colors = colors;
    shadowTop.startPoint = CGPointMake(0.5, 0.0);
    shadowTop.endPoint = CGPointMake(0.5, 1.0);
    [shadowView.layer insertSublayer:shadowTop atIndex:0];
    
    CAGradientLayer *shadowRight = [CAGradientLayer layer];
    shadowRight.frame = CGRectMake(self.bounds.size.width - radius + offsetX, 0 + offsetY, radius, self.bounds.size.height);
    shadowRight.colors = colors;
    shadowRight.startPoint = CGPointMake(0.5, 0.0);
    shadowRight.endPoint = CGPointMake(0.5, 1.0);
    [shadowView.layer insertSublayer:shadowRight atIndex:0];

    CAGradientLayer *shadowBottom = [CAGradientLayer layer];
    shadowBottom.frame = CGRectMake(0 + offsetX, self.bounds.size.height - radius + offsetY, self.bounds.size.width, radius);
    shadowBottom.colors = colors;
    shadowBottom.startPoint = CGPointMake(0.5, 1.0);
    shadowBottom.endPoint = CGPointMake(0.5, 0.0);
    [shadowView.layer insertSublayer:shadowBottom atIndex:0];

    CAGradientLayer *shadowLeft = [CAGradientLayer layer];
    shadowLeft.frame = CGRectMake(0 + offsetX, 0 + offsetY, radius, self.bounds.size.height);
    shadowLeft.colors = colors;
    shadowLeft.startPoint = CGPointMake(0.0, 0.5);
    shadowLeft.endPoint = CGPointMake(1.0, 0.5);
    [shadowView.layer insertSublayer:shadowLeft atIndex:0];
    
    [self addSubview:shadowView];
}

- (void)borderColor:(UIColor *)color width:(CGFloat)width {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}
@end

@implementation ViewStyle {
    UIView* _view;
    CGRect _frame;
}

/* Create & apply
 ****************/
- (instancetype)initWithView:(UIView *)view {
    self = [self init];
    _view = view;
    _frame = view.frame;
    return self;
}

- (UIView *)apply {
    _view.frame = _frame;
    return _view;
}


/* Position
 **********/
- (StylerFloat1)x {
    return ^(float x) {
        self.xy(x, _view.frame.origin.y);
        return self;
    };
}

- (StylerFloat1)y {
    return ^(float y) {
        self.xy(_view.frame.origin.x, y);
        return self;
    };
}

- (StylerFloat2)xy {
    return ^(float x, float y) {
        _frame.origin.x = x;
        _frame.origin.y = y;
        return self;
    };
}

- (StylerView)centerIn {
    return ^(UIView* parentView) {
        _view.frame = _frame;
        _view.center = parentView.center;
        _frame = _view.frame;
        return self;
    };
}

/* Size
 ******/
- (StylerFloat1)w {
    return ^(float width) {
        _frame.size.width = width;
        return self;
    };
}

- (StylerFloat1)h {
    return ^(float height) {
        _frame.size.height = height;
        return self;
    };
}

- (StylerFloat2)wh {
    return ^(float width, float height) {
        _frame.size.width = width;
        _frame.size.height = height;
        return self;
    };
}

- (StylerSize)size {
    return ^(CGSize size) {
        _frame.size = size;
        return self;
    };
}

- (ViewStyle*)sizeToFit {
    [_view sizeToFit];
    _frame.size = _view.frame.size;
    return self;
}

/* Misc
 ******/
- (StylerColor1)bg {
    return ^(UIColor* color) {
        _view.backgroundColor = color;
        return self;
    };
}

- (StylerRadius)radius {
    return ^(CGFloat radius) {
        _view.layer.cornerRadius = radius;
        return self;
    };
}
@end
