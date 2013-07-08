//
//  UIView+Style.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewStyle;

typedef ViewStyle* (^Styler)();
typedef ViewStyle* (^StylerView)(UIView* view);
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
- (StylerView)centerIn;

/* Color
 *******/
- (StylerColor1)bg;

@end

@interface UIView (FunStyle)

- (ViewStyle*) style;
- (void)moveX:(NSInteger)x y:(NSInteger)y;

@end
