//
//  UIView+Style.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunBase.h"

@class ViewStyler;

typedef ViewStyler* (^Styler)();
typedef ViewStyler* (^StylerView)(UIView* view);
typedef ViewStyler* (^StylerSize)(CGSize size);
typedef ViewStyler* (^StylerFloat1)(CGFloat num);
typedef ViewStyler* (^StylerFloat2)(CGFloat f1, CGFloat f2);
typedef ViewStyler* (^StylerFloat3)(CGFloat f1, CGFloat f2, CGFloat f3);
typedef ViewStyler* (^StylerFloat4)(CGFloat f1, CGFloat f2, CGFloat f3, CGFloat f4);
typedef ViewStyler* (^StylerColor1)(UIColor* color);
typedef ViewStyler* (^StylerPoint)(CGPoint point);
typedef ViewStyler* (^StylerRect)(CGRect rect);
typedef ViewStyler* (^StylerString1)(NSString* string);
typedef ViewStyler* (^StylerInteger1)(NSInteger integer);
typedef ViewStyler* (^StylerTextAlignment)(NSTextAlignment textAlignment);
typedef ViewStyler* (^StylerColorFloat2)(UIColor* color, CGFloat f1, CGFloat f2);
typedef ViewStyler* (^StylerFont)(UIFont* font);
@interface ViewStyler : FunBase

/* Create & apply
 ****************/
- (void)apply;
- (id)render;

/* View hierarchy
 ****************/
- (StylerView)appendTo;
- (StylerView)prependTo;
- (StylerInteger1)tag;
- (StylerString1)name;

/* Position
 **********/
- (StylerFloat1)x;
- (StylerFloat1)y;
- (StylerFloat2)xy;
- (ViewStyler*)centerInSuperView;
- (ViewStyler*)centerVerticallyInSuperview;
- (ViewStyler*)centerHorizontallyInSuperview;
- (ViewStyler*)positionAboveSuperview;
- (StylerFloat1)positionFromRight;
- (StylerFloat1)positionFromBottom;
- (StylerPoint)position;
- (StylerRect)frame;
- (StylerFloat4)inset;
- (StylerFloat1)moveDown;
- (StylerView)positionBelowView;

/* Size
 ******/
- (StylerFloat1)w;
- (StylerFloat1)h;
- (StylerFloat2)wh;
- (StylerSize)size;
- (ViewStyler*)sizeToFit;
- (ViewStyler*)sizeToParent;

/* Styling
 *********/
- (StylerColor1)bg;
- (StylerFloat3)shadow;
- (StylerFloat1)radius;
- (StylerFloat1)borderWidth;
- (StylerFloat4)borderWidths;
- (StylerColor1)borderColor;
- (ViewStyler*)hide;
- (ViewStyler*)clipToBounds;

/* Labels
 ********/
- (StylerString1)text;
- (StylerColor1)textColor;
- (StylerTextAlignment)textAlignment;
- (StylerColorFloat2)textShadow;
- (StylerFont)textFont;

@end

@interface UIView (FunStyle)
+ (StylerView) appendTo;
+ (StylerView) prependTo;
+ (ViewStyler*) styler;
+ (StylerRect) frame;
- (ViewStyler*) styler;
- (void)render;

/* Size
 ******/
- (CGFloat)height;
- (CGFloat)width;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;
- (void)resizeByAddingWidth:(CGFloat)width height:(CGFloat)height;
- (void)resizeBySubtractingWidth:(CGFloat)width height:(CGFloat)height;
- (CGSize)sizeToContainSubviews;
- (void)setSize:(CGSize)size;

/* Position
 **********/
- (void)centerInSuperview;
- (void)centerVerticallyInSuperView;
- (void)moveByX:(CGFloat)x y:(CGFloat)y;
- (void)moveByY:(CGFloat)y;
- (void)moveByX:(CGFloat)x;
- (void)moveToX:(CGFloat)x y:(CGFloat)y;
- (void)moveToX:(CGFloat)x;
- (void)moveToY:(CGFloat)y;
- (void)moveToPosition:(CGPoint)origin;
- (void)moveByVector:(CGPoint)vector;
- (CGPoint)topRightCorner;
- (CGFloat)x;
- (CGFloat)y;
- (CGFloat)x2;
- (CGFloat)y2;
- (CGRect)frameInWindow;
- (CGRect)frameOnScreen;

/* Borders, Shadows & Insets
 ***************************/
- (void)setOutsetShadowColor:(UIColor*)color radius:(CGFloat)radius spread:(CGFloat)spread x:(CGFloat)offsetX y:(CGFloat)offsetY;
- (void)setInsetShadowColor:(UIColor*)color radius:(CGFloat)radius spread:(CGFloat)spread x:(CGFloat)offsetX y:(CGFloat)offsetY;
- (void)setOutsetShadowColor:(UIColor*)color radius:(CGFloat)radius;
- (void)setInsetShadowColor:(UIColor*)color radius:(CGFloat)radius;
- (void)setBorderColor:(UIColor*)color width:(CGFloat)width;
- (void)setGradientColors:(NSArray*)colors;

/* View hierarchy
 ****************/
- (UIView*)appendTo:(UIView*)superview;
- (void)empty;
- (UIView*)viewWithName:(NSString*)name;

/* Screenshot
 ************/
- (UIImage*)captureToImage;
- (UIImage*)captureToImageWithScale:(CGFloat)scale;
- (NSData*)captureToPngData;
- (NSData*)captureToJpgData:(CGFloat)compressionQuality;
- (UIView*)ghost;
- (void)ghostWithDuration:(NSTimeInterval)duration animation:(ViewCallback)animationCallback;
- (void)ghostWithDuration:(NSTimeInterval)duration animation:(ViewCallback)animationCallback completion:(ViewCallback)completionCallback;
@end
