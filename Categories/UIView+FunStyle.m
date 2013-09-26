//
//  UIView+Style.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 ;; Labs Inc. All rights reserved.
//

#import "UIView+FunStyle.h"
#import "FunObjc.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Fun.h"

// Arity 0
#define DeclareStyler(STYLER_NAME, STYLER_CODE)\
-(Styler) STYLER_NAME {\
    STYLER_CODE; return self;\
}
// Arity 1
#define DeclareFloatStyler(STYLER_NAME, FLOAT_ARG_NAME, STYLER_CODE)\
    -(StylerFloat1) STYLER_NAME {\
        return ^(CGFloat FLOAT_ARG_NAME) {\
        STYLER_CODE; return self;\
    };\
}
#define DeclareViewStyler(STYLER_NAME, VIEW_ARG_NAME, STYLER_CODE)\
-(StylerView) STYLER_NAME {\
    return ^(UIView* VIEW_ARG_NAME) {\
        STYLER_CODE; return self;\
    };\
}
#define DeclareIntegerStyler(STYLER_NAME, INT_ARG_NAME, STYLER_CODE)\
-(StylerInteger1) STYLER_NAME {\
    return ^(NSInteger INT_ARG_NAME) {\
        STYLER_CODE; return self;\
    };\
}
#define DeclareStringStyler(STYLER_NAME, STRING_ARG_NAME, STYLER_CODE)\
-(StylerString1) STYLER_NAME {\
    return ^(NSString* STRING_ARG_NAME) {\
        STYLER_CODE; return self;\
    };\
}
#define DeclarePointStyler(STYLER_NAME, POINT_ARG_NAME, STYLER_CODE)\
-(StylerPoint) STYLER_NAME {\
    return ^(CGPoint POINT_ARG_NAME) {\
        STYLER_CODE; return self;\
    };\
}
#define DeclareRectStyler(STYLER_NAME, RECT_ARG_NAME, STYLER_CODE)\
-(StylerRect) STYLER_NAME {\
    return ^(CGRect RECT_ARG_NAME) {\
        STYLER_CODE; return self;\
    };\
}
#define DeclareSizeStyler(STYLER_NAME, SIZE_ARG_NAME, STYLER_CODE)\
-(StylerSize) STYLER_NAME {\
    return ^(CGSize SIZE_ARG_NAME) {\
        STYLER_CODE; return self;\
    };\
}
#define DeclareColorStyler(STYLER_NAME, COLOR_ARG_NAME, STYLER_CODE)\
-(StylerColor1) STYLER_NAME {\
    return ^(UIColor* COLOR_ARG_NAME) {\
        STYLER_CODE; return self;\
    };\
}
#define DeclareStyler1(STYLER_NAME, ARG1_TYPE, ARG1_NAME, STYLER_CODE)\
-(ViewStyler*(^)(ARG1_TYPE)) STYLER_NAME {\
return ^(ARG1_TYPE ARG1_NAME) {\
STYLER_CODE; return self;\
};\
}

// Arity 2
//////////
#define DeclareFloat2Styler(STYLER_NAME, F1ARG_NAME, F2ARG_NAME, STYLER_CODE)\
-(StylerFloat2) STYLER_NAME {\
    return ^(CGFloat F1ARG_NAME, CGFloat F2ARG_NAME) {\
        STYLER_CODE; return self;\
    };\
}
#define DeclareViewFloatStyler(STYLER_NAME, VIEW_ARG_NAME, FLOAT_ARG_NAME, STYLER_CODE)\
-(StylerViewFloat) STYLER_NAME {\
    return ^(UIView* VIEW_ARG_NAME, CGFloat FLOAT_ARG_NAME) {\
        STYLER_CODE; return self;\
    };\
}
#define DeclareFloatColorStyler(STYLER_NAME, FLOAT_ARG_NAME, COLOR_ARG_NAME, STYLER_CODE)\
-(StylerFloatColor) STYLER_NAME {\
    return ^(CGFloat FLOAT_ARG_NAME, UIColor* COLOR_ARG_NAME) {\
        STYLER_CODE; return self;\
    };\
}
// Arity 3
//////////
#define DeclareFloat3Styler(STYLER_NAME, f1NAME, f2NAME, f3NAME, STYLER_CODE)\
    -(StylerFloat3)STYLER_NAME { \
        return ^(CGFloat f1NAME, CGFloat f2NAME, CGFloat f3NAME) {\
        STYLER_CODE; return self;\
    };\
}
// Arity 4
//////////
#define DeclareFloat4Styler(STYLER_NAME, f1NAME, f2NAME, f3NAME, f4NAME, STYLER_CODE)\
-(StylerFloat4)STYLER_NAME { \
    return ^(CGFloat f1NAME, CGFloat f2NAME, CGFloat f3NAME, CGFloat f4NAME) {\
        STYLER_CODE; return self;\
    };\
}

