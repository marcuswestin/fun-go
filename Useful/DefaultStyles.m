//
//  DefaultStyles.m
//  ivyq
//
//  Created by Marcus Westin on 9/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "DefaultStyles.h"
#import <QuartzCore/QuartzCore.h>

#define DeclareClassDefaultStyles(VIEW_CLASS_NAME, STYLES_CLASS_NAME, INSTANCE_NAME)\
@implementation VIEW_CLASS_NAME (DefaultStyles) \
static STYLES_CLASS_NAME * INSTANCE_NAME; \
+ (void) load { INSTANCE_NAME = [STYLES_CLASS_NAME new]; } \
+ (STYLES_CLASS_NAME *)styles { return INSTANCE_NAME; }\
@end

// Base Default style class
///////////////////////////
@implementation DefaultStyles
- (void)applyTo:(UIView *)view {}
@end

// UIView
/////////
DeclareClassDefaultStyles(UIView, UIViewStyles, uiViewStyles)
@implementation UIViewStyles {
    CGRect _frame;
}
- (void)setWidth:(CGFloat)width {
    _frame.size.width = width;
}
- (void)setHeight:(CGFloat)height {
    _frame.size.height = height;
}
- (CGFloat)width {
    return _frame.size.width;
}
- (CGFloat)height {
    return _frame.size.height;
}
- (void)applyTo:(UIView *)view {
    [super applyTo:view];
    view.frame = _frame;
    if (_backgroundColor) {
        view.backgroundColor = _backgroundColor;
    }
    if (_cornerRadius) {
        view.layer.cornerRadius = _cornerRadius;
    }
    if (_borderColor && _borderWidth) {
        view.layer.borderColor = [_borderColor CGColor];
        view.layer.borderWidth = _borderWidth;
    }
}
@end

// UIButton
///////////
DeclareClassDefaultStyles(UIButton, UIButtonStyles, uiButtonStyles)
@implementation UIButtonStyles
- (void)applyTo:(UIButton *)button {
    [super applyTo:button];
    if (_textColor) {
        [button setTitleColor:_textColor forState:UIControlStateNormal];
    }
    if (_font) {
        [button.titleLabel setFont:_font];
    }
}
@end

// UITextField
//////////////
DeclareClassDefaultStyles(UITextField, UITextFieldStyles, uiTextFieldStyles)
@implementation UITextFieldStyles
- (void)applyTo:(UITextField *)textField {
    [super applyTo:textField];
    if (_textColor) {
        [textField setTextColor:_textColor];
    }
    if (_font) {
        [textField setFont:_font];
    }
    if (_pad) {
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setRightViewMode:UITextFieldViewModeAlways];
        [textField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, _pad, 0)]];
        [textField setRightView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, _pad, 0)]];
    }
}
@end

// UITextView
/////////////
DeclareClassDefaultStyles(UITextView, UITextViewStyles, uiTextViewStyles)
@implementation UITextViewStyles
- (void)applyTo:(UITextView *)textView {
    [super applyTo:textView];
    if (_textColor) {
        textView.textColor = _textColor;
    }
    if (_font) {
        textView.font = _font;
    }
}
@end

// UILabel
//////////
DeclareClassDefaultStyles(UILabel, UILabelStyles, uiLabelStyles)
@implementation UILabelStyles
- (void)applyTo:(UILabel *)label {
    [super applyTo:label];
    if (_textColor) {
        [label setTextColor:_textColor];
    }
    if (_font) {
        [label setFont:_font];
    }
}
@end