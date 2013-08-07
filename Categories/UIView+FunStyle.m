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

@implementation ViewStyler {
    UIView* _view;
    CGRect _frame;
    UIEdgeInsets _borderWidths;
    UIColor* _borderColor;
}

/* Create & apply
 ****************/
- (ViewStyler*)initWithView:(UIView*)view {
    _view = view;
    _frame = view.frame;
    return self;
}

- (void)apply {
    _view.frame = _frame;
    [self _makeBorders];
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
        self.xy(x, _frame.origin.y);
        return self;
    };
}

- (StylerFloat1)y {
    return ^(float y) {
        self.xy(_frame.origin.x, y);
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
    };
}
- (StylerFloat1)positionFromBottom {
    return ^(CGFloat offsetFromBottom) {
        return self.y(_view.superview.frame.size.height - _frame.size.height - offsetFromBottom);
    };
}
- (StylerRect)frame {
    return ^(CGRect frame) {
        _frame = frame;
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

/* Styling
 *********/
- (StylerColor1)bg {
    return ^(UIColor* color) {
        _view.backgroundColor = color;
        return self;
    };
}
- (StylerFloat3)shadow {
    return ^(CGFloat xOffset, CGFloat yOffset, CGFloat radius) {
        _view.layer.shadowColor = [UIColor colorWithWhite:0.5 alpha:1].CGColor;
        _view.layer.shadowOffset = CGSizeMake(xOffset, yOffset);
        _view.layer.shadowRadius = radius;
        _view.layer.shadowOpacity = 0.5;
        return self;
    };
}
- (StylerFloat1)radius {
    return ^(CGFloat radius) {
        _view.layer.cornerRadius = radius;
        return self;
    };
}
- (StylerFloat4)borderWidths {
    return ^(CGFloat top, CGFloat right, CGFloat bottom, CGFloat left) {
        _borderWidths = UIEdgeInsetsMake(top, left, bottom, right);
        return self;
    };
}
- (StylerColor1)borderColor {
    return ^(UIColor* borderColor) {
        _borderColor = borderColor;
        return self;
    };
}
- (void)_makeBorders {
    if (_borderWidths.top) {
        [self _addBorder:CGRectMake(0, 0, _frame.size.width, _borderWidths.top)];
    }
    if (_borderWidths.right) {
        [self _addBorder:CGRectMake(_frame.size.width - _borderWidths.right, 0, _borderWidths.right, _frame.size.height)];
    }
    if (_borderWidths.bottom) {
        [self _addBorder:CGRectMake(0, _frame.size.height - _borderWidths.bottom, _frame.size.width, _borderWidths.bottom)];
    }
    if (_borderWidths.left) {
        [self _addBorder:CGRectMake(0, 0, _borderWidths.left, _frame.size.height)];
    }
}
- (void)_addBorder:(CGRect)rect {
    CALayer* border = [CALayer layer];
    border.frame = rect;
    border.backgroundColor = _borderColor.CGColor;
    [_view.layer addSublayer:border];
}
- (ViewStyler *)hide {
    return ^(){
        _view.hidden = YES;
        return self;
    };
}
/* Labels
 ********/
- (StylerString1)text {
    return ^(NSString* text) {
        ((UILabel*) _view).text = text;
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
#if defined DEBUG && FALSE
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
- (void)setWidth:(CGFloat)width {
    [self setSize:CGSizeMake(width, self.height)];
}
- (void)setHeight:(CGFloat)height {
    [self setSize:CGSizeMake(self.width, height)];
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
- (void)moveByX:(CGFloat)dx y:(CGFloat)dy {
    CGRect frame = self.frame;
    frame.origin.x += dx;
    frame.origin.y += dy;
    self.frame = frame;
}
- (void)moveByX:(CGFloat)x {
    [self moveByX:x y:0];
}
- (void)moveByY:(CGFloat)y {
    [self moveByX:0 y:y];
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
- (void)moveToPosition:(CGPoint)origin {
    [self moveToX:origin.x y:origin.y];
}
- (void)moveByVector:(CGPoint)vector {
    CGPoint newOrigin = self.frame.origin;
    newOrigin.x += vector.x;
    newOrigin.y += vector.y;
    [self moveToPosition:newOrigin];
}
- (void)centerVerticallyInView:(UIView *)view {
    [self moveToY:CGRectGetMidY(view.frame) - CGRectGetMidY(self.frame)];
}
- (void)centerVerticallyInSuperView {
    [self centerVerticallyInView:self.superview];
}
- (void)centerInSuperview {
    [self.styler.centerInSuperView apply];
}
- (CGPoint)topRightCorner {
    CGPoint point = self.frame.origin;
    point.x += self.width;
    return point;
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

/* View hierarchy
 ****************/
- (void)empty {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
- (UIView *)appendTo:(UIView *)superview {
    [superview addSubview:self];
    return self;
}

/* Screenshot
 ************/
- (UIImage *)captureToImage {
    return [self captureToImageWithScale:0.0];
}
- (UIImage *)captureToImageWithScale:(CGFloat)scale {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, scale);
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
