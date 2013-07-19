//
//  UIView+Style.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 ;; Labs Inc. All rights reserved.
//

#import "UIView+FunStyle.h"
#import "FunAll.h"
#import <QuartzCore/QuartzCore.h>

#if defined DEBUG
//#define RANDOM_COLOR
#endif

@implementation ViewStyler {
    UIView* _view;
    CGRect _frame;
}

/* Create & apply
 ****************/
- (ViewStyler*)initWithView:(UIView*)view {
    _view = view;
    _frame = view.frame;
    return self;
}

- (id)apply {
    _view.frame = _frame;
    return _view;
}

- (id)render {
    [self apply];
    [_view render];
    return _view;
}

- (id)view {
    return _view;
}

/* View Hierarchy
 ****************/
- (StylerView)appendTo {
    return ^(UIView* view) {
        [view addSubview:_view];
        return self;
    };
}
- (StylerView)prependTo {
    return ^(UIView* view) {
        [view insertSubview:_view atIndex:0];
        return self;
    };
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
- (StylerPoint)position {
    return ^(CGPoint position) {
        _frame.origin = position;
        return self;
    };
}

- (StylerView)centerInView {
    return ^(UIView* parentView) {
        _view.frame = _frame;
        _view.center = parentView.center;
        _frame = _view.frame;
        return self;
    };
}

- (ViewStyler *)centerInSuperView {
    return self.centerInView(_view.superview);
}

- (ViewStyler *)positionAboveSuperview {
    return self.y(-_frame.size.height);
}
- (StylerFloat1)positionFromRight {
    return ^(CGFloat offsetFromRight) {
        return self.x(_view.superview.frame.size.width - _frame.size.width - offsetFromRight);
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

- (ViewStyler*)sizeToFit {
    [_view sizeToFit];
    _frame.size = _view.frame.size;
    return self;
}

- (ViewStyler*)sizeToParent {
    _frame.size = _view.superview.bounds.size;
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

@implementation UIView (FunStyle)

- (void)render {}

+ (StylerView)appendTo {
    return self.styler.appendTo;
}

+ (StylerView)prependTo {
    return self.styler.prependTo;
}

+ (ViewStyler*)styler {
    UIView* instance = [[[self class] alloc] init];
#if defined RANDOM_COLOR
    return instance.styler.bg([UIColor randomColor]);
#else
    return instance.styler;
#endif
}
- (ViewStyler*)styler {
    return [[ViewStyler alloc] initWithView:self];
}

/* Size
 ******/
- (CGFloat)height {
    return CGRectGetHeight(self.frame);
}
- (CGFloat)width {
    return CGRectGetWidth(self.frame);
}
- (void)setSize:(CGSize)size {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}
- (void)resizeByAddingWidth:(CGFloat)width height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height += height;
    frame.size.width += width;
    self.frame = frame;
}
- (void)resizeBySubtractingWidth:(CGFloat)width height:(CGFloat)height {
    [self resizeByAddingWidth:-width height:-height];
}
- (CGSize)resizeToContainSubviews {
    CGSize size = self.bounds.size;
    for (UIView* view in self.subviews) {
        CGSize subSize = [view resizeToContainSubviews];
        CGFloat maxX = view.frame.origin.x + subSize.width;
        CGFloat maxY = view.frame.origin.y + subSize.height;
        if (maxX > size.width) { size.width = maxX; }
        if (maxY > size.height) { size.height = maxY; }
    }
    return self.size = size;
}

/* Position
 **********/
- (void)moveByX:(NSInteger)dx y:(NSInteger)dy {
    CGRect frame = self.frame;
    frame.origin.x += dx;
    frame.origin.y += dy;
    self.frame = frame;
}
- (void)moveToX:(CGFloat)x y:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.x = x;
    frame.origin.y = y;
    self.frame = frame;
}
- (void)moveToY:(CGFloat)y {
    [self moveToX:self.frame.origin.x y:y];
}
- (void)moveToX:(CGFloat)x {
    [self moveToX:x y:self.frame.origin.y];
}
- (void)centerVerticallyInView:(UIView *)view {
    [self moveToY:CGRectGetMidY(view.frame) - CGRectGetMidY(self.frame)];
}
- (void)centerVerticallyInSuperView {
    [self centerVerticallyInView:self.superview];
}

/* Borders, Shadows & Insets
 ***************************/
- (void)setBorderColor:(UIColor *)color width:(CGFloat)width {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

- (void)setOutsetShadowColor:(UIColor *)color radius:(CGFloat)radius {
    return [self setOutsetShadowColor:color radius:radius spread:0 x:0 y:0];
}
- (void)setInsetShadowColor:(UIColor *)color radius:(CGFloat)radius {
    return [self setInsetShadowColor:color radius:radius spread:0 x:0 y:0];
}

static CGFloat STATIC = 0.5f;
- (void)setOutsetShadowColor:(UIColor *)color radius:(CGFloat)radius spread:(CGFloat)spread x:(CGFloat)offsetX y:(CGFloat)offsetY {
    if (self.clipsToBounds) { NSLog(@"Warning: outset shadow put on view with clipped bounds"); }
    NSArray* colors = @[(id)color.CGColor, (id)[UIColor.clearColor CGColor]];
    
    CAGradientLayer *top = [CAGradientLayer layer];
    top.frame = CGRectMake(0 + offsetX, -radius + offsetY, self.bounds.size.width, spread + radius);
    top.colors = colors;
    top.startPoint = CGPointMake(STATIC, 1.0);
    top.endPoint = CGPointMake(STATIC, 0.0);
    [self.layer insertSublayer:top atIndex:0];
    
    CAGradientLayer *right = [CAGradientLayer layer];
    right.frame = CGRectMake(self.bounds.size.width + radius + offsetX, 0 + offsetY, spread + radius, self.bounds.size.height);
    right.colors = colors;
    right.startPoint = CGPointMake(0.0, STATIC);
    right.endPoint = CGPointMake(1.0, STATIC);
    [self.layer insertSublayer:right atIndex:0];
    
    CAGradientLayer *bottom = [CAGradientLayer layer];
    bottom.frame = CGRectMake(0 + offsetX, self.bounds.size.height + offsetY, self.bounds.size.width, spread + radius);
    bottom.colors = colors;
    bottom.startPoint = CGPointMake(STATIC, 0.0);
    bottom.endPoint = CGPointMake(STATIC, 1.0);
    [self.layer insertSublayer:bottom atIndex:0];
    
    CAGradientLayer *left = [CAGradientLayer layer];
    left.frame = CGRectMake(-radius + offsetX, 0 + offsetY, spread + radius, self.bounds.size.height);
    left.colors = colors;
    left.startPoint = CGPointMake(1.0, STATIC);
    left.endPoint = CGPointMake(0.0, STATIC);
    [self.layer insertSublayer:left atIndex:0];
}

- (void)setInsetShadowColor:(UIColor*)color radius:(CGFloat)radius spread:(CGFloat)spread x:(CGFloat)offsetX y:(CGFloat)offsetY {
    NSArray* colors = @[(id)color.CGColor, (id)[UIColor.clearColor CGColor]];
    
    CAGradientLayer *top = [CAGradientLayer layer];
    top.frame = CGRectMake(0 + offsetX, 0 + offsetY, self.bounds.size.width, spread + radius);
    top.colors = colors;
    top.startPoint = CGPointMake(STATIC, 0.0);
    top.endPoint = CGPointMake(STATIC, 1.0);
    [self.layer insertSublayer:top atIndex:0];
    
    CAGradientLayer *right = [CAGradientLayer layer];
    right.frame = CGRectMake(self.bounds.size.width - radius + offsetX, 0 + offsetY, spread + radius, self.bounds.size.height);
    right.colors = colors;
    right.startPoint = CGPointMake(1.0, STATIC);
    right.endPoint = CGPointMake(0.0, STATIC);
    [self.layer insertSublayer:right atIndex:0];

    CAGradientLayer *bottom = [CAGradientLayer layer];
    bottom.frame = CGRectMake(0 + offsetX, self.bounds.size.height - radius + offsetY, self.bounds.size.width, spread + radius);
    bottom.colors = colors;
    bottom.startPoint = CGPointMake(STATIC, 1.0);
    bottom.endPoint = CGPointMake(STATIC, 0.0);
    [self.layer insertSublayer:bottom atIndex:0];

    CAGradientLayer *left = [CAGradientLayer layer];
    left.frame = CGRectMake(0 + offsetX, 0 + offsetY, spread + radius, self.bounds.size.height);
    left.colors = colors;
    left.startPoint = CGPointMake(0.0, STATIC);
    left.endPoint = CGPointMake(1.0, STATIC);
    [self.layer insertSublayer:left atIndex:0];
}

/* Content
 *********/
- (void)empty {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
- (UIImage *)captureToImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
- (NSData *)captureToJpgData:(CGFloat)compressionQuality {
    return UIImageJPEGRepresentation([self captureToImage], compressionQuality);
}
- (NSData *)captureToPngData {
    return UIImagePNGRepresentation([self captureToImage]);
}

@end
