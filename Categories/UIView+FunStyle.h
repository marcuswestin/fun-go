//
//  UIView+Style.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewStyler;

typedef ViewStyler* (^Styler)();
typedef ViewStyler* (^StylerView)(UIView* view);
typedef ViewStyler* (^StylerSize)(CGSize size);
typedef ViewStyler* (^StylerFloat1)(float num);
typedef ViewStyler* (^StylerFloat2)(float f1, float f2);
typedef ViewStyler* (^StylerColor1)(UIColor* color);

@interface ViewStyler : NSObject

/* Create & apply
 ****************/
- (id)initWithView:(UIView*)view;
- (id)apply;

/* View hierarchy
 ****************/
- (StylerView)appendTo;
- (StylerView)prependTo;

/* Position
 **********/
- (StylerFloat1)x;
- (StylerFloat1)y;
- (StylerFloat2)xy;
- (ViewStyler*)centerInSuperView;
- (StylerView)centerInView;
- (ViewStyler*)positionAboveSuperview;
- (StylerFloat1)positionFromRight;

/* Size
 ******/
- (StylerFloat1)w;
- (StylerFloat1)h;
- (StylerFloat2)wh;
- (StylerSize)size;
- (ViewStyler*)sizeToFit;
- (ViewStyler*)sizeToParent;

/* Misc
 ******/
- (StylerColor1)bg;
typedef ViewStyler* (^StylerRadius)(CGFloat radius);
- (StylerRadius)radius;
@end

@interface UIView (FunStyle)

+ (StylerView) appendTo;
+ (StylerView) prependTo;
+ (ViewStyler*) styler;
- (ViewStyler*) styler;

/* Size
 ******/
- (CGFloat)height;
- (CGFloat)width;

/* Position
 **********/
- (void)centerVerticallyInView:(UIView*)view;
- (void)centerVerticallyInSuperView;
- (void)moveByX:(NSInteger)x y:(NSInteger)y;
- (void)moveToX:(CGFloat)x y:(CGFloat)y;
- (void)moveToX:(CGFloat)x;
- (void)moveToY:(CGFloat)y;

/* Borders, Shadows & Insets
 ***************************/
- (UIView*)setOutsetShadowColor:(UIColor*)color radius:(CGFloat)radius spread:(CGFloat)spread x:(CGFloat)offsetX y:(CGFloat)offsetY;
- (UIView*)setInsetShadowColor:(UIColor*)color radius:(CGFloat)radius spread:(CGFloat)spread x:(CGFloat)offsetX y:(CGFloat)offsetY;
- (UIView*)setOutsetShadowColor:(UIColor*)color radius:(CGFloat)radius;
- (UIView*)setInsetShadowColor:(UIColor*)color radius:(CGFloat)radius;
- (void)setBorderColor:(UIColor*)color width:(CGFloat)width;

/* Content
 *********/
- (void)empty;
- (UIImage*)captureToImage;
- (NSData*)captureToPngData;
- (NSData*)captureToJpgData:(CGFloat)compressionQuality;
@end
