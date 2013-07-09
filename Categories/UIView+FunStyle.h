//
//  UIView+Style.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewStyle;

ViewStyle* makeView();

typedef ViewStyle* (^Styler)();
typedef ViewStyle* (^StylerView)(UIView* view);
typedef ViewStyle* (^StylerSize)(CGSize size);
typedef ViewStyle* (^StylerFloat1)(float num);
typedef ViewStyle* (^StylerFloat2)(float f1, float f2);
typedef ViewStyle* (^StylerColor1)(UIColor* color);

@interface ViewStyle : NSObject

/* Create & apply
 ****************/
- (instancetype)initWithView:(UIView*)view;
- (UIView*)apply;

/* Position
 **********/
- (StylerFloat1)x;
- (StylerFloat1)y;
- (StylerFloat2)xy;
- (ViewStyle*)sizeToFit;

/* Size
 ******/
- (StylerFloat1)w;
- (StylerFloat1)h;
- (StylerFloat2)wh;
- (StylerSize)size;
- (StylerView)centerIn;

/* Misc
 ******/
- (StylerColor1)bg;
typedef ViewStyle* (^StylerRadius)(CGFloat radius);
- (StylerRadius)radius;
@end

@interface UIView (FunStyle)

- (ViewStyle*) style;
- (void)moveByX:(NSInteger)x y:(NSInteger)y;
- (void)moveToX:(CGFloat)x y:(CGFloat)y;
- (void)moveToX:(CGFloat)x;
- (void)moveToY:(CGFloat)y;
- (void)outsetShadowColor:(UIColor*)color opacity:(CGFloat)opacity radius:(CGFloat)radius x:(CGFloat)offsetX y:(CGFloat)offsetY;
- (void)insetShadowColor:(UIColor*)fillColor radius:(CGFloat)radius x:(CGFloat)offsetX y:(CGFloat)offsetY;
- (void)borderColor:(UIColor*)color width:(CGFloat)width;

/* Size
 ******/
- (CGFloat)height;

/* Position
 **********/
- (void)centerVerticallyInView:(UIView*)view;

@end
