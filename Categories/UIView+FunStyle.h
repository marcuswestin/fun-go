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

typedef ViewStyler* Styler;
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
typedef ViewStyler* (^StylerColorFloat)(UIColor* color, CGFloat f);
typedef ViewStyler* (^StylerFont)(UIFont* font);
typedef ViewStyler* (^StylerViewFloat)(UIView* view, CGFloat f);
typedef ViewStyler* (^StylerFloatColor)(CGFloat f, UIColor* color);

@interface ViewStyler : FunBase

/* Create & apply
 ****************/
- (void)apply;
- (id)render;
- (StylerView)appendTo;
- (StylerView)prependTo;

/* View hierarchy
 ****************/
- (StylerInteger1)tag;
- (StylerString1)name;

/* Position
 **********/
- (StylerFloat1)x;
- (StylerFloat1)y;
- (StylerFloat2)xy;
- (ViewStyler*)center;
- (ViewStyler*)centerVertically;
- (ViewStyler*)centerHorizontally;
- (StylerFloat1)fromRight;
- (StylerFloat1)fromBottom;
- (StylerPoint)position;
- (StylerRect)frame;
- (StylerFloat4)inset;
- (StylerFloat1)moveDown;
- (StylerViewFloat)below;
- (StylerViewFloat)above;
- (StylerViewFloat)leftOf;
- (StylerViewFloat)rightOf;

/* Size
 ******/
- (StylerFloat1)w;
- (StylerFloat1)h;
- (StylerFloat2)wh;
- (StylerSize)size;
- (ViewStyler*)sizeToFit;
- (ViewStyler*)fill;
- (ViewStyler*)fillW;
- (ViewStyler*)fillH;

/* Styling
 *********/
- (StylerColor1)bg;
- (StylerFloat3)shadow;
- (StylerFloat1)radius;
- (StylerFloatColor)border;
- (StylerFloat4)borderWidths;
- (ViewStyler*)hide;
- (ViewStyler*)clipToBounds;

/* Labels
 ********/
- (Styler)textCenter;
- (StylerString1)text;
- (StylerColor1)textColor;
- (StylerTextAlignment)textAlignment;
- (StylerColorFloat2)textShadow;
- (StylerFont)textFont;

/* Text inputs
 *************/
- (StylerString1)placeholder;
@end


/* View helpers
 **************/
@interface UIView (FunStyler)
+ (StylerView) appendTo;
+ (StylerView) prependTo;
+ (ViewStyler*) styler;
+ (StylerRect) frame;
- (ViewStyler*) styler;
- (void)render;
- (UIView*)viewWithName:(NSString*)name;
@end