static NSMutableArray* tagIntegerToTagName;
static NSMutableDictionary* tagNameToTagNumber;

@interface ViewStyler ()
- (instancetype)initWithView:(UIView*)view;
@end

/* UIView helpers
 ****************/
@implementation UIView (FunStyler)
+ (StylerView)appendTo {
    return self.styler.appendTo;
}
+ (StylerView)prependTo {
    return self.styler.prependTo;
}
- (ViewStyler *)styler {
    return [[ViewStyler alloc] initWithView:self];
}
- (void)render {}

+ (StylerRect)frame {
    return self.styler.frame;
}
+ (ViewStyler*)styler {
    UIView* instance = [[[self class] alloc] initWithFrame:CGRectZero];
#if defined DEBUG && FALSE
    return instance.styler.bg(RANDOM_COLOR);
#else
    return instance.styler;
#endif
}
- (UIView *)viewWithName:(NSString *)name {
    NSNumber* tagNumber = tagNameToTagNumber[name];
    if (!tagNumber) { return nil; }
    return [self viewWithTag:[tagNumber integerValue]];
}
@end

// Type helpers
///////////////
#define _labelView ((UILabel*)_view)
#define _buttonView ((UIButton*)_view)
#define _textField ((UITextField*)_view)

@implementation ViewStyler {
    UIView* _view;
    CGRect _frame;
    UIEdgeInsets _borderWidths;
    UIColor* _borderColor;
}

+ (void)load {
    tagIntegerToTagName = [NSMutableArray arrayWithObject:@0];
    tagNameToTagNumber = [NSMutableDictionary dictionary];
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

- (id)onTap:(EventHandler)handler {
    id view = [self render];
    [_buttonView onTap:handler];
    return view;
}

- (id)view {
    return _view;
}

/* View Hierarchy
 ****************/
DeclareViewStyler(appendTo, view, [_view appendTo:view])
DeclareViewStyler(prependTo, view, [_view prependTo:view])

DeclareIntegerStyler(tag, tagI, _view.tag = tagI)

DeclareStringStyler(name, tagName,
                    NSNumber* tagNumber = tagNameToTagNumber[tagName];
                    if (!tagNumber) {
                        NSInteger tag = tagIntegerToTagName.count;
                        [tagIntegerToTagName addObject:tagName];
                        tagNameToTagNumber[tagName] = [NSNumber numberWithInteger:tag];
                    }
                    _view.tag = [tagNameToTagNumber[tagName] integerValue];
                    )
/* Position
 **********/
DeclareFloatStyler(x, x, _frame.origin.x = x)
DeclareFloatStyler(y, y, _frame.origin.y = y)
DeclareFloat2Styler(xy, x, y,
                    _frame.origin.x = x;
                    _frame.origin.y = y;
                    )
DeclarePointStyler(position, pos, _frame.origin = pos)
DeclareStyler(center,
              [self centerHorizontally];
              [self centerVertically];
              )
DeclareStyler(centerVertically,
              _frame.origin.y = CGRectGetMidY(_view.superview.bounds) - _frame.size.height/2;
              )
DeclareStyler(centerHorizontally,
              _frame.origin.x = CGRectGetMidX(_view.superview.bounds) - _frame.size.width/2;
              )
DeclareFloatStyler(fromBottom, offset,
                   _frame.origin.y = _view.superview.frame.size.height - _frame.size.height - offset;
                   )
DeclareFloatStyler(fromRight, offset,
                   _frame.origin.x = _view.superview.frame.size.width - _frame.size.width - offset;
                   )
DeclareRectStyler(frame, frame, _frame = frame)

DeclareFloat4Styler(inset, top, right, bottom, left,
                    _frame.origin.y += top;
                    _frame.size.height -= top;
                    _frame.size.height -= bottom;

                    _frame.origin.x += left;
                    _frame.size.width -= left;
                    _frame.size.width -= right;
                    )

DeclareFloatStyler(insetAll, i, return self.inset(i,i,i,i))
DeclareFloatStyler(insetTop, f, return self.inset(f,0,0,0))

DeclareFloatStyler(moveUp, amount, _frame.origin.y -= amount)
DeclareFloatStyler(moveDown, amount, _frame.origin.y += amount)

DeclareViewFloatStyler(below, view, offset, _frame.origin.y = view.y2 + offset)
DeclareViewFloatStyler(above, view, offset, _frame.origin.y = view.y - _frame.size.height - offset)
DeclareViewFloatStyler(rightOf, view, offset, _frame.origin.x = view.x2 + offset)
DeclareViewFloatStyler(leftOf, view, offset, _frame.origin.x = view.x - offset)
DeclareViewStyler(fillRightOf, view,
                  _frame.origin.x = view.x2;
                  _frame.size.width = _view.superview.width - view.x2;
                  )

/* Size
 ******/
DeclareFloatStyler(w, width, _frame.size.width = width)
DeclareFloatStyler(h, height, _frame.size.height = height)
DeclareFloat2Styler(wh, w, h, _frame.size = CGSizeMake(w, h))
DeclareStyler(fill, _frame.size = _view.superview.bounds.size)
DeclareStyler(fillW, _frame.size.width = _view.superview.width)
DeclareStyler(fillH, _frame.size.height = _view.superview.height)

DeclareSizeStyler(size, size, _frame.size = size)
DeclareStyler(sizeToParent, _frame.size = _view.superview.bounds.size)
DeclareStyler(sizeToFit,
              _view.frame = _frame;
              [_view sizeToFit];
              _frame.size = _view.frame.size;
              )


/* Styling
 *********/
DeclareColorStyler(bg, color,
                   _view.backgroundColor = color;
                   if (color.hasTransparency) {
                       _view.opaque = NO;
                   }
                   )
DeclareFloat3Styler(shadow, xOffset, yOffset, radius,
                    _view.layer.shadowColor = [UIColor colorWithWhite:0.5 alpha:1].CGColor;
                    _view.layer.shadowOffset = CGSizeMake(xOffset, yOffset);
                    _view.layer.shadowRadius = radius;
                    _view.layer.shadowOpacity = 0.5;
                    )
DeclareFloatStyler(radius, radius, _view.layer.cornerRadius = radius)
- (StylerFloat4)borderWidths {
    return ^(CGFloat top, CGFloat right, CGFloat bottom, CGFloat left) {
        _borderWidths = UIEdgeInsetsMake(top, left, bottom, right);
        return self;
    };
}
DeclareFloatColorStyler(border, w, borderColor,
                        _borderWidths = UIEdgeInsetsMake(w, w, w, w);
                        _borderColor = borderColor;
                        )

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
    _view.hidden = YES;
    return self;
}
- (ViewStyler *)clipToBounds {
    _view.clipsToBounds = YES;
    return self;
}
/* Labels
 ********/
