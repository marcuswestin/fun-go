//
//  UIView+Fun.h
//  ivyq
//
//  Created by Marcus Westin on 9/10/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunObjc.h"

@interface UIView (Fun)

/* Size
 ******/
- (CGFloat)height;
- (CGFloat)width;
- (CGSize)size;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;
- (void)setSize:(CGSize)size;
- (void)resizeByAddingWidth:(CGFloat)width height:(CGFloat)height;
- (void)resizeBySubtractingWidth:(CGFloat)width height:(CGFloat)height;
- (CGSize)sizeToContainSubviews;

/* Position
 **********/
- (void)centerView;
- (void)centerVertically;
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
- (void)empty;
- (void)appendTo:(UIView*)superview;
- (void)prependTo:(UIView*)superview;

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

@interface UIView (Blur)
- (void)blur;
- (void)blur:(UIColor*)color;
@end