- (StylerString1)text {
    return ^(NSString* text) {
        if ([_view respondsToSelector:@selector(setText:)]) {
            [_view performSelector:@selector(setText:) withObject:text];
        } else if ([_view isKindOfClass:UIButton.class]) {
            [_buttonView setTitle:text forState:UIControlStateNormal];
        } else {
            [NSException raise:@"Error" format:@"Unknown class in text"];
        }
        return self;
    };
}
- (StylerColor1)textColor {
    return ^(UIColor* textColor) {
        if ([_view isKindOfClass:UILabel.class]) {
            _labelView.textColor = textColor;
        } else if ([_view isKindOfClass:UIButton.class]) {
            [_buttonView setTitleColor:textColor forState:UIControlStateNormal];
        } else {
            [NSException raise:@"Error" format:@"Unknown class in textColor"];
        }
        return self;
    };
}
- (StylerTextAlignment)textAlignment {
    return ^(NSTextAlignment textAlignment) {
        _labelView.textAlignment = textAlignment;
        return self;
    };
}
DeclareStyler(textCenter, self.textAlignment(NSTextAlignmentCenter))
- (StylerColorFloat2)textShadow {
    return ^(UIColor* shadowColor, CGFloat shadowOffsetX, CGFloat shadowOffsetY) {
        _labelView.shadowColor = shadowColor;
        _labelView.shadowOffset = CGSizeMake(shadowOffsetX, shadowOffsetY);
        return self;
    };
}
- (StylerFont)textFont {
    return ^(UIFont* font) {
        _labelView.font = font;
        return self;
    };
}
DeclareIntegerStyler(textLines, lines,
                     _labelView.numberOfLines = lines;
                     )
DeclareStyler(wrapText,
              _labelView.numberOfLines = 0;
              _labelView.lineBreakMode = NSLineBreakByWordWrapping;
              [self sizeToFit]
              )
DeclareStyler1(keyboardType, UIKeyboardType, type, _textField.keyboardType = type)
DeclareStyler1(keyboardAppearance, UIKeyboardAppearance, appearance, _textField.keyboardAppearance = appearance)

/* Text inputs
 *************/
DeclareStringStyler(placeholder, placeholder, _textField.placeholder = placeholder)
@end